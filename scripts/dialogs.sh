#!/bin/bash
#########
## DO NOT USE THIS SCRIPT DIRECTLY!
## This script will be loaded by the 'k8s-jcasc.sh' script.

##########
# If a command was not already set, this function asks for the command
#
function selectInstallationTypeDialog() {
    if [[ -z "${K8S_MGMT_COMMAND}" ]]; then
        echo "Please select the command you want to execute:"
        select WIZARD in "install" "uninstall" "upgrade" "encryptSecrets" "decryptSecrets" "applySecrets" "applySecretsToAll" "createProject" "createDeploymentOnlyProject" "createJenkinsUserPassword" "quit"; do
            case $WIZARD in
                install) setCommandToInstall; break;;
                uninstall) setCommandToUnInstall; break;;
                upgrade) setCommandToUpgrade; break;;
                encryptSecrets) setCommandToSecretsEncrypt; break;;
                decryptSecrets) setCommandToSecretDecrypt; break;;
                applySecrets) setCommandToSecretsApply; break;;
                applySecretsToAll) setCommandToSecretsApplyToAllNamespaces; break;;
                createProject) setCommandToCreateProject; break;;
                createDeploymentOnlyProject) setCommandToCreateDeploymentOnlyProject; break;;
                createJenkinsUserPassword) setCommandToCreateJenkinsUserPassword; break;;
                quit) exit 0; break;;
            esac
        done
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
        echo "Please enter the deployment name."
        read -p "Deployment name: " __INTERNAL_DEPLOYMENT_NAME
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
# argument 2: true=show directory selection | false/na=input (unsupported without dialog/whiptail)
##########
function dialogAskForProjectDirectory() {
    # arguments
    local ARG_RETVALUE=$1
    # unsupported for default dialog
    local ARG_USE_DIALOG=$2

    # first check, if global project directory variable was not set
    local __INTERNAL_PROJECT_DIRECTORY
    if [[ -z "${K8S_MGMT_PROJECT_DIRECTORY}" ]]; then
        # get data from user
        echo "Please enter the target project directory."
        read -p "Directory: " __INTERNAL_PROJECT_DIRECTORY
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
        echo "Please enter the namespace for your installation."
        if [[ -n "${K8S_MGMT_PROJECT_DIRECTORY}" ]]; then
            echo "Press <return> if you want to use the directory name as namespace (${K8S_MGMT_PROJECT_DIRECTORY})"
        fi
        read -p "Namespace: " __INTERNAL_NAMESPACE

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
    if [[ -n "${__INTERNAL_IP_ADDRESS_BY_NAMESPACE}" ]]; then
        K8S_MGMT_IP_ADDRESS="${__INTERNAL_IP_ADDRESS_BY_NAMESPACE}"
    fi

    # first check, if global IP variable was not set
    local __INTERNAL_IP_ADDRESS_VALID
    if [[ -z "${K8S_MGMT_IP_ADDRESS}" ]]; then
        # get data from user
        echo "Please enter the loadbalancer IP for your installation."
        read -p "IP address: " __INTERNAL_IP_ADDRESS

        # validate
        validateIpAddress "${__INTERNAL_IP_ADDRESS}" __INTERNAL_IP_ADDRESS_VALID
        # if IP address was invalid ask again, else return IP
        if [[ "${__INTERNAL_IP_ADDRESS_VALID}" == "false" ]]; then
            local __INTERNAL_IP_ADDRESS_DUMMY
            dialogAskForIpAddress __INTERNAL_IP_ADDRESS_DUMMY ARG_NAMESPACE
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
    local __INTERNAL_JENKINS_SYSMSG
    echo "Please enter the Jenkins system message or leave empty for default (can be changed later in the JCasC file)."
    read -p "System message: " __INTERNAL_JENKINS_SYSMSG

    eval ${ARG_RETVALUE}="\${__INTERNAL_JENKINS_SYSMSG}"
}

##########
# Ask for Jenkins cloud templates if they exist.
# If user is selecting file(s), the method returns the content.
#
# argument 1: variable in which the result should be written (return value)
##########
function dialogAskForCloudTemplates() {
    # arguments
    local ARG_RETVALUE=$1
    local __INTERNAL_CLOUD_TEMPLATES_SELECTION
    local __INTERNAL_CLOUD_TEMPLATES_FOUND
    findJenkinsCloudTemplates __INTERNAL_CLOUD_TEMPLATES_FOUND

    # check if cloud templates were found
    if [[ -n "${__INTERNAL_CLOUD_TEMPLATES_FOUND}" ]]; then
        # prepare them for dialogs
        for __CLOUD_TMPLP_IDX in "${!__INTERNAL_CLOUD_TEMPLATES_FOUND[@]}"
        do
            echo "$((__CLOUD_TMPLP_IDX+1)) - ${__INTERNAL_CLOUD_TEMPLATES_FOUND[__CLOUD_TMPLP_IDX]}"
        done

        # ask user for templates
        echo "Enter the number(s) of the cloud templates you want to use. To select multiple templates, separate them with comma (,). Leave empty if you do not want to add a template."
        read -p "Templates: " __INTERNAL_CLOUD_TEMPLATES_USER_ENTRIES
        if [[ -n "${__INTERNAL_CLOUD_TEMPLATES_USER_ENTRIES}" ]]; then
            __INTERNAL_CLOUD_TEMPLATES_USER_ENTRIES_ARR=(${__INTERNAL_CLOUD_TEMPLATES_USER_ENTRIES//,/ })
            __INTERNAL_CLOUD_TEMPLATES_SELECTION=()
            for __INTERNAL_CLOUD_TEMPLATES_USER_SELECT_IDX in "${__INTERNAL_CLOUD_TEMPLATES_USER_ENTRIES_ARR[@]}"
            do
                __INTERNAL_CLOUD_TEMPLATES_SELECTION=("${__INTERNAL_CLOUD_TEMPLATES_SELECTION[@]}" "${__INTERNAL_CLOUD_TEMPLATES_FOUND[$((__INTERNAL_CLOUD_TEMPLATES_USER_ENTRIES_ARR-1))]}" )
            done
        fi

        # read content of selected templates
        __INTERNAL_JENKINS_CLOUD_CONTENT=$(readSelectedCloudTemplates "${__INTERNAL_CLOUD_TEMPLATES_SELECTION[@]}")
    fi

    eval ${ARG_RETVALUE}="\${__INTERNAL_JENKINS_CLOUD_CONTENT}"
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
    local __INTERNAL_EXISTING_PERSISTENCE_CLAIM
    echo "Enter an existing claim, that should be reused or leave empty for no persistence claim. You can change it later in the jenkins_helm_values.yaml file."
    read -p "Existing claim: " __INTERNAL_EXISTING_PERSISTENCE_CLAIM

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
    if [[ -z "${JENKINS_JOBDSL_BASE_URL}" ]]; then
        echo "Please enter the URL to the job configuration repository"
    else
        echo "Please enter the URL or URI to the job configuration repository (URI must be the part after '${JENKINS_JOBDSL_BASE_URL}')"
    fi
    # get data from user
    read -p "JobDSL file URL: " __INTERNAL_JENKINS_JOB_REPO

    # validate entry if pattern was there
    if [[ -n "${JENKINS_JOBDSL_REPO_VALIDATE_PATTERN}" ]]; then
        if [[ ! "${__INTERNAL_JENKINS_JOB_REPO}" =~ ${JENKINS_JOBDSL_REPO_VALIDATE_PATTERN} ]]; then
            echo "ERROR dialogs.sh: The Jenkins job configuration repository has a wrong syntax."
            echo "ERROR dialogs.sh: It must match the pattern: '${JENKINS_JOBDSL_REPO_VALIDATE_PATTERN}'"
            echo ""
            local __INTERNAL_RECURSIVE_JOB_REPO_DUMMY
            dialogAskForJenkinsJobConfigurationRepository __INTERNAL_RECURSIVE_JOB_REPO_DUMMY
        fi
    fi

    ## generate the final result
    if [[ -n "${JENKINS_JOBDSL_BASE_URL}" ]]; then
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

##########
# Ask for user password and encrypt it for Jenkins.
#
##########
function dialogAskForPassword() {
    if [[ -x "$(command -v htpasswd)" ]]; then
        # get data from user
        local __INTERNAL_USER_PASSWORD
        echo "Please enter the plaintext password for the user."
        read -p "Plaintext password: " __INTERNAL_USER_PASSWORD

        local _INTERNAL_ENCRYPTED_PASS
        encryptUserPasswordForJenkins "${__INTERNAL_USER_PASSWORD}" _INTERNAL_ENCRYPTED_PASS
        echo "Encrypted password: ${_INTERNAL_ENCRYPTED_PASS}"
    else
        echo "ERROR: you need to have 'htpasswd' installed to create a password."
        echo "ERROR: you can also use this site for password creation: https://www.devglan.com/online-tools/bcrypt-hash-generator"
    fi
}
