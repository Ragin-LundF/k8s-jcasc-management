#!/bin/bash

# read configuration
source ./config/k8s_jcasc_mgmt.cnf

# import subscripts (take care with order!)
source ./scripts/arguments_utils.sh
source ./scripts/cleanup_k8s_utils.sh
source ./scripts/dialogs.sh
source ./scripts/ipconfig_utils.sh
source ./scripts/install_controller.sh
source ./scripts/project_wizard_controller.sh
source ./scripts/secrets_controller.sh
source ./scripts/sed_utils.sh
source ./scripts/validator_utils.sh

# start the script
processArguments $@

# validate, that command exists and nothing went wrong
if [[ -z "${K8S_MGMT_COMMAND}" ]]; then
    echo ""
    echo "  Something went wrong. Was not able to find a valid command."
    echo ""
    exit 1
fi

##########
# Delegate the command to the right actions
#
function run() {
    # delegate command to methods
    if [[ "${_K8S_MGMT_COMMAND_CREATE_PROJECT}" == "${K8S_MGMT_COMMAND}" ]]; then
        ## Create new project
        projectWizard
    elif [[ "${_K8S_MGMT_COMMAND_SECRETS_ENCRYPT}" == "${K8S_MGMT_COMMAND}" ]]; then
        ## encrypt secrets
        encryptSecrets
    elif [[ "${_K8S_MGMT_COMMAND_SECRETS_DECRYPT}" == "${K8S_MGMT_COMMAND}" ]]; then
        ## decrypt secrets
        decryptSecrets
    elif [[ "${_K8S_MGMT_COMMAND_SECRETS_APPLY}" == "${K8S_MGMT_COMMAND}" ]]; then
        ## apply secrets
        # resolve namespace from global variable or ask for it
        local __INTERNAL_NAMESPACE
        dialogAskForNamespace __INTERNAL_NAMESPACE

        # check if something was found
        if [[ ! -z "${__INTERNAL_NAMESPACE}" ]]; then
            K8S_MGMT_NAMESPACE="${__INTERNAL_NAMESPACE}"
            applySecrets "${K8S_MGMT_NAMESPACE}"
        else
            echo ""
            echo "  ERROR: Unable to get name of the namespace. Please use the -n= | --namespace= argument or type the right namespace into the dialog."
            echo ""
            exit 1
        fi
    elif [[ "${_K8S_MGMT_COMMAND_INSTALL}" == "${K8S_MGMT_COMMAND}" ]]; then
        ## install Jenkins
        installOrUpgradeJenkins "${_K8S_MGMT_COMMAND_INSTALL}"
        installIngressControllerToNamespace
    elif [[ "${_K8S_MGMT_COMMAND_UPGRADE}" == "${K8S_MGMT_COMMAND}" ]]; then
        ## upgrade Jenkins
        installOrUpgradeJenkins "${_K8S_MGMT_COMMAND_UPGRADE}"
    elif [[ "${_K8S_MGMT_COMMAND_UNINSTALL}" == "${K8S_MGMT_COMMAND}" ]]; then
        ## uninstall Jenkins
        uninstallJenkins
        ## uninstall nginx-ingress controller
        uninstallIngressControllerFromNamespace
        ## remove nginx-ingress-controller sa,roles,clusterroes....
        cleanupK8sNginxIngressControllerComplete
    fi
}

run