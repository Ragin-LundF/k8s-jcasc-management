#!/bin/bash
#########
## DO NOT USE THIS SCRIPT DIRECTLY!
## This script will be loaded by the 'k8s-jcasc.sh' script.

##########
# Process '##PROJECT_DIRECTORY## Jenkins in namespace ##NAMESPACE##' placeholder in the new project directory
# with a new Jenkins system message.
# !!! This should be the first replacement call !!!
#
# argument 1: directory of the project
# argument 2: IP address
##########
function processTemplatesWithJenkinsSystemMessage() {
    # arguments
    local ARG_FULL_PROJECT_DIRECTORY=$1
    local ARG_JENKINS_SYSTEM_MESSAGE=$2

    # If a custom message should be set, overwrite the message
    if [[ -n "${ARG_JENKINS_SYSTEM_MESSAGE}" ]]; then
        replaceStringInFile "##PROJECT_DIRECTORY## Jenkins in namespace ##NAMESPACE##" "${ARG_JENKINS_SYSTEM_MESSAGE}" "${ARG_FULL_PROJECT_DIRECTORY}/jcasc_config.yaml"
    fi
}

##########
# Process '##NAMESPACE##' placeholder in the new project directory
#
# argument 1: directory of the project
# argument 2: namespace name
##########
function processTemplatesWithNamespace() {
    # arguments
    local ARG_FULL_PROJECT_DIRECTORY=$1
    local ARG_NAMESPACE=$2

    # check if nginx ingress is existing
    if [[ -f "${ARG_FULL_PROJECT_DIRECTORY}/nginx_ingress_helm_values.yaml" ]]; then
        replaceStringInFile "##NAMESPACE##" "${ARG_NAMESPACE}" "${ARG_FULL_PROJECT_DIRECTORY}/nginx_ingress_helm_values.yaml"
    fi

    # check if Jenkins JCasC file is existing
    if [[ -f "${ARG_FULL_PROJECT_DIRECTORY}/jcasc_config.yaml" ]]; then
        replaceStringInFile "##NAMESPACE##" "${ARG_NAMESPACE}" "${ARG_FULL_PROJECT_DIRECTORY}/jcasc_config.yaml"
    fi

    # if a persistence volume claim exists, replace values there
    if [[ -f "${ARG_FULL_PROJECT_DIRECTORY}/pvc_claim.yaml" ]]; then
        # Name of the Jenkins deployment
        replaceStringInFile "##NAMESPACE##" "${ARG_NAMESPACE}" "${ARG_FULL_PROJECT_DIRECTORY}/pvc_claim.yaml"
    fi
}

##########
# Process '##PUBLIC_IP_ADDRESS##' placeholder in the new project directory
#
# argument 1: directory of the project
# argument 2: IP address
##########
function processTemplatesWithIpAddress() {
    # arguments
    local ARG_FULL_PROJECT_DIRECTORY=$1
    local ARG_IP_ADDRESS=$2

    if [[ -f "${ARG_FULL_PROJECT_DIRECTORY}/jcasc_config.yaml" ]]; then
        replaceStringInFile "##PUBLIC_IP_ADDRESS##" "${ARG_IP_ADDRESS}" "${ARG_FULL_PROJECT_DIRECTORY}/jcasc_config.yaml"
    fi
    if [[ -f "${ARG_FULL_PROJECT_DIRECTORY}/nginx_ingress_helm_values.yaml" ]]; then
        replaceStringInFile "##PUBLIC_IP_ADDRESS##" "${ARG_IP_ADDRESS}" "${ARG_FULL_PROJECT_DIRECTORY}/nginx_ingress_helm_values.yaml"
    fi
}

##########
# Process '##PROJECT_JENKINS_JOB_DEFINITION_REPOSITORY##' placeholder in the new project directory
#
# argument 1: URL to Jenkins seed job repository
# argument 2: directory of the project
##########
function processTemplatesWithJenkinsJobRepository() {
    # arguments
    local ARG_FULL_PROJECT_DIRECTORY=$1
    local ARG_JENKINS_JOB_REPOSITORY=$2

    replaceStringInFile "##PROJECT_JENKINS_JOB_DEFINITION_REPOSITORY##" "${ARG_JENKINS_JOB_REPOSITORY}" "${ARG_FULL_PROJECT_DIRECTORY}/jcasc_config.yaml"
}

##########
# Process '##PROJECT_DIRECTORY##' placeholder in the new project directory
#
# argument 1: full directory of the project
# argument 2: Project directory (without base directory)
##########
function processTemplatesWithProjectDirectory() {
    # arguments
    local ARG_FULL_PROJECT_DIRECTORY=$1
    local ARG_PROJECT_DIRECTORY=$2

    replaceStringInFile "##PROJECT_DIRECTORY##" "${ARG_PROJECT_DIRECTORY}" "${ARG_FULL_PROJECT_DIRECTORY}/jcasc_config.yaml"
    replaceStringInFile "##PROJECT_DIRECTORY##" "${ARG_PROJECT_DIRECTORY}" "${ARG_FULL_PROJECT_DIRECTORY}/jenkins_helm_values.yaml"
}

##########
# Process '##PROJECT_DIRECTORY##' placeholder in the new project directory
#
# argument 1: full directory of the project
# argument 2: Name of the existing claim
##########
function processTemplatesWithPersistenceExistingClaim() {
    # arguments
    local ARG_FULL_PROJECT_DIRECTORY=$1
    local ARG_EXISTING_PERSISTENCE_CLAIM=$2

    replaceStringInFile "##JENKINS_MASTER_PERSISTENCE_EXISTING_CLAIM##" "${ARG_EXISTING_PERSISTENCE_CLAIM} " "${ARG_FULL_PROJECT_DIRECTORY}/jenkins_helm_values.yaml"

    # if a persistence volume claim exists, replace values there
    if [[ -f "${ARG_FULL_PROJECT_DIRECTORY}/pvc_claim.yaml" ]]; then
        # Name of the PVC
        replaceStringInFile "##K8S_MGMT_PERSISTENCE_VOLUME_CLAIM_NAME##" "${ARG_EXISTING_PERSISTENCE_CLAIM} " "${ARG_FULL_PROJECT_DIRECTORY}/pvc_claim.yaml"
    fi
}

##########
# Process global configuration placeholder
#
# argument 1: directory of the project
##########
function processTemplatesWithGlobalConfiguration() {
    # arguments
    local ARG_FULL_PROJECT_DIRECTORY=$1

    # if a nginx helm values.yaml exists, replace values there
    if [[ -f "${ARG_FULL_PROJECT_DIRECTORY}/nginx_ingress_helm_values.yaml" ]]; then
        replaceStringInFile "##JENKINS_MASTER_DEPLOYMENT_NAME##" "${JENKINS_MASTER_DEPLOYMENT_NAME}" "${ARG_FULL_PROJECT_DIRECTORY}/nginx_ingress_helm_values.yaml"
        # Jenkins master default URI prefix
        replaceStringInFile "##JENKINS_MASTER_DEFAULT_URI_PREFIX##" "${JENKINS_MASTER_DEFAULT_URI_PREFIX}" "${ARG_FULL_PROJECT_DIRECTORY}/nginx_ingress_helm_values.yaml"

        # nginx-ingress-controller deployment name
        replaceStringInFile "##NGINX_INGRESS_DEPLOYMENT_NAME##" "${NGINX_INGRESS_DEPLOYMENT_NAME} " "${ARG_FULL_PROJECT_DIRECTORY}/nginx_ingress_helm_values.yaml"
        replaceStringInFile "##NGINX_INGRESS_CONTROLLER_CONTAINER_IMAGE##" "${NGINX_INGRESS_CONTROLLER_CONTAINER_IMAGE}" "${ARG_FULL_PROJECT_DIRECTORY}/nginx_ingress_helm_values.yaml"
        replaceStringInFile "##NGINX_INGRESS_CONTROLLER_CONTAINER_PULL_SECRETS##" "${NGINX_INGRESS_CONTROLLER_CONTAINER_PULL_SECRETS} " "${ARG_FULL_PROJECT_DIRECTORY}/nginx_ingress_helm_values.yaml"
        replaceStringInFile "##NGINX_INGRESS_CONTROLLER_FOR_NAMESPACE##" "${NGINX_INGRESS_CONTROLLER_FOR_NAMESPACE}" "${ARG_FULL_PROJECT_DIRECTORY}/nginx_ingress_helm_values.yaml"
        replaceStringInFile "##NGINX_INGRESS_ANNOTATION_CLASS##" "${NGINX_INGRESS_ANNOTATION_CLASS} " "${ARG_FULL_PROJECT_DIRECTORY}/nginx_ingress_helm_values.yaml"
        # configure loadbalancer
        replaceStringInFile "##NGINX_LOADBALANCER_ENABLED##" "${NGINX_LOADBALANCER_ENABLED} " "${ARG_FULL_PROJECT_DIRECTORY}/nginx_ingress_helm_values.yaml"
        replaceStringInFile "##NGINX_LOADBALANCER_HTTP_PORT##" "${NGINX_LOADBALANCER_HTTP_PORT} " "${ARG_FULL_PROJECT_DIRECTORY}/nginx_ingress_helm_values.yaml"
        replaceStringInFile "##NGINX_LOADBALANCER_HTTP_TARGETPORT##" "${NGINX_LOADBALANCER_HTTP_TARGETPORT} " "${ARG_FULL_PROJECT_DIRECTORY}/nginx_ingress_helm_values.yaml"
        replaceStringInFile "##NGINX_LOADBALANCER_HTTPS_PORT##" "${NGINX_LOADBALANCER_HTTPS_PORT} " "${ARG_FULL_PROJECT_DIRECTORY}/nginx_ingress_helm_values.yaml"
        replaceStringInFile "##NGINX_LOADBALANCER_HTTPS_TARGETPORT##" "${NGINX_LOADBALANCER_HTTPS_TARGETPORT} " "${ARG_FULL_PROJECT_DIRECTORY}/nginx_ingress_helm_values.yaml"
    fi

    # if a jenkins jcasc yaml exists, replace values there
    if [[ -f "${ARG_FULL_PROJECT_DIRECTORY}/jcasc_config.yaml" ]]; then
        # Kubernetes server certificate
        replaceStringInFile "##KUBERNETES_SERVER_CERTIFICATE##" "${KUBERNETES_SERVER_CERTIFICATE}" "${ARG_FULL_PROJECT_DIRECTORY}/jcasc_config.yaml"
        # Name of the Jenkins deployment
        replaceStringInFile "##JENKINS_MASTER_DEPLOYMENT_NAME##" "${JENKINS_MASTER_DEPLOYMENT_NAME}" "${ARG_FULL_PROJECT_DIRECTORY}/jcasc_config.yaml"

        # Docker Registry Credentials ID for Kubernetes
        replaceStringInFile "##KUBERNETES_DOCKER_REGISTRY_CREDENTIALS_ID##" "${KUBERNETES_DOCKER_REGISTRY_CREDENTIALS_ID}" "${ARG_FULL_PROJECT_DIRECTORY}/jcasc_config.yaml"
        # Maven Repository Credentials ID
        replaceStringInFile "##MAVEN_REPOSITORY_SECRETS_CREDENTIALS_ID##" "${MAVEN_REPOSITORY_SECRETS_CREDENTIALS_ID}" "${ARG_FULL_PROJECT_DIRECTORY}/jcasc_config.yaml"
        # NPM Repository Credentials ID
        replaceStringInFile "##NPM_REPOSITORY_SECRETS_CREDENTIALS_ID##" "${NPM_REPOSITORY_SECRETS_CREDENTIALS_ID}" "${ARG_FULL_PROJECT_DIRECTORY}/jcasc_config.yaml"
        # VCS Credentials ID
        replaceStringInFile "##VCS_REPOSITORY_SECRETS_CREDENTIALS_ID##" "${VCS_REPOSITORY_SECRETS_CREDENTIALS_ID}" "${ARG_FULL_PROJECT_DIRECTORY}/jcasc_config.yaml"
        # Jenkins master default URI prefix
        replaceStringInFile "##JENKINS_MASTER_DEFAULT_URI_PREFIX##" "${JENKINS_MASTER_DEFAULT_URI_PREFIX}" "${ARG_FULL_PROJECT_DIRECTORY}/jcasc_config.yaml"
        # Jenkins master label for seed job binding
        replaceStringInFile "##JENKINS_MASTER_DEFAULT_LABEL##" "${JENKINS_MASTER_DEFAULT_LABEL}" "${ARG_FULL_PROJECT_DIRECTORY}/jcasc_config.yaml"
        # URL to the seed job script repository
        replaceStringInFile "##JENKINS_JOBDSL_SEED_JOB_SCRIPT_URL##" "${JENKINS_JOBDSL_SEED_JOB_SCRIPT_URL}" "${ARG_FULL_PROJECT_DIRECTORY}/jcasc_config.yaml"
        # replace Jenkins admin password
        replaceStringInFile "##JENKINS_MASTER_ADMIN_PASSWORD_ENCRYPTED##" "${JENKINS_MASTER_ADMIN_PASSWORD_ENCRYPTED}" "${ARG_FULL_PROJECT_DIRECTORY}/jcasc_config.yaml"
        replaceStringInFile "##JENKINS_MASTER_PROJECT_USER_PASSWORD_ENCRYPTED##" "${JENKINS_MASTER_PROJECT_USER_PASSWORD_ENCRYPTED}" "${ARG_FULL_PROJECT_DIRECTORY}/jcasc_config.yaml"
    fi

    # if a jenkins helm values.yaml exists, replace values there
    if [[ -f "${ARG_FULL_PROJECT_DIRECTORY}/jenkins_helm_values.yaml" ]]; then
        # Jenkins master default URI prefix
        replaceStringInFile "##JENKINS_MASTER_DEFAULT_URI_PREFIX##" "${JENKINS_MASTER_DEFAULT_URI_PREFIX}" "${ARG_FULL_PROJECT_DIRECTORY}/jenkins_helm_values.yaml"
        # Jenkins master label for seed job binding
        replaceStringInFile "##JENKINS_MASTER_DEFAULT_LABEL##" "${JENKINS_MASTER_DEFAULT_LABEL}" "${ARG_FULL_PROJECT_DIRECTORY}/jenkins_helm_values.yaml"
        # Jenkins master access (anonymous read-only or only logged-in)
        replaceStringInFile "##JENKINS_MASTER_DENY_ANONYMOUS_READ_ACCESS##" "${JENKINS_MASTER_DENY_ANONYMOUS_READ_ACCESS}" "${ARG_FULL_PROJECT_DIRECTORY}/jenkins_helm_values.yaml"
        # The default JcasC Configuration file URL
        replaceStringInFile "##JENKINS_JCASC_CONFIGURATION_URL##" "${JENKINS_JCASC_CONFIGURATION_URL}" "${ARG_FULL_PROJECT_DIRECTORY}/jenkins_helm_values.yaml"
        # Replace Jenkins persistence storage class
        replaceStringInFile "##JENKINS_MASTER_PERSISTENCE_STORAGE_CLASS##" "${JENKINS_MASTER_PERSISTENCE_STORAGE_CLASS}" "${ARG_FULL_PROJECT_DIRECTORY}/jenkins_helm_values.yaml"

        # Replace Jenkins persistence access mode
        replaceStringInFile "##JENKINS_MASTER_PERSISTENCE_ACCESS_MODE##" "${JENKINS_MASTER_PERSISTENCE_ACCESS_MODE}" "${ARG_FULL_PROJECT_DIRECTORY}/jenkins_helm_values.yaml"
        # Replace Jenkins persistence storage size
        replaceStringInFile "##JENKINS_MASTER_PERSISTENCE_STORAGE_SIZE##" "${JENKINS_MASTER_PERSISTENCE_STORAGE_SIZE}" "${ARG_FULL_PROJECT_DIRECTORY}/jenkins_helm_values.yaml"
        # replace the container image
        replaceStringInFile "##JENKINS_MASTER_CONTAINER_IMAGE##" "${JENKINS_MASTER_CONTAINER_IMAGE}" "${ARG_FULL_PROJECT_DIRECTORY}/jenkins_helm_values.yaml"
        replaceStringInFile "##JENKINS_MASTER_CONTAINER_IMAGE_TAG##" "${JENKINS_MASTER_CONTAINER_IMAGE_TAG}" "${ARG_FULL_PROJECT_DIRECTORY}/jenkins_helm_values.yaml"
        replaceStringInFile "##JENKINS_MASTER_CONTAINER_PULL_POLICY##" "${JENKINS_MASTER_CONTAINER_PULL_POLICY}" "${ARG_FULL_PROJECT_DIRECTORY}/jenkins_helm_values.yaml"
        replaceStringInFile "##JENKINS_MASTER_CONTAINER_IMAGE_PULL_SECRET_NAME##" "${JENKINS_MASTER_CONTAINER_IMAGE_PULL_SECRET_NAME} " "${ARG_FULL_PROJECT_DIRECTORY}/jenkins_helm_values.yaml"
        # replace Jenkins admin password
        replaceStringInFile "##JENKINS_MASTER_ADMIN_PASSWORD##" "${JENKINS_MASTER_ADMIN_PASSWORD}" "${ARG_FULL_PROJECT_DIRECTORY}/jenkins_helm_values.yaml"
    fi

    # if a persistence volume claim exists, replace values there
    if [[ -f "${ARG_FULL_PROJECT_DIRECTORY}/pvc_claim.yaml" ]]; then
        # Name of the Jenkins deployment
        replaceStringInFile "##JENKINS_MASTER_DEPLOYMENT_NAME##" "${JENKINS_MASTER_DEPLOYMENT_NAME}" "${ARG_FULL_PROJECT_DIRECTORY}/pvc_claim.yaml"
        # Name of the Jenkins deployment
        replaceStringInFile "##JENKINS_MASTER_PERSISTENCE_STORAGE_SIZE##" "${JENKINS_MASTER_PERSISTENCE_STORAGE_SIZE}" "${ARG_FULL_PROJECT_DIRECTORY}/pvc_claim.yaml"
        # Name of the Jenkins deployment
        replaceStringInFile "##JENKINS_MASTER_PERSISTENCE_ACCESS_MODE##" "${JENKINS_MASTER_PERSISTENCE_ACCESS_MODE}" "${ARG_FULL_PROJECT_DIRECTORY}/pvc_claim.yaml"
        # Name of the Jenkins deployment
        replaceStringInFile "##JENKINS_MASTER_PERSISTENCE_STORAGE_CLASS##" "${JENKINS_MASTER_PERSISTENCE_STORAGE_CLASS}" "${ARG_FULL_PROJECT_DIRECTORY}/pvc_claim.yaml"
    fi
}

##########
# Create project directory and copy needed files
#
# argument 1: Path to the project directory
# argument 2: Name of the PVC (optional, if existing pvc should be used)
# argument 3: Is it deployment only? If this arg is set, it does not copy the Jenkins specific things.
##########
function createProjectFromTemplate() {
    # arguments
    local ARG_PROJECT_DIRECTORY=$1
    local ARG_PVC_CLAIM=$2
    local ARG_DEPLOYMENT_ONLY=$3

    # create new project directory
    mkdir -p "${ARG_PROJECT_DIRECTORY}"
    # copy files
    # copy ingress values template
    cp "${TEMPLATES_BASE_DIRECTORY}nginx_ingress_helm_values.yaml" "${ARG_PROJECT_DIRECTORY}/"

    # if it is not a deployment only, copy also the other stuff
    if [[ -z "${ARG_DEPLOYMENT_ONLY}" ]]; then
        ## if project does not use a global secrets file copy it to project directory
        if [[ -z "${GLOBAL_SECRETS_FILE}" ]]; then
            cp "${TEMPLATES_BASE_DIRECTORY}secrets.sh" "${ARG_PROJECT_DIRECTORY}/"
        fi
        # copy Jenkins Helm Chart values.yaml for project configuration
        cp "${TEMPLATES_BASE_DIRECTORY}jenkins_helm_values.yaml" "${ARG_PROJECT_DIRECTORY}/"
        # copy JcasC file to project
        cp "${TEMPLATES_BASE_DIRECTORY}jcasc_config.yaml" "${ARG_PROJECT_DIRECTORY}/"

        if [[ -n "${ARG_PVC_CLAIM}" ]]; then
            cp "${TEMPLATES_BASE_DIRECTORY}pvc_claim.yaml" "${ARG_PROJECT_DIRECTORY}/"
        fi
    fi
}

##########
# Process the cloud template configuration placeholder
#
# argument 1: directory of the project
# argument 2: content of the selected templates
##########
function processTemplatesWithCloudTemplates() {
    # arguments
    local ARG_FULL_PROJECT_DIRECTORY=$1
    local ARG_SELECTED_CLOUD_TEMPLATES=$2

    if [[ -n "${ARG_SELECTED_CLOUD_TEMPLATES}" ]]; then
        echo "${ARG_SELECTED_CLOUD_TEMPLATES}" | while IFS=$'\n' read __INTERNAL_CONTENT_AS_ARRAY; do
            replaceStringInFile "##K8S_MGMT_JENKINS_CLOUD_TEMPLATES##" "          ${__INTERNAL_CONTENT_AS_ARRAY}\n##K8S_MGMT_JENKINS_CLOUD_TEMPLATES##" "${ARG_FULL_PROJECT_DIRECTORY}/jcasc_config.yaml"
        done
    fi
    # replace left template variable with empty comment
    replaceStringInFile "##K8S_MGMT_JENKINS_CLOUD_TEMPLATES##" "          #" "${ARG_FULL_PROJECT_DIRECTORY}/jcasc_config.yaml"
}

##########
# Project wizard delegation method to trigger dialogs and
# execute the resulting actions
#
##########
function projectWizard() {
    # variables
    local VAR_PROJECT_DIRECTORY
    local VAR_NAMESPACE
    local VAR_IP_ADDRESS
    local VAR_CLOUD_TEMPLATES
    local VAR_JENKINS_SYSTEM_MESSAGE
    local VAR_JENKINS_JOB_CONFIGURATION_REPOSITORY
    local VAR_EXISTING_PERSISTENCE_CLAIM

    # first receive the project directory
    dialogAskForProjectDirectory VAR_PROJECT_DIRECTORY

    # try to pre-load some configuration
    ## read the IP address, if global variable 'K8S_MGMT_NAMESPACE' was already set
     if [[ -n "${K8S_MGMT_NAMESPACE}" ]]; then
        readIpForNamespaceFromFile "${K8S_MGMT_NAMESPACE}" VAR_IP_ADDRESS
     fi

    # collect all information from dialogs
    dialogAskForNamespace VAR_NAMESPACE
    dialogAskForIpAddress VAR_IP_ADDRESS "${VAR_NAMESPACE}"
    dialogAskForCloudTemplates VAR_CLOUD_TEMPLATES
    dialogAskForJenkinsSystemMessage VAR_JENKINS_SYSTEM_MESSAGE
    dialogAskForJenkinsJobConfigurationRepository VAR_JENKINS_JOB_CONFIGURATION_REPOSITORY
    dialogAskForExistingPersistenceClaim VAR_EXISTING_PERSISTENCE_CLAIM

    # target directory
    local __INTERNAL_FULL_PROJECT_DIRECTORY="${PROJECTS_BASE_DIRECTORY}${VAR_PROJECT_DIRECTORY}"

    # everything looks fine, lets add the IP address and namespace name to the configuration
    addIpToIpConfiguration "${VAR_IP_ADDRESS}" "${VAR_NAMESPACE}"

    # all data collected -> start create new project
    createProjectFromTemplate "${__INTERNAL_FULL_PROJECT_DIRECTORY}" "${VAR_EXISTING_PERSISTENCE_CLAIM}"

    # start processing the templates
    ## First process the cloud templates, because they contain things, that will be replaced later!
    processTemplatesWithCloudTemplates "${__INTERNAL_FULL_PROJECT_DIRECTORY}" "${VAR_CLOUD_TEMPLATES}"

    ## Jenkins system message should be the first, because it overwrites the message, if a custom message was defined
    processTemplatesWithJenkinsSystemMessage "${__INTERNAL_FULL_PROJECT_DIRECTORY}" "${VAR_JENKINS_SYSTEM_MESSAGE}"
    processTemplatesWithJenkinsJobRepository "${__INTERNAL_FULL_PROJECT_DIRECTORY}" "${VAR_JENKINS_JOB_CONFIGURATION_REPOSITORY}"
    ## second should be the global configuration, because it can contain further templates like project name directory
    processTemplatesWithGlobalConfiguration "${__INTERNAL_FULL_PROJECT_DIRECTORY}"
    ## process all other
    processTemplatesWithNamespace "${__INTERNAL_FULL_PROJECT_DIRECTORY}" "${VAR_NAMESPACE}"
    processTemplatesWithIpAddress "${__INTERNAL_FULL_PROJECT_DIRECTORY}" "${VAR_IP_ADDRESS}"
    processTemplatesWithProjectDirectory "${__INTERNAL_FULL_PROJECT_DIRECTORY}" "${VAR_PROJECT_DIRECTORY}"
    processTemplatesWithPersistenceExistingClaim "${__INTERNAL_FULL_PROJECT_DIRECTORY}" "${VAR_EXISTING_PERSISTENCE_CLAIM}"
}

##########
# Deployment only project wizard delegation method to trigger dialogs and
# execute the resulting actions
#
##########
function createDeploymentOnlyWizard() {
    # variables
    local VAR_PROJECT_DIRECTORY
    local VAR_NAMESPACE
    local VAR_IP_ADDRESS

    # first receive the project directory
    dialogAskForProjectDirectory VAR_PROJECT_DIRECTORY

    # try to pre-load some configuration
    ## read the IP address, if global variable 'K8S_MGMT_NAMESPACE' was already set
     if [[ -n "${K8S_MGMT_NAMESPACE}" ]]; then
        readIpForNamespaceFromFile "${K8S_MGMT_NAMESPACE}" VAR_IP_ADDRESS
     fi

    dialogAskForNamespace VAR_NAMESPACE
    dialogAskForIpAddress VAR_IP_ADDRESS "${VAR_NAMESPACE}"

    # target directory
    local __INTERNAL_FULL_PROJECT_DIRECTORY="${PROJECTS_BASE_DIRECTORY}${VAR_PROJECT_DIRECTORY}"

    # all data collected -> start create new project
    createProjectFromTemplate "${__INTERNAL_FULL_PROJECT_DIRECTORY}" "${VAR_EXISTING_PERSISTENCE_CLAIM}" "true"

    # everything looks fine, lets add the IP address and namespace name to the configuration
    addIpToIpConfiguration "${VAR_IP_ADDRESS}" "${VAR_NAMESPACE}"

    processTemplatesWithNamespace "${__INTERNAL_FULL_PROJECT_DIRECTORY}" "${VAR_NAMESPACE}"
    processTemplatesWithIpAddress "${__INTERNAL_FULL_PROJECT_DIRECTORY}" "${VAR_IP_ADDRESS}"
    processTemplatesWithGlobalConfiguration "${__INTERNAL_FULL_PROJECT_DIRECTORY}"
}