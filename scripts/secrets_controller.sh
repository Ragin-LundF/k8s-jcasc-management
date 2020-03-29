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

    openssl enc -e -a -aes-256-cbc -pbkdf2 -salt -in ${VAR_SECRETS_FILE} -out ${VAR_SECRETS_FILE}.enc
    rm ${VAR_SECRETS_FILE}


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

    openssl enc -d -a -aes-256-cbc -pbkdf2 -salt -in ${VAR_SECRETS_FILE}.enc -out ${VAR_SECRETS_FILE}
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
        read -p "Which is the target namespace name? " ARG_NAMESPACE
        applySecrets "${ARG_NAMESPACE}"
    fi

    # decrypt the secrets
    decryptSecrets
    # set namespace variable and execute the secrets file to apply the secrets
    env NAMESPACE=${ARG_NAMESPACE} sh ${VAR_SECRETS_FILE}
    rm ${VAR_SECRETS_FILE}
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