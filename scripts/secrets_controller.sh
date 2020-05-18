#!/bin/bash
#########
## DO NOT USE THIS SCRIPT DIRECTLY!
## This script will be loaded by the 'k8s-jcasc.sh' script.

##########
# Function to encrypt the secrets with openssl
##########
function encryptSecrets() {
    if [[ "${LOG_LEVEL}" != "NONE" ]]; then
        echo ""
        echo "  INFO secrets_controller.sh: Encrypt the secrets..."
        echo ""
    fi

    # resolve secrets file
    local VAR_SECRETS_FILE
    resolveSecretsFile VAR_SECRETS_FILE

    if [[ "${LOG_LEVEL}" == "DEBUG" ]]; then
        echo ""
        echo "  INFO secrets_controller.sh: Secrets file resolved under '${VAR_SECRETS_FILE}'"
        echo ""
    fi

    if [[ "${K8S_MGMT_ENCRYPTION_TOOL}" == "openssl" ]]; then
        openssl enc -e -a -aes-256-cbc -salt -in "${VAR_SECRETS_FILE}" -out "${VAR_SECRETS_FILE}.enc"
    elif [[ "${K8S_MGMT_ENCRYPTION_TOOL}" == "gpg" ]]; then
        gpg -c "${VAR_SECRETS_FILE}"
    fi
    rm "${VAR_SECRETS_FILE}"


    if [[ "${LOG_LEVEL}" != "NONE" ]]; then
        echo ""
        echo "  INFO secrets_controller.sh: Encryption finished..."
        echo ""
    fi
}

##########
# Function to decrypt the secrets with openssl
##########
function decryptSecrets() {
    local VAR_SECRETS_FILE
    resolveSecretsFile VAR_SECRETS_FILE

    if [[ "${K8S_MGMT_ENCRYPTION_TOOL}" == "openssl" ]]; then
        openssl enc -d -a -aes-256-cbc -salt -in "${VAR_SECRETS_FILE}.enc" -out "${VAR_SECRETS_FILE}"
    elif [[ "${K8S_MGMT_ENCRYPTION_TOOL}" == "gpg" ]]; then
        gpg "${VAR_SECRETS_FILE}.gpg"
    fi

}

##########
# Private function to apply the secrets to the namespace
#
# argument 1: namespace to which the secrets should be applied
# argument 2: secrets file which should be applied
##########
function __applySecretsToNamespace() {
    local ARG_NAMESPACE=$1
    local ARG_SECRETS_FILE=$2

    env NAMESPACE="${ARG_NAMESPACE}" sh "${ARG_SECRETS_FILE}"
}

##########
# Function to execute the secrets file
#
# argument 1: namespace to which the secrets should be applied
##########
function applySecrets() {
    local ARG_NAMESPACE=$1
    local VAR_SECRETS_FILE
    resolveSecretsFile VAR_SECRETS_FILE

    # check if namespace is known, that we can apply the secrets.
    if [[ -z "${ARG_NAMESPACE}" ]]; then
        dialogAskForNamespace ARG_NAMESPACE
    fi

    # decrypt the secrets
    decryptSecrets
    # set namespace variable and execute the secrets file to apply the secrets
    __applySecretsToNamespace "${ARG_NAMESPACE}" "${VAR_SECRETS_FILE}"
    # we are done...remove the decrypted secrets.sh file
    rm "${VAR_SECRETS_FILE}"
}

##########
# Function to apply the secrets to every namespace, which is defined in the IP_CONFIG_FILE file.
#
##########
function applyGlobalSecretsToAllNamespaces() {
    if [[ -n "${GLOBAL_SECRETS_FILE}" ]]; then
        # variables
        local VAR_SECRETS_FILE
        resolveSecretsFile VAR_SECRETS_FILE

        # read namespaces from file
        local VAR_NAMESPACE_FROM_IP_FILE
        readNamespacesFromFile VAR_NAMESPACE_FROM_IP_FILE

        local array VAR_NAMESPACE_ARRAY=()
        IFS=',' read -r -a VAR_NAMESPACE_ARRAY <<< "${VAR_NAMESPACE_FROM_IP_FILE}"

        # decrypt the secrets
        decryptSecrets

        # iterate over the namespaces and apply the secrets
        for __NAMESPACE in "${VAR_NAMESPACE_ARRAY[@]}"
        do
            if [[ -n "${__NAMESPACE}" ]]; then
                __applySecretsToNamespace "${__NAMESPACE}" "${VAR_SECRETS_FILE}"
            fi
        done

        # we are done...remove the decrypted secrets.sh file
        rm "${VAR_SECRETS_FILE}"
    else
        echo ""
        echo "  ERROR: This function is only available for globally configured secrets files!"
        echo "  ERROR: To use it, please configure the GLOBAL_SECRETS_FILE variable."
        echo ""
        exit 1
    fi
}

##########
# Function to resolve the path and file for the secrets
#
# argument 1: variable in which the result should be written (return value)
#             The result contains the directory with the name of the file without the .enc extension
# argument 2: optional project directory, if secrets file is not managed in a central place
##########
function resolveSecretsFile() {
    local ARG_RETVAL_SECRET_DIR=$1

    if [[ -z "${GLOBAL_SECRETS_FILE}" ]]; then
        if [[ -z "${K8S_MGMT_PROJECT_DIRECTORY}" ]]; then
            echo ""
            echo "  ERROR secrets_controller.sh: Unable to search for a secrets file!"
            echo "  ERROR secrets_controller.sh: Please configure 'GLOBAL_SECRETS_FILE' or use the '-p' or '--projectdir' option to define the project."
            echo ""
            exit 1
        else
            eval ${ARG_RETVAL_SECRET_DIR}="\${PROJECTS_BASE_DIRECTORY}\${K8S_MGMT_PROJECT_DIRECTORY}/secrets.sh"
        fi
    else
        eval ${ARG_RETVAL_SECRET_DIR}="\${GLOBAL_SECRETS_FILE}"
    fi
}

##########
# Function to create secrets for a user bcrypted
#
# argument 1: the plain password which should be encrypted
# argument 2: variable in which the result should be written (return value)
##########
function encryptUserPasswordForJenkins() {
    local ARG_PLAIN_PASSWORD=$1
    local ARG_RETVAL_ENCRYPTED_PASS=$2

    local _INTERNAL_ENCRYPTED_JENKINS_USER_PASSWORD=$(htpasswd -nbBC 10 MYPASS "${ARG_PLAIN_PASSWORD}" | sed -e 's/MYPASS\://')
    eval ${ARG_RETVAL_ENCRYPTED_PASS}="\${_INTERNAL_ENCRYPTED_JENKINS_USER_PASSWORD}"
}