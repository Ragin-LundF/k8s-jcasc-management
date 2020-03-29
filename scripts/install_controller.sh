#!/bin/bash
#########
## DO NOT USE THIS SCRIPT DIRECTLY!
## This script will be loaded by the 'k8s-jcasc.sh' script.

# Variables
_K8S_MGMT_HELM_INSTALL_COMMAND="install"
_K8S_MGMT_HELM_UPGRADE_COMMAND="upgrade"


##########
# This function installs the Jenkins instance
#
# argument 1: INSTALL or UPGRADE (see _K8S_MGMT_COMMAND_INSTALL or _K8S_MGMT_COMMAND_UPGRADE at the arguments_utils.sh file)
##########
function installOrUpgradeJenkins() {
    ## install Jenkins to Kubernetes
    # arguments
    local ARG_INSTALL_UPGRADE_COMMAND=$1

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
    # get namespace from global variables or ask for the name
    local __INTERNAL_NAMESPACE
    dialogAskForNamespace __INTERNAL_NAMESPACE
    # get project directory
    local __INTERNAL_PROJECT_DIRECTORY
    dialogAskForProjectDirectory __INTERNAL_PROJECT_DIRECTORY
    # get deployment name
    local __INTERNAL_DEPLOYMENT_NAME
    dialogAskForDeploymentName __INTERNAL_DEPLOYMENT_NAME
    # get IP address of the installation
    local __INTERNAL_IP_ADDRESS
    readIpForNamespaceFromFile "${__INTERNAL_NAMESPACE}" __INTERNAL_IP_ADDRESS

    # create new variable with full project directory
    local __INTERNAL_FULL_PROJECT_DIRECTORY="${PROJECTS_BASE_DIRECTORY}${__INTERNAL_PROJECT_DIRECTORY}"

    # set global variables
    if [[ ! -z "${__INTERNAL_NAMESPACE}" ]]; then
        K8S_MGMT_NAMESPACE="${__INTERNAL_NAMESPACE}"
    fi
    if [[ ! -z "${__INTERNAL_PROJECT_DIRECTORY}" ]]; then
        K8S_MGMT_PROJECT_DIRECTORY="${__INTERNAL_PROJECT_DIRECTORY}"
    fi
    if [[ ! -z "${__INTERNAL_DEPLOYMENT_NAME}" ]]; then
        K8S_MGMT_DEPLOYMENTNAME="${__INTERNAL_DEPLOYMENT_NAME}"
    fi

    # start with apply secrets to kubernetes
    echo ""
    echo "  INFO: Apply secrets..."
    echo ""
    applySecrets "${K8S_MGMT_NAMESPACE}"

    ## TODO: install persistence volume claim

    # install or upgrade the Jenkins Helm Chart
    helm ${__INTERNAL_HELM_COMMAND} ${K8S_MGMT_DEPLOYMENTNAME} ${__INTERNAL_HELM_JENKINS_PATH} -n ${K8S_MGMT_NAMESPACE} -f ${K8S_MGMT_PROJECT_DIRECTORY}/jenkins_helm_values.yaml
}

##########
# This function uninstalls the Jenkins instance
#
##########
function uninstallJenkins() {
    local __INTERNAL_NAMESPACE
    dialogAskForNamespace __INTERNAL_NAMESPACE
    local __INTERNAL_DEPLOYMENT_NAME
    dialogAskForDeploymentName __INTERNAL_DEPLOYMENT_NAME

    helm uninstall ${__INTERNAL_DEPLOYMENT_NAME} -n ${__INTERNAL_NAMESPACE}
}