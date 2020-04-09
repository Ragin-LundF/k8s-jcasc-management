#!/bin/bash
#########
## DO NOT USE THIS SCRIPT DIRECTLY!
## This script will be loaded by the 'k8s-jcasc.sh' script.

##########
# If a command was not already set, this function asks for the command
#
function selectInstallationTypeDialog() {
    if [[ -z "${K8S_MGMT_COMMAND}" ]]; then
        echo "Dialog"
        local WIZARD=`dialog --backtitle "Main menu" --title "Main menu" --nocancel --clear --menu "Please select the command you want to execute" 0 0 0 "install" "" "uninstall" "" "upgrade" "" "encryptSecrets" "" "decryptSecrets" "" "applySecrets" "" "applySecretsToAll" "" "createProject" "" "quit" "" 3>&1 1>&2 2>&3`
        case "${WIZARD}" in
            install) setCommandToInstall; break;;
            uninstall) setCommandToUnInstall; break;;
            upgrade) setCommandToUpgrade; break;;
            encryptSecrets) setCommandToSecretsEncrypt; break;;
            decryptSecrets) setCommandToSecretDecrypt; break;;
            applySecrets) setCommandToSecretsApply; break;;
            applySecretsToAll) setCommandToSecretsApplyToAllNamespaces; break;;
            createProject) setCommandToCreateProject; break;;
            quit) exit 0; break;;
        esac
    fi
}

##########
# Ask for deployment name if it was not already set.
#
# argument 1: variable in which the result should be written (return value)
##########
function dialogAskForDeploymentName() {
    # arguments
    local ARG_RETVALUE=$1

    # first check, if global deployment name variable was not set
    local __INTERNAL_DEPLOYMENT_NAME
    if [[ -z "${JENKINS_MASTER_DEPLOYMENT_NAME}" ]]; then
        # get data from user
        __INTERNAL_DEPLOYMENT_NAME=`dialog --backtitle "Deployment name" --title "Deployment name" --clear --nocancel --inputbox "Please enter the deployment name" 0 0 3>&1 1>&2 2>&3`
        # set the deployment name as default
        JENKINS_MASTER_DEPLOYMENT_NAME="${__INTERNAL_DEPLOYMENT_NAME}"
    else
        __INTERNAL_DEPLOYMENT_NAME="${JENKINS_MASTER_DEPLOYMENT_NAME}"
    fi

    eval ${ARG_RETVALUE}="\${__INTERNAL_DEPLOYMENT_NAME}"
}

##########
# Ask for Project directory if it was not already set.
#
# argument 1: variable in which the result should be written (return value)
##########
function dialogAskForProjectDirectory() {
    # arguments
    local ARG_RETVALUE=$1

    # first check, if global project directory variable was not set
    local __INTERNAL_PROJECT_DIRECTORY
    if [[ -z "${K8S_MGMT_PROJECT_DIRECTORY}" ]]; then
        # get data from user
        __INTERNAL_PROJECT_DIRECTORY=`dialog --backtitle "Project directory selection" --title "Project directory selection"  --clear --nocancel --inputbox "Please enter the target project directory." 0 0 3>&1 1>&2 2>&3`
        # set the directory as default directory
        K8S_MGMT_PROJECT_DIRECTORY="${__INTERNAL_PROJECT_DIRECTORY}"
    else
        __INTERNAL_PROJECT_DIRECTORY="${K8S_MGMT_PROJECT_DIRECTORY}"
    fi

    eval ${ARG_RETVALUE}="\${__INTERNAL_PROJECT_DIRECTORY}"
}

##########
# Ask for namespace, if global K8S mgmt namespace variable was not set.
# If the namespace is wrong the dialog calls itself again until the user
# enters a valid name
#
# argument 1: variable in which the result should be written (return value)
##########
function dialogAskForNamespace() {
    # arguments
    local ARG_RETVALUE=$1

    # first check, if global namespace variable was not set
    local __INTERNAL_NAMESPACE_VALID
    if [[ -z "${K8S_MGMT_NAMESPACE}" ]]; then
        # get data from user
        __INTERNAL_NAMESPACE=`dialog --backtitle "Enter namespace" --title "Enter namespace"  --clear --nocancel --inputbox "Please enter the target namespace." 0 0 "${K8S_MGMT_PROJECT_DIRECTORY}" 3>&1 1>&2 2>&3`

        # check namespace and if it was empty and the directory set, then set namespace=directory
        if [[ -z "${__INTERNAL_NAMESPACE}" && -n "${K8S_MGMT_PROJECT_DIRECTORY}" ]]; then
            __INTERNAL_NAMESPACE=${K8S_MGMT_PROJECT_DIRECTORY}
        fi

        # validate
        validateNamespace "${__INTERNAL_NAMESPACE}" __INTERNAL_NAMESPACE_VALID
        # if namespace was invalid ask again, else return namespace
        if [[ "${__INTERNAL_NAMESPACE_VALID}" == "false" ]]; then
            local __INTERNAL_NAMESPACE_RECURSIVE_DUMMY
            dialogAskForNamespace __INTERNAL_NAMESPACE_RECURSIVE_DUMMY
        fi
        # set namespace as default
        K8S_MGMT_NAMESPACE="${__INTERNAL_NAMESPACE}"
    else
        __INTERNAL_NAMESPACE="${K8S_MGMT_NAMESPACE}"
    fi
    eval ${ARG_RETVALUE}="\${__INTERNAL_NAMESPACE}"
}

##########
# Ask for IP address, if global K8S mgmt IP variable was not set.
# If the IP address is wrong the dialog calls itself again until the user
# enters a valid IP
#
# argument 1: variable in which the result should be written (return value)
# argument 2: namespace as optional argument, to search for IP with namespace
##########
function dialogAskForIpAddress() {
    # arguments
    local ARG_RETVALUE=$1
    local ARG_NAMESPACE=$2

    # if a namespace was give, try to resolve IP by namespace name
    local __INTERNAL_IP_ADDRESS_BY_NAMESPACE
    readIpForNamespaceFromFile "${ARG_NAMESPACE}" __INTERNAL_IP_ADDRESS_BY_NAMESPACE
    if [[ ! -z "${__INTERNAL_IP_ADDRESS_BY_NAMESPACE}" ]]; then
        K8S_MGMT_IP_ADDRESS="${__INTERNAL_IP_ADDRESS_BY_NAMESPACE}"
    fi

    # first check, if global IP variable was not set
    local __INTERNAL_IP_ADDRESS_VALID
    if [[ -z "${K8S_MGMT_IP_ADDRESS}" ]]; then
        # get data from user
        __INTERNAL_IP_ADDRESS=`dialog --backtitle "Enter IP address" --title "Enter IP address" --clear --nocancel --inputbox "Please enter the loadbalancer IP for your installation." 0 0 3>&1 1>&2 2>&3`

        # validate
        validateIpAddress "${__INTERNAL_IP_ADDRESS}" __INTERNAL_IP_ADDRESS_VALID
        # if IP address was invalid ask again, else return IP
        if [[ "${__INTERNAL_IP_ADDRESS_VALID}" == "false" ]]; then
            local __INTERNAL_IP_ADDRESS_DUMMY
            dialogAskForIpAddress __INTERNAL_IP_ADDRESS_DUMMY
        fi
    else
        __INTERNAL_IP_ADDRESS="${K8S_MGMT_IP_ADDRESS}"
    fi
    eval ${ARG_RETVALUE}="\${__INTERNAL_IP_ADDRESS}"
}

##########
# Ask for Jenkins system message.
#
# argument 1: variable in which the result should be written (return value)
##########
function dialogAskForJenkinsSystemMessage() {
    # arguments
    local ARG_RETVALUE=$1

    # get data from user
    local __INTERNAL_JENKINS_SYSMSG=`dialog --backtitle "Jenkins system message" --title "Jenkins system message" --clear --nocancel --inputbox "Please enter the Jenkins system message or leave empty for default (can be changed later in the JCasC file)." 0 0 3>&1 1>&2 2>&3`

    eval ${ARG_RETVALUE}="\${__INTERNAL_JENKINS_SYSMSG}"
}

##########
# Ask for existing persistence claim.
#
# argument 1: variable in which the result should be written (return value)
##########
function dialogAskForExistingPersistenceClaim() {
    # arguments
    local ARG_RETVALUE=$1

    # get data from user
    local __INTERNAL_EXISTING_PERSISTENCE_CLAIM=`dialog --backtitle "Existing persistent volume claim" --title "Existing persistent volume claim" --clear --nocancel --inputbox "Enter an existing claim, that should be reused or leave empty for no persistence claim. You can change it later in the jenkins_helm_values.yaml file." 0 0 3>&1 1>&2 2>&3`

    eval ${ARG_RETVALUE}="\${__INTERNAL_EXISTING_PERSISTENCE_CLAIM}"
}

##########
# Ask for Jenkins job configuration repository.
#
# argument 1: variable in which the result should be written (return value)
##########
function dialogAskForJenkinsJobConfigurationRepository() {
    # arguments
    local ARG_RETVALUE=$1

    # generate the message
    local __INTERNAL_MSG_JOBDSL_BASE_TXT
    if [[ -z "${JENKINS_JOBDSL_BASE_URL}" ]]; then
        __INTERNAL_MSG_JOBDSL_BASE_TXT="Please enter the URL to the job configuration repository"
    else
        __INTERNAL_MSG_JOBDSL_BASE_TXT="Please enter the URL or URI to the job configuration repository (URI must be the part after '${JENKINS_JOBDSL_BASE_URL}')"
    fi
    # get data from user
    __INTERNAL_JENKINS_JOB_REPO=`dialog --backtitle "JobDSL configuration repository" --title "JobDSL configuration repository" --clear --nocancel --inputbox "${__INTERNAL_MSG_JOBDSL_BASE_TXT}" 0 0 3>&1 1>&2 2>&3`

    # validate entry if pattern was there
    if [[ ! -z "${JENKINS_JOBDSL_REPO_VALIDATE_PATTERN}" ]]; then
        if [[ ! "${__INTERNAL_JENKINS_JOB_REPO}" =~ ${JENKINS_JOBDSL_REPO_VALIDATE_PATTERN} ]]; then
            echo "ERROR dialogs.sh: The Jenkins job configuration repository has a wrong syntax."
            echo "ERROR dialogs.sh: It must match the pattern: '${JENKINS_JOBDSL_REPO_VALIDATE_PATTERN}'"
            echo ""
            local __INTERNAL_RECURSIVE_JOB_REPO_DUMMY
            dialogAskForJenkinsJobConfigurationRepository __INTERNAL_RECURSIVE_JOB_REPO_DUMMY
        fi
    fi

    ## generate the final result
    if [[ ! -z "${JENKINS_JOBDSL_BASE_URL}" ]]; then
        # if JENKINS_JOBDSL_BASE_URL was defined, check if there is something with "://" (ssh/http/https...)
        if [[ "${__INTERNAL_JENKINS_JOB_REPO}" != *"://"* ]]; then
            # add a slash if base url does not end with slash and new repo does not start with slash
            if [[ "${JENKINS_JOBDSL_BASE_URL}" != *"/" && "${__INTERNAL_JENKINS_JOB_REPO}" != "/"* ]]; then
                __INTERNAL_JENKINS_JOB_REPO="/${__INTERNAL_JENKINS_JOB_REPO}"
            fi
            # should be no URL, so add the base url
            __INTERNAL_JENKINS_JOB_REPO="${JENKINS_JOBDSL_BASE_URL}${__INTERNAL_JENKINS_JOB_REPO}"
        fi
    fi
    eval ${ARG_RETVALUE}="\${__INTERNAL_JENKINS_JOB_REPO}"
}
