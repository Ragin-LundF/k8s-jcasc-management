#!/bin/bash
#########
## DO NOT USE THIS SCRIPT DIRECTLY!
## This script will be loaded by the 'k8s-jcasc.sh' script.

function projectWizardNamespaceHandler() {
    # arguments
    local ARG_RETVALUE=$1

    local __INTERNAL_NAMESPACE
    dialogAskForNamespace __INTERNAL_NAMESPACE

    eval ${ARG_RETVALUE}="\${__INTERNAL_NAMESPACE}"
}

function projectWizardIpAddressHandler() {
    # arguments
    local ARG_RETVALUE=$1

    local __INTERNAL_IP_ADDRESS
    dialogAskForIpAddress __INTERNAL_IP_ADDRESS

    eval ${ARG_RETVALUE}="\${__INTERNAL_IP_ADDRESS}"
}

function projectWizardJenkinsSystemMessageHandler() {
    # arguments
    local ARG_RETVALUE=$1

    local __INTERNAL_JENKINS_SYSTEM_MESSAGE
    dialogAskForJenkinsSystemMessage __INTERNAL_JENKINS_SYSTEM_MESSAGE

    eval ${ARG_RETVALUE}="\${__INTERNAL_JENKINS_SYSTEM_MESSAGE}"
}

function projectWizardJenkinsJobRepositoryHandler() {
    # arguments
    local ARG_RETVALUE=$1

    local __INTERNAL_JENKINS_JOB_REPOSITORY
    dialogAskForJenkinsJobConfigurationRepository __INTERNAL_JENKINS_JOB_REPOSITORY

    eval ${ARG_RETVALUE}="\${__INTERNAL_JENKINS_JOB_REPOSITORY}"
}

function createProjectFromTemplate() {
    # arguments
    local ARG_PROJECT_NAME=$1

    # variables
    local VAR_PROJECT_DIRECTORY="${PROJECTS_BASE_DIRECTORY}${ARG_PROJECT_NAME}"

    # create new project directory
    mkdir -p ${VAR_PROJECT_DIRECTORY}
    # copy files
    ## if project does not use a global secrets file copy it to project directory
    if [[ -z "${GLOBAL_SECRETS_FILE}" ]]; then
        cp templates/secrets.sh ${VAR_PROJECT_DIRECTORY}/
    fi
    # copy Jenkins Helm Chart values.yaml for project configuration
    cp templates/jenkins_helm_values.yaml ${VAR_PROJECT_DIRECTORY}/
}

function projectWizard() {
    # variables
    local VAR_NAMESPACE
    local VAR_IP_ADDRESS
    local VAR_JENKINS_SYSTEM_MESSAGE
    local VAR_JENKINS_JOB_CONFIGURATION_REPOSITORY

    # try to pre-load some configuration
    ## read the IP address, if global variable 'K8S_MGMT_NAMESPACE' was already set
     if [[ ! -z "${K8S_MGMT_NAMESPACE}" ]]; then
        readIpForNamespaceFromFile "${K8S_MGMT_NAMESPACE}" VAR_IP_ADDRESS
     fi

    # collect all information from dialogs
    projectWizardNamespaceHandler VAR_NAMESPACE
    projectWizardIpAddressHandler VAR_IP_ADDRESS
    projectWizardJenkinsSystemMessageHandler VAR_JENKINS_SYSTEM_MESSAGE
    projectWizardJenkinsJobRepositoryHandler VAR_JENKINS_JOB_CONFIGURATION_REPOSITORY

    # all data collected -> start create new project
    if [[ -z "${PROJECT_DIRECTORY}" ]]; then
        createProjectFromTemplate "${PROJECT_DIRECTORY}"
    fi
}

