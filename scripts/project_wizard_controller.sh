#!/bin/bash
#########
## DO NOT USE THIS SCRIPT DIRECTLY!
## This script will be loaded by the 'k8s-jcasc.sh' script.

##########
# Process '##PROJECT_NAME## Jenkins in namespace ##NAMESPACE##' placeholder in the new project directory
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
    if [[ ! -z "${ARG_JENKINS_SYSTEM_MESSAGE}" ]]; then
        replaceStringInFile "##PROJECT_NAME## Jenkins in namespace ##NAMESPACE##" "${ARG_JENKINS_SYSTEM_MESSAGE}" ${ARG_FULL_PROJECT_DIRECTORY}/jcasc_config.yaml
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

    replaceStringInFile "##NAMESPACE##" "${ARG_NAMESPACE}" ${ARG_FULL_PROJECT_DIRECTORY}/jcasc_config.yaml
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

    replaceStringInFile "##PUBLIC_IP_ADDRESS##" "${ARG_IP_ADDRESS}" ${ARG_FULL_PROJECT_DIRECTORY}/jcasc_config.yaml
}

##########
# Process '##PROJECT_JENKINS_JOB_DEFINITION_REPOSITORY##' placeholder in the new project directory
#
# argument 1: URL to Jenkins seed job repository
# argument 2: directory of the project
##########
function processTemplatesWithJenkinsJobRepository() {
    # arguments
    local ARG_JENKINS_JOB_REPOSITORY_=$1
    local ARG_FULL_PROJECT_DIRECTORY=$2

    replaceStringInFile "##PROJECT_JENKINS_JOB_DEFINITION_REPOSITORY##" "${ARG_JENKINS_JOB_REPOSITORY_}" ${ARG_FULL_PROJECT_DIRECTORY}/jcasc_config.yaml
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

    replaceStringInFile "##PROJECT_DIRECTORY##" "${ARG_PROJECT_DIRECTORY}" ${ARG_FULL_PROJECT_DIRECTORY}/jcasc_config.yaml
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

    replaceStringInFile "##JENKINS_MASTER_PERSISTENCE_EXISTING_CLAIM##" "${ARG_EXISTING_PERSISTENCE_CLAIM}" ${ARG_FULL_PROJECT_DIRECTORY}/jenkins_helm_values.yaml
}

##########
# Process global configuration placeholder
#
# argument 1: directory of the project
##########
function processTemplatesWithGlobalConfiguration() {
    # arguments
    local ARG_FULL_PROJECT_DIRECTORY=$1

    # Kubernetes server certificate
    replaceStringInFile "##KUBERNETES_SERVER_CERTIFICATE##" "${KUBERNETES_SERVER_CERTIFICATE}" ${ARG_FULL_PROJECT_DIRECTORY}/jcasc_config.yaml
    # Name of the Jenkins deployment
    replaceStringInFile "##JENKINS_MASTER_DEPLOYMENT_NAME##" "${JENKINS_MASTER_DEPLOYMENT_NAME}" ${ARG_FULL_PROJECT_DIRECTORY}/jcasc_config.yaml
    # Docker Registry Credentials ID for Kubernetes
    replaceStringInFile "##KUBERNETES_DOCKER_REGISTRY_CREDENTIALS_ID##" "${KUBERNETES_DOCKER_REGISTRY_CREDENTIALS_ID}" ${ARG_FULL_PROJECT_DIRECTORY}/jcasc_config.yaml
    # Maven Repository Credentials ID
    replaceStringInFile "##MAVEN_REPOSITORY_SECRETS_CREDENTIALS_ID##" "${MAVEN_REPOSITORY_SECRETS_CREDENTIALS_ID}" ${ARG_FULL_PROJECT_DIRECTORY}/jcasc_config.yaml
    # NPM Repository Credentials ID
    replaceStringInFile "##NPM_REPOSITORY_SECRETS_CREDENTIALS_ID##" "${NPM_REPOSITORY_SECRETS_CREDENTIALS_ID}" ${ARG_FULL_PROJECT_DIRECTORY}/jcasc_config.yaml
    # VCS Credentials ID
    replaceStringInFile "##VCS_REPOSITORY_SECRETS_CREDENTIALS_ID##" "${VCS_REPOSITORY_SECRETS_CREDENTIALS_ID}" ${ARG_FULL_PROJECT_DIRECTORY}/jcasc_config.yaml
    # Jenkins master default URI prefix
    replaceStringInFile "##JENKINS_MASTER_DEFAULT_URI_PREFIX##" "${JENKINS_MASTER_DEFAULT_URI_PREFIX}" ${ARG_FULL_PROJECT_DIRECTORY}/jcasc_config.yaml
    replaceStringInFile "##JENKINS_MASTER_DEFAULT_URI_PREFIX##" "${JENKINS_MASTER_DEFAULT_URI_PREFIX}" ${ARG_FULL_PROJECT_DIRECTORY}/jenkins_helm_values.yaml
    # Jenkins master label for seed job binding
    replaceStringInFile "##JENKINS_MASTER_DEFAULT_LABEL##" "${JENKINS_MASTER_DEFAULT_LABEL}" ${ARG_FULL_PROJECT_DIRECTORY}/jcasc_config.yaml
    replaceStringInFile "##JENKINS_MASTER_DEFAULT_LABEL##" "${JENKINS_MASTER_DEFAULT_LABEL}" ${ARG_FULL_PROJECT_DIRECTORY}/jenkins_helm_values.yaml
    # URL to the seed job script repository
    replaceStringInFile "##JENKINS_JOBDSL_SEED_JOB_SCRIPT_URL##" "${JENKINS_JOBDSL_SEED_JOB_SCRIPT_URL}" ${ARG_FULL_PROJECT_DIRECTORY}/jcasc_config.yaml
    # Jenkins master access (anonymous read-only or only logged-in)
    replaceStringInFile "##JENKINS_MASTER_DENY_ANONYMOUS_READ_ACCESS##" "${JENKINS_MASTER_DENY_ANONYMOUS_READ_ACCESS}" ${ARG_FULL_PROJECT_DIRECTORY}/jenkins_helm_values.yaml
    # The default JcasC Configuration file URL
    replaceStringInFile "##JENKINS_JCASC_CONFIGURATION_URL##" "${JENKINS_JCASC_CONFIGURATION_URL}" ${ARG_FULL_PROJECT_DIRECTORY}/jenkins_helm_values.yaml
    # Replace Jenkins persistence storage class
    replaceStringInFile "##JENKINS_MASTER_PERSISTENCE_STORAGE_CLASS##" "${JENKINS_MASTER_PERSISTENCE_STORAGE_CLASS}" ${ARG_FULL_PROJECT_DIRECTORY}/jenkins_helm_values.yaml
    # Replace Jenkins persistence access mode
    replaceStringInFile "##JENKINS_MASTER_PERSISTENCE_ACCESS_MODE##" "${JENKINS_MASTER_PERSISTENCE_ACCESS_MODE}" ${ARG_FULL_PROJECT_DIRECTORY}/jenkins_helm_values.yaml
    # Replace Jenkins persistence storage size
    replaceStringInFile "##JENKINS_MASTER_PERSISTENCE_STORAGE_SIZE##" "${JENKINS_MASTER_PERSISTENCE_STORAGE_SIZE}" ${ARG_FULL_PROJECT_DIRECTORY}/jenkins_helm_values.yaml
    replaceStringInFile "##JENKINS_MASTER_ADMIN_PASSWORD##" "${JENKINS_MASTER_ADMIN_PASSWORD}" ${ARG_FULL_PROJECT_DIRECTORY}/jenkins_helm_values.yaml
}

##########
# Create project directory and copy needed files
#
# argument 1: Path to the project directory
##########
function createProjectFromTemplate() {
    # arguments
    local ARG_PROJECT_DIRECTORY=$1

    # create new project directory
    mkdir -p ${ARG_PROJECT_DIRECTORY}
    # copy files
    ## if project does not use a global secrets file copy it to project directory
    if [[ -z "${GLOBAL_SECRETS_FILE}" ]]; then
        cp templates/secrets.sh ${ARG_PROJECT_DIRECTORY}/
    fi
    # copy Jenkins Helm Chart values.yaml for project configuration
    cp templates/jenkins_helm_values.yaml ${ARG_PROJECT_DIRECTORY}/
    # copy JcasC file to project
    cp templates/jcasc_config.yaml ${ARG_PROJECT_DIRECTORY}/
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
    local VAR_JENKINS_SYSTEM_MESSAGE
    local VAR_JENKINS_JOB_CONFIGURATION_REPOSITORY
    local VAR_EXISTING_PERSISTENCE_CLAIM

    # first receive the project directory
    dialogAskForProjectDirectory VAR_PROJECT_DIRECTORY

    # try to pre-load some configuration
    ## read the IP address, if global variable 'K8S_MGMT_NAMESPACE' was already set
     if [[ ! -z "${K8S_MGMT_NAMESPACE}" ]]; then
        readIpForNamespaceFromFile "${K8S_MGMT_NAMESPACE}" VAR_IP_ADDRESS
     fi

    # collect all information from dialogs
    dialogAskForNamespace VAR_NAMESPACE
    dialogAskForIpAddress VAR_IP_ADDRESS "${VAR_NAMESPACE}"
    dialogAskForJenkinsSystemMessage VAR_JENKINS_SYSTEM_MESSAGE
    dialogAskForJenkinsJobConfigurationRepository VAR_JENKINS_JOB_CONFIGURATION_REPOSITORY
    dialogAskForExistingPersistenceClaim VAR_EXISTING_PERSISTENCE_CLAIM

    # target directory
    local __INTERNAL_FULL_PROJECT_DIRECTORY="${PROJECTS_BASE_DIRECTORY}${VAR_PROJECT_DIRECTORY}"

    # all data collected -> start create new project
    createProjectFromTemplate "${__INTERNAL_FULL_PROJECT_DIRECTORY}"

    # everything looks fine, lets add the IP address and namespace name to the configuration
    addIpToIpConfiguration "${VAR_IP_ADDRESS}" "${VAR_NAMESPACE}"

    # start processing the templates
    ## Jenkins system message should be the first, because it overwrites the message, if a custom message was defined
    processTemplatesWithJenkinsSystemMessage "${__INTERNAL_FULL_PROJECT_DIRECTORY}" "${VAR_JENKINS_SYSTEM_MESSAGE}"
    ## second should be the global configuration, because it can contain further templates like project name directory
    processTemplatesWithGlobalConfiguration "${__INTERNAL_FULL_PROJECT_DIRECTORY}"
    ## process all other
    processTemplatesWithNamespace "${__INTERNAL_FULL_PROJECT_DIRECTORY}" "${VAR_NAMESPACE}"
    processTemplatesWithIpAddress "${__INTERNAL_FULL_PROJECT_DIRECTORY}" "${VAR_IP_ADDRESS}"
    processTemplatesWithProjectDirectory "${__INTERNAL_FULL_PROJECT_DIRECTORY}" "${VAR_PROJECT_DIRECTORY}"
    processTemplatesWithPersistenceExistingClaim "${__INTERNAL_FULL_PROJECT_DIRECTORY}" "${VAR_EXISTING_PERSISTENCE_CLAIM}"
}

