#!/bin/bash

# read configuration
source ./config/k8s_jcasc_mgmt.cnf

# import subscripts (take care with order!)
source ./scripts/arguments_utils.sh
source ./scripts/dialogs.sh
source ./scripts/ipconfig_utils.sh
source ./scripts/project_wizard_controller.sh
source ./scripts/secrets_controller.sh
source ./scripts/sed_utils.sh
source ./scripts/validator_utils.sh

# start the script
processArguments $@

if [[ -z "${K8S_MGMT_COMMAND}" ]]; then
    echo ""
    echo "  Something went wrong. Was not able to find a valid command."
    echo ""
    exit 1
fi

if [[ "${_K8S_MGMT_COMMAND_CREATE_PROJECT}" == "${K8S_MGMT_COMMAND}" ]]; then
    projectWizard
fi
