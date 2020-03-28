#!/bin/bash
#########
## DO NOT USE THIS SCRIPT DIRECTLY!
## This script will be loaded by the 'k8s-jcasc.sh' script.
## The following check ensures, that everything was correct to use this script
if [[ -z "${PROJECTS_DIRECTORY}" ]]; then
    echo "ERROR secrets_controller.sh: Configuration file was not read correctly. Could not find the 'PROJECTS_DIRECTORY' variable."
    echo "ERROR secrets_controller.sh: Please do not use this file directly and check your configuration under 'config/k8s_jcasc_mgmt.cnf'."
    echo ""
    exit 1
fi

##########
# Function to encrypt the secrets with openssl
##########
function encryptSecrets() {
    if [[ "${LOG_LEVEL}" != "NONE" ]]; then
        echo "INFO secrets_controller.sh: Encrypt the secrets..."
    fi
    local SECRETS_FILE
    resolveSecretsFile SECRETS_FILE

    if [[ "${LOG_LEVEL}" == "DEBUG" ]]; then
        echo "INFO secrets_controller.sh: Secrets file resolved under '${SECRETS_FILE}'"
    fi

    openssl aes-256-cbc -a -salt -in ${SECRETS_FILE} -out ${SECRETS_FILE}.enc
    rm ${SECRETS_FILE}


    if [[ "${LOG_LEVEL}" != "NONE" ]]; then
        echo "INFO secrets_controller.sh: Encryption finished..."
    fi
}

##########
# Function to decrypt the secrets with openssl
##########
function decryptSecrets() {
    local SECRETS_FILE
    resolveSecretsFile SECRETS_FILE

    openssl aes-256-cbc -d -a -in ${SECRETS_FILE}.enc -out ${SECRETS_FILE}
}

##########
# Function to execute the secrets file
#
# argument 1: namespace to which the secrets should be applied
##########
function applySecrets() {
    local ARG_NAMESPACE=$1
    local SECRETS_FILE
    resolveSecretsFile SECRETS_FILE

    # check if namespace is known, that we can apply the secrets.
    if [[ -z "${ARG_NAMESPACE}" ]]; then
        read -p "Which is the target namespace name? " ARG_NAMESPACE
        applySecrets "${ARG_NAMESPACE}"
    fi

    # decrypt the secrets
    decryptSecrets
    # set namespace variable and execute the secrets file to apply the secrets
    echo "env NAMESPACE=${ARG_NAMESPACE} sh ${SECRETS_FILE}"
    rm ${SECRETS_FILE}
}

##########
# Function to resolve the path and file for the secrets
#
# argument 1: variable in which the result should be written (return value)
#             The result contains the directory with the name of the file without the .enc extension
##########
function resolveSecretsFile() {
    local ARG_RETVAL_SECRET_DIR=$1

    if [[ -z "${GLOBAL_SECRETS_FILE}" ]]; then
        if [[ -z "${PROJECT_NAME}" ]]; then
            echo "ERROR secrets_controller.sh: Unable to search for a secrets file!"
            echo "ERROR secrets_controller.sh: Please configure 'GLOBAL_SECRETS_FILE' or use the '-p' or '--projectdir' option to define the project."
            echo ""
            exit 1
        else
            eval ${ARG_RETVAL_SECRET_DIR}="${PROJECTS_DIRECTORY}${PROJECT_NAME}/"
        fi
    else
        eval ${ARG_RETVAL_SECRET_DIR}="${GLOBAL_SECRETS_FILE}"
    fi
}