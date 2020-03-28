#!/bin/bash

# read configuration
source ./config/k8s_jcasc_mgmt.cnf

# import subscripts
source ./scripts/arguments.sh
source ./scripts/sed_utils.sh
source ./scripts/ipconfig_utils.sh
source ./scripts/secrets_controller.sh

# start the script
processArguments $@

