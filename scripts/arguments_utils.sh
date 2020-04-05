#!/bin/bash
#########
## DO NOT USE THIS SCRIPT DIRECTLY!
## This script will be loaded by the 'k8s-jcasc.sh' script.

##########
# Global command variables
_K8S_MGMT_COMMAND_INSTALL="INSTALL"
_K8S_MGMT_COMMAND_UPGRADE="UPGRADE"
_K8S_MGMT_COMMAND_UNINSTALL="UNINSTALL"
_K8S_MGMT_COMMAND_SECRETS_ENCRYPT="SECRETS_ENCRYPT"
_K8S_MGMT_COMMAND_SECRETS_DECRYPT="SECRETS_DECRYPT"
_K8S_MGMT_COMMAND_SECRETS_APPLY="SECRETS_APPLY"
_K8S_MGMT_COMMAND_SECRETS_APPLY_TO_ALL_NAMESPACES="SECRETS_APPLY_ALL_NAMESPACES"
_K8S_MGMT_COMMAND_CREATE_PROJECT="CREATE_PROJECT"

##########
# Functions to set the K8S_MGMT_COMMAND.
function setCommandToInstall() {
    K8S_MGMT_COMMAND="${_K8S_MGMT_COMMAND_INSTALL}"
}
function setCommandToUnInstall() {
    K8S_MGMT_COMMAND="${_K8S_MGMT_COMMAND_UNINSTALL}"
}
function setCommandToUpgrade() {
    K8S_MGMT_COMMAND="${_K8S_MGMT_COMMAND_UPGRADE}"
}
function setCommandToSecretsEncrypt() {
    K8S_MGMT_COMMAND="${_K8S_MGMT_COMMAND_SECRETS_ENCRYPT}"
}
function setCommandToSecretDecrypt() {
    K8S_MGMT_COMMAND="${_K8S_MGMT_COMMAND_SECRETS_DECRYPT}"
}
function setCommandToSecretsApply() {
    K8S_MGMT_COMMAND="${_K8S_MGMT_COMMAND_SECRETS_APPLY}"
}
function setCommandToSecretsApplyToAllNamespaces() {
    K8S_MGMT_COMMAND="${_K8S_MGMT_COMMAND_SECRETS_APPLY_TO_ALL_NAMESPACES}"
}
function setCommandToCreateProject() {
    K8S_MGMT_COMMAND="${_K8S_MGMT_COMMAND_CREATE_PROJECT}"
}

##########
# If a command was not already set, this function asks for the command
#
function selectInstallationType() {
    if [[ -z "${K8S_MGMT_COMMAND}" ]]; then
        echo "Please select the command you want to execute:"
            select WIZARD in "install" "uninstall" "upgrade" "encryptSecrets" "decryptSecrets" "applySecrets" "applySecretsToAll" "createProject" "quit"; do
                case $WIZARD in
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
            done
    fi
}

##########
# Process arguments and set defaults
#
function processArguments() {
    # check arguments
    for i in "$@"
    do
        case ${i} in
            ## options
            # directory, where the project configuration is located
            -p=*|--projectdir=*)
                K8S_MGMT_PROJECT_DIRECTORY="${i#*=}"
                shift # past argument=value
            ;;
            # name of the namespace
            -n=*|--namespace=*)
                K8S_MGMT_NAMESPACE="${i#*=}"
                shift # past argument=value
            ;;
            # name of the deployment
            -d=*|--deploymentname=*)
                JENKINS_MASTER_DEPLOYMENT_NAME="${i#*=}"
                shift # past argument=value
            ;;

            ## arguments
            # install Jenkins
            install)
                setCommandToInstall
                shift # past argument=value
            ;;
            # uninstall Jenkins
            uninstall)
                setCommandToUnInstall
                shift # past argument=value
            ;;
            # upgrade Jenkins installation
            upgrade)
                setCommandToUpgrade
                shift # past argument=value
            ;;
            # encrypt the secrets
            encryptsecrets)
                setCommandToSecretsEncrypt
                shift # past argument=value
            ;;
            # decrypt the secrets
            decryptsecrets)
                setCommandToSecretDecrypt
                shift # past argument=value
            ;;
            # apply secrets to kubernetes
            applysecrets)
                setCommandToSecretsApply
                shift # past argument=value
            ;;
            # apply secrets to kubernetes
            applysecretstoallnamespaces)
                setCommandToSecretsApplyToAllNamespaces
                shift # past argument=value
            ;;
            # create new project
            createproject)
                setCommandToCreateProject
                shift # past argument=value
            ;;
            *)
                # unknown option
            ;;
        esac
    done

    selectInstallationType
}