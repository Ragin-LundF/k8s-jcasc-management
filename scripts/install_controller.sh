#!/bin/bash
#########
## DO NOT USE THIS SCRIPT DIRECTLY!
## This script will be loaded by the 'k8s-jcasc.sh' script.

# Variables
_K8S_MGMT_HELM_INSTALL_COMMAND="install"
_K8S_MGMT_HELM_UPGRADE_COMMAND="upgrade"


##########
# This function installs the persistence volume claim if needed
#
##########
function installPersistenceVolumeClaim() {
    # variables
    local __INTERNAL_PROJECT_DIRECTORY
    dialogAskForProjectDirectory __INTERNAL_PROJECT_DIRECTORY "true"
    local __INTERNAL_NAMESPACE
    dialogAskForNamespace __INTERNAL_NAMESPACE

    # create new variable with full project directory
    local __INTERNAL_FULL_PROJECT_DIRECTORY="${PROJECTS_BASE_DIRECTORY}${__INTERNAL_PROJECT_DIRECTORY}"

    # if pvc exists, try to install it
    if [[ -f "${__INTERNAL_FULL_PROJECT_DIRECTORY}/pvc_claim.yaml" ]]; then
        # load the name of the PVC
        local __INTERNAL_PVC_FROM_FILE=$(grep 'name:' "${__INTERNAL_FULL_PROJECT_DIRECTORY}/pvc_claim.yaml" | awk '{print $2}' | tr -d '"')
        # check Kubernetes, which PVC for the namespace are existing
        local __INTERNAL_EXISTING_PVC_ON_K8S=$(kubectl -n "${__INTERNAL_NAMESPACE}" get pvc | awk '{print $1}' | grep "${__INTERNAL_PVC_FROM_FILE}")
        # predefine variable to decide if PVC has to be installed or not
        local __INTERNAL_BOOLEAN_CREATE_PVC=true

        # Because of similar names, we have to check the PVC like a list, because it can contain multiple elements
        if [[ "${__INTERNAL_EXISTING_PVC_ON_K8S}" =~ [[:space:]] ]]; then
            local array __INTERNAL_EXISTING_PVC_ON_K8S_ARRAY=(${__INTERNAL_EXISTING_PVC_ON_K8S})
            for __INTERNAL_EXISTING_PVC_ARR_ELEMENT in "${__INTERNAL_EXISTING_PVC_ON_K8S_ARRAY[@]}"
            do
                if [[ "${__INTERNAL_EXISTING_PVC_ARR_ELEMENT}" == "${__INTERNAL_PVC_FROM_FILE}" ]]; then
                    __INTERNAL_BOOLEAN_CREATE_PVC=false
                    break
                fi
            done
        else
            # Only one element was found, compare it directly
            if [[ "${__INTERNAL_EXISTING_PVC_ON_K8S}" == "${__INTERNAL_PVC_FROM_FILE}" ]]; then
                __INTERNAL_BOOLEAN_CREATE_PVC=false
            fi
        fi

        # Looks like no existing PVC was found. Lets create a new one
        if [[ "${__INTERNAL_BOOLEAN_CREATE_PVC}" == "true" ]]; then
            echo ""
            echo "  INFO: Create PVC ${__INTERNAL_PVC_FROM_FILE}..."
            echo ""
            kubectl -n "${__INTERNAL_NAMESPACE}" apply -f "${__INTERNAL_FULL_PROJECT_DIRECTORY}/pvc_claim.yaml"
            # now we should wait shortly, to avoid race conditions
            sleep 1
        else
            echo ""
            echo "  INFO: PVC ${__INTERNAL_PVC_FROM_FILE} already exists..."
            echo ""
        fi
    fi
}

##########
# This function checks the cluster, if namespace already exists.
# If this is not the case, it creates the namespace.
# If the namespace argument is empty, it does nothing.
#
# argument 1: Namespace name
##########
function checkAndInstallNamespace() {
    local __INTERNAL_NAMESPACE_TO_CHECK=$1

    if [[ -n "${__INTERNAL_NAMESPACE_TO_CHECK}" ]]; then
        # lookup if namespace already exists
        local __INTERNAL_NS_EXISTS
        __INTERNAL_NS_EXISTS=$(kubectl get namespaces | awk '{print $1}' | grep "${__INTERNAL_NAMESPACE_TO_CHECK}")

        if [[ -z "${__INTERNAL_NS_EXISTS}" ]]; then
            kubectl create namespace "${__INTERNAL_NAMESPACE_TO_CHECK}"
        fi
    fi
}

##########
# This function installs the Jenkins instance
#
# argument 1: INSTALL or UPGRADE (see _K8S_MGMT_COMMAND_INSTALL or _K8S_MGMT_COMMAND_UPGRADE at the arguments_utils.sh file)
# argument 2: return value if jenkins installation was existing or not to decide, if a ingress should be created or not
##########
function installOrUpgradeJenkins() {
    ## install Jenkins to Kubernetes
    # arguments
    local ARG_INSTALL_UPGRADE_COMMAND=$1
    local ARG_RETVAL_K8S_MGMT_INSTALL_JENKINS_HELM_EXISTING=$2
    local __JENKINS_HELM_CHARTS_EXISTING

    # validate helm command
    local __INTERNAL_HELM_COMMAND
    if [[ "${ARG_INSTALL_UPGRADE_COMMAND}" == "${_K8S_MGMT_COMMAND_INSTALL}" ]]; then
        __INTERNAL_HELM_COMMAND="${_K8S_MGMT_HELM_INSTALL_COMMAND}"
    elif [[ "${ARG_INSTALL_UPGRADE_COMMAND}" == "${_K8S_MGMT_COMMAND_UPGRADE}" ]]; then
        __INTERNAL_HELM_COMMAND="${_K8S_MGMT_HELM_UPGRADE_COMMAND}"
    else
        echo ""
        echo "  ERROR: Unknown command used! Please do not use the install_controller.sh script directly."
        echo ""
        exit 1
    fi

    # path to helm charts
    local __INTERNAL_HELM_JENKINS_PATH="./charts/jenkins-master"
    # get project directory
    local __INTERNAL_PROJECT_DIRECTORY_NAME
    dialogAskForProjectDirectory __INTERNAL_PROJECT_DIRECTORY_NAME "true"
    # get namespace from global variables or ask for the name
    local __INTERNAL_NAMESPACE
    dialogAskForNamespace __INTERNAL_NAMESPACE
    # get deployment name
    local __INTERNAL_DEPLOYMENT_NAME
    dialogAskForDeploymentName __INTERNAL_DEPLOYMENT_NAME
    # get IP address of the installation
    local __INTERNAL_IP_ADDRESS
    readIpForNamespaceFromFile "${__INTERNAL_NAMESPACE}" __INTERNAL_IP_ADDRESS

    # create new variable with full project directory
    local __INTERNAL_FULL_PROJECT_DIRECTORY="${PROJECTS_BASE_DIRECTORY}${__INTERNAL_PROJECT_DIRECTORY_NAME}"

    # set global variables
    if [[ -n "${__INTERNAL_NAMESPACE}" ]]; then
        K8S_MGMT_NAMESPACE="${__INTERNAL_NAMESPACE}"
    fi
    if [[ -n "${__INTERNAL_PROJECT_DIRECTORY_NAME}" ]]; then
        K8S_MGMT_PROJECT_DIRECTORY="${__INTERNAL_PROJECT_DIRECTORY_NAME}"
    fi
    if [[ -n "${__INTERNAL_DEPLOYMENT_NAME}" ]]; then
        JENKINS_MASTER_DEPLOYMENT_NAME="${__INTERNAL_DEPLOYMENT_NAME}"
    fi

    # check namespace and install it if it does not exist
    checkAndInstallNamespace "${K8S_MGMT_NAMESPACE}"

    # Now lets install the PVC if it does not exist
    installPersistenceVolumeClaim

    # install or upgrade the Jenkins Helm Chart
    if [[ -f "${__INTERNAL_FULL_PROJECT_DIRECTORY}/jenkins_helm_values.yaml" ]]; then
        __JENKINS_HELM_CHARTS_EXISTING="true"
        # start with apply secrets to kubernetes
        echo ""
        echo "  INFO: Apply secrets..."
        echo ""
        applySecrets "${K8S_MGMT_NAMESPACE}"

        # start with installing Jenkins to kubernetes
        echo ""
        echo "  INFO: Installing Jenkins..."
        echo ""

        # if output logging is active, prepare it
        local __INTERNAL_COMMAND_EXTENSION=""
        if [[ -n "${K8S_MGMT_YAML_OUTPUT_FILE}" ]]; then
            {
                date
                echo "K8S_MGMT COMMAND:"
                echo "================="
                echo "helm ${__INTERNAL_HELM_COMMAND} ${JENKINS_MASTER_DEPLOYMENT_NAME} ${__INTERNAL_HELM_JENKINS_PATH} -n ${K8S_MGMT_NAMESPACE} -f ${__INTERNAL_FULL_PROJECT_DIRECTORY}/jenkins_helm_values.yaml"
            } >> "${K8S_MGMT_YAML_OUTPUT_FILE}"
            __INTERNAL_COMMAND_EXTENSION="--dry-run --debug"
        fi

        # Execute command and print output
        local __INTERNAL_JENKINS_INSTALL_OUTPUT
        __INTERNAL_JENKINS_INSTALL_OUTPUT=$(helm "${__INTERNAL_HELM_COMMAND}" "${JENKINS_MASTER_DEPLOYMENT_NAME}" "${__INTERNAL_HELM_JENKINS_PATH}" -n "${K8S_MGMT_NAMESPACE}" ${__INTERNAL_COMMAND_EXTENSION} -f "${__INTERNAL_FULL_PROJECT_DIRECTORY}/jenkins_helm_values.yaml")
        echo "${__INTERNAL_JENKINS_INSTALL_OUTPUT}"
        if [[ -n "${K8S_MGMT_YAML_OUTPUT_FILE}" ]]; then
            echo "${__INTERNAL_JENKINS_INSTALL_OUTPUT}" >> ${K8S_MGMT_YAML_OUTPUT_FILE}
        fi
    else
        __JENKINS_HELM_CHARTS_EXISTING="false"
        echo ""
        echo "  INFO: No Jenkins Helm values found...skipping..."
        echo ""
    fi

    # lookup for scripts to execute
    if [[ -d "${__INTERNAL_FULL_PROJECT_DIRECTORY}/scripts/" ]]; then
        find "${__INTERNAL_FULL_PROJECT_DIRECTORY}/scripts/" -name "i_*.sh" -type f -exec chmod +x {} \; -exec {} \;
    fi
    eval ${ARG_RETVAL_K8S_MGMT_INSTALL_JENKINS_HELM_EXISTING}="\${__JENKINS_HELM_CHARTS_EXISTING}"
}

##########
# This function installs the Nginx-Ingress controller instance and loadbalancer
#
# # argument 1: Is Jenkins available? true = Jenkins ingress will be installed, if configured | false = Jenkins ingress will be disabled
##########
function installIngressControllerToNamespace() {
    local ARG_JENKINS_IS_EXISTING=$1

    # path to helm charts
    local __INTERNAL_HELM_NGINX_INGRESS_PATH="./charts/nginx-ingress-controller"
    # get project directory
    local __INTERNAL_PROJECT_DIRECTORY_NAME
    dialogAskForProjectDirectory __INTERNAL_PROJECT_DIRECTORY_NAME "true"
    # get namespace from global variables or ask for the name
    local __INTERNAL_NAMESPACE
    dialogAskForNamespace __INTERNAL_NAMESPACE

    # create new variable with full project directory
    local __INTERNAL_FULL_PROJECT_DIRECTORY="${PROJECTS_BASE_DIRECTORY}${__INTERNAL_PROJECT_DIRECTORY_NAME}"

    if [[ -f "${__INTERNAL_FULL_PROJECT_DIRECTORY}/nginx_ingress_helm_values.yaml" ]]; then
        echo ""
        echo "  INFO: Try to install nginx ingress controller..."
        echo ""
        local __SET_JENKINS_INGRESS_DISABLED=""

        if [[ "false" == "${ARG_JENKINS_IS_EXISTING}" ]]; then
            __SET_JENKINS_INGRESS_DISABLED="--set k8sJenkinsMgmt.ingress.enabled=false"
            echo ""
            echo "  INFO: No Jenkins Deployment found. Deactivating Jenkins ingress..."
            echo ""
        fi
        # install the nginx-ingress controller with loadbalancer and default route
        # if output logging is active, prepare it
        local __INTERNAL_COMMAND_EXTENSION=""
        if [[ -n "${K8S_MGMT_YAML_OUTPUT_FILE}" ]]; then
            {
                date
                echo "K8S_MGMT COMMAND:"
                echo "================="
                echo "helm install ${NGINX_INGRESS_DEPLOYMENT_NAME} ${__INTERNAL_HELM_NGINX_INGRESS_PATH} -n ${__INTERNAL_NAMESPACE} -f ${__INTERNAL_FULL_PROJECT_DIRECTORY}/nginx_ingress_helm_values.yaml ${__SET_JENKINS_INGRESS_DISABLED}"
            } >> "${K8S_MGMT_YAML_OUTPUT_FILE}"
            __INTERNAL_COMMAND_EXTENSION="--dry-run --debug"
        fi

        # Execute command and write output
        local __INTERNAL_INSTALL_NGINX_OUTPUT
        __INTERNAL_INSTALL_NGINX_OUTPUT=$(helm install "${NGINX_INGRESS_DEPLOYMENT_NAME}" "${__INTERNAL_HELM_NGINX_INGRESS_PATH}" -n "${__INTERNAL_NAMESPACE}" ${__INTERNAL_COMMAND_EXTENSION} -f "${__INTERNAL_FULL_PROJECT_DIRECTORY}/nginx_ingress_helm_values.yaml" ${__SET_JENKINS_INGRESS_DISABLED})
        echo "${__INTERNAL_INSTALL_NGINX_OUTPUT}"
        if [[ -n "${K8S_MGMT_YAML_OUTPUT_FILE}" ]]; then
             echo "${__INTERNAL_INSTALL_NGINX_OUTPUT}" >> ${K8S_MGMT_YAML_OUTPUT_FILE}
        fi
    else
        echo ""
        echo "  INFO: No Nginx Helm values found..."
        echo ""
    fi
}

##########
# This function installs the Nginx-Ingress controller instance and loadbalancer
#
##########
function uninstallIngressControllerFromNamespace() {
    # get namespace from global variables or ask for the name
    local __INTERNAL_NAMESPACE
    dialogAskForNamespace __INTERNAL_NAMESPACE

    # uninstall the nginx-ingress controller
    local __INTERNAL_COMMAND_EXTENSION=""
    if [[ -n "${K8S_MGMT_YAML_OUTPUT_FILE}" ]]; then
        {
            date
            echo "K8S_MGMT COMMAND:"
            echo "================="
            echo "helm uninstall ${NGINX_INGRESS_DEPLOYMENT_NAME} -n ${__INTERNAL_NAMESPACE}"
        } >> "${K8S_MGMT_YAML_OUTPUT_FILE}"
        __INTERNAL_COMMAND_EXTENSION=" --dry-run --debug"
    fi
    local __INTERNAL_NGINX_UNINSTALL_OUTPUT
    __INTERNAL_NGINX_UNINSTALL_OUTPUT=$(helm uninstall "${NGINX_INGRESS_DEPLOYMENT_NAME}" -n "${__INTERNAL_NAMESPACE}" ${__INTERNAL_COMMAND_EXTENSION})
    echo "${__INTERNAL_NGINX_UNINSTALL_OUTPUT}"
    if [[ -n "${K8S_MGMT_YAML_OUTPUT_FILE}" ]]; then
        echo "${__INTERNAL_NGINX_UNINSTALL_OUTPUT}" >> ${K8S_MGMT_YAML_OUTPUT_FILE}
    fi
}

##########
# This function uninstalls the Jenkins instance
#
##########
function uninstallJenkins() {
    local __INTERNAL_NAMESPACE
    dialogAskForNamespace __INTERNAL_NAMESPACE
    local __INTERNAL_HELM_DEPLOYMENT_NAME
    dialogAskForDeploymentName __INTERNAL_HELM_DEPLOYMENT_NAME

    # prepare output or debugging
    local __INTERNAL_COMMAND_EXTENSION=""
    if [[ -n "${K8S_MGMT_YAML_OUTPUT_FILE}" ]]; then
        {
            date
            echo "K8S_MGMT COMMAND:"
            echo "================="
            echo "helm uninstall ${__INTERNAL_HELM_DEPLOYMENT_NAME} -n ${__INTERNAL_NAMESPACE}"
        } >> "${K8S_MGMT_YAML_OUTPUT_FILE}"
        __INTERNAL_COMMAND_EXTENSION=" --dry-run --debug"
    fi

    # Execute command
    local __INTERNAL_JENKINS_UNINSTALL_OUTPUT
    __INTERNAL_JENKINS_UNINSTALL_OUTPUT=$(helm uninstall "${__INTERNAL_HELM_DEPLOYMENT_NAME}" -n "${__INTERNAL_NAMESPACE}" ${__INTERNAL_COMMAND_EXTENSION})
    echo "${__INTERNAL_JENKINS_UNINSTALL_OUTPUT}"
    if [[ -n "${K8S_MGMT_YAML_OUTPUT_FILE}" ]]; then
        echo "${__INTERNAL_JENKINS_UNINSTALL_OUTPUT}" >> ${K8S_MGMT_YAML_OUTPUT_FILE}
    fi

    # lookup for scripts to execute if namespace name = directory name
    if [[ -d "${PROJECTS_BASE_DIRECTORY}${__INTERNAL_NAMESPACE}/scripts/" ]]; then
        find "${PROJECTS_BASE_DIRECTORY}${__INTERNAL_NAMESPACE}/scripts/" -name "d_*.sh" -type f -exec chmod +x {} \; -exec {} \;
    fi
}
