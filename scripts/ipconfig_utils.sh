#!/bin/bash
#########
## DO NOT USE THIS SCRIPT DIRECTLY!
## This script will be loaded by the 'k8s-jcasc.sh' script.
## The following check ensures, that everything was correct to use this script
if [[ -z "${IP_CONFIG_FILE}" ]]; then
    echo "ERROR ipconfig_utils.sh: Configuration file was not read correctly. Could not find the 'IP_CONFIG_FILE' variable."
    echo "ERROR ipconfig_utils.sh: Please do not use this file directly and check your configuration under 'config/k8s_jcasc_mgmt.cnf'."
    echo ""
    exit 1
fi

##########
# This functions is reading the current IP for the given namespace, if it exists
#
# argument 1: namespace name
# argument 2: variable in which the result should be written (return value)
##########
function readIpForNamespaceFromFile() {
    local ARG_USED_NAMESPACE=$1
    local ARG_RETVAL_FOUND_IP_ADDRESS=$2

    # validate, if namespace was defined
    if [[ -z "${ARG_USED_NAMESPACE}" ]]; then
        echo "ERROR ipconfig_utils.sh: No namespace was given as argument."
        echo ""
    else
        # if namespace was defined, try to read the IP from the config file
        if [[ -f "${IP_CONFIG_FILE}" ]]; then
            while read VAR VALUE
            do
                if [[ "${VAR}" == "${ARG_USED_NAMESPACE}" ]]; then
                    if [[ "${LOG_LEVEL}" != "NONE" ]]; then
                        echo "INFO ipconfig_utils.sh: IP '${VALUE}' found for namespace '${ARG_USED_NAMESPACE}'."
                    fi
                    eval ${ARG_RETVAL_FOUND_IP_ADDRESS}="${VALUE}"
                fi
            done < ${IP_CONFIG_FILE}
        else
            if [[ "${LOG_LEVEL}" != "NONE" ]]; then
                echo "INFO ipconfig_utils.sh: File '${IP_CONFIG_FILE}' not found. Create a new one!"
            fi
            # no file found. create new file
            touch "${IP_CONFIG_FILE}"
            # add last line, because while read needs a LF character on each line
            echo "" > ${IP_CONFIG_FILE}
        fi
    fi
}

##########
# This functions is reading the current IP for the given namespace, if it exists
#
# argument 1: IP that should be checked against the configuration
# argument 2: variable in which the result should be written (return value)
#             The result is false, if IP does not exist or the name of the namespace
##########
function validateIfIpAlreadyExists() {
    local ARG_IP_TO_CHECK=$1
    local ARG_RETVAL_NAMESPACE=$2
    # predefine false. If something will be found, then it will be replaced by the namespace
    eval ${ARG_RETVAL_NAMESPACE}="false"

    # check if file exists
    if [[ -f "${IP_CONFIG_FILE}" ]]; then
        # read file and check if IP was already defined
        while read VAR VALUE
        do
            if [[ "${ARG_IP_TO_CHECK}" == "${VALUE}" ]]; then
                if [[ "${LOG_LEVEL}" != "NONE" ]]; then
                    echo "INFO ipconfig_utils.sh: IP address '${VALUE}' already exists for namespace '${VAR}'"
                fi
                eval ${ARG_RETVAL_NAMESPACE}="${VAR}"
                break
            fi
        done < ${IP_CONFIG_FILE}
    else
        if [[ "${LOG_LEVEL}" != "NONE" ]]; then
            echo "WARN ipconfig_utils.sh: File '${IP_CONFIG_FILE}' not found."
        fi
    fi
}
