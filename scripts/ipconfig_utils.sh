#!/bin/bash
#########
## DO NOT USE THIS SCRIPT DIRECTLY!
## This script will be loaded by the 'k8s-jcasc.sh' script.
## The following check ensures, that everything was correct to use this script
if [[ -z "${IP_CONFIG_FILE}" ]]; then
    echo ""
    echo "  ERROR ipconfig_utils.sh: Configuration file was not read correctly. Could not find the 'IP_CONFIG_FILE' variable."
    echo "  ERROR ipconfig_utils.sh: Please do not use this file directly and check your configuration under 'config/k8s_jcasc_mgmt.cnf'."
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
        echo ""
        echo "  ERROR ipconfig_utils.sh: No namespace was given as argument."
        echo ""
    else
        # if namespace was defined, try to read the IP from the config file
        if [[ -f "${IP_CONFIG_FILE}" ]]; then
            while read VAR VALUE
            do
                if [[ "${VAR}" == "${ARG_USED_NAMESPACE}" ]]; then
                    echo ""
                    echo "  INFO ipconfig_utils: IP ${VALUE} found for namespace ${ARG_USED_NAMESPACE}."
                    echo ""
                    eval ${ARG_RETVAL_FOUND_IP_ADDRESS}="${VALUE}"
                fi
            done < ${IP_CONFIG_FILE}
        else
            if [[ "${LOG_LEVEL}" != "NONE" ]]; then
                echo ""
                echo "  INFO ipconfig_utils.sh: File ${IP_CONFIG_FILE} not found. Create a new one!"
                echo ""
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
                    echo ""
                    echo "  INFO ipconfig_utils.sh: IP address ${VALUE} already exists for namespace ${VAR}"
                    echo ""
                fi
                eval ${ARG_RETVAL_NAMESPACE}="${VAR}"
                break
            fi
        done < ${IP_CONFIG_FILE}
    else
        if [[ "${LOG_LEVEL}" != "NONE" ]]; then
            echo ""
            echo "  WARN ipconfig_utils.sh: File '${IP_CONFIG_FILE}' not found."
            echo ""
        fi
    fi
}

##########
# This functions adds a namespace and IP address to the defined IP configuration file in IP_CONFIG_FILE.
#
# argument 1: The new IP address
# argument 2: The new Namespace
##########
function addIpToIpConfiguration() {
    local ARG_NEW_IP_ADDRESS=$1
    local ARG_NEW_NAMESPACE=$2

    # validate arguments
    if [[ -z "${ARG_NEW_IP_ADDRESS}" ]]; then
        echo ""
        echo "  ERROR ipconfig_utils.sh: No new IP was given as argument."
        echo ""
        exit 1
    fi
    if [[ -z "${ARG_NEW_NAMESPACE}" ]]; then
        echo ""
        echo "  ERROR ipconfig_utils.sh: No new namespace was given as argument."
        echo ""
        exit 1
    fi

    # validate if IP address is valid (maybe double check, but ensures, that nothing will fail)
    local __INTERNAL_IP_VALID
    validateIpAddress "${ARG_NEW_IP_ADDRESS}" __INTERNAL_IP_VALID
    if [[ "${__INTERNAL_IP_VALID}" == "false" ]]; then
        exit 1
    fi
    # validate if namespace is valid (maybe double check, but ensures, that nothing will fail)
    local __INTERNAL_NAMESPACE_VALID
    validateNamespace "${ARG_NEW_NAMESPACE}" __INTERNAL_NAMESPACE_VALID
    if [[ "${__INTERNAL_NAMESPACE_VALID}" == "false" ]]; then
        exit 1
    fi

    # first check if IP already exists, to avoid conflicts
    local DOES_IP_ALREADY_EXIST
    validateIfIpAlreadyExists "${ARG_NEW_IP_ADDRESS}" DOES_IP_ALREADY_EXIST

    if [[ "${DOES_IP_ALREADY_EXIST}" == "false" ]]; then
        # add the new IP address to the IP configuration file
        echo "${ARG_NEW_NAMESPACE} ${ARG_NEW_IP_ADDRESS}" >> ${IP_CONFIG_FILE}
    else
        # something went wrong. No previous check has detected, that the IP already exists.
        echo ""
        echo "  ERROR ipconfig_utils.sh: You try to add the IP address '${ARG_NEW_IP_ADDRESS}' to the namespace '${ARG_NEW_NAMESPACE}'."
        echo "  ERROR ipconfig_utils.sh: This IP address was already assigned to the namespace '${DOES_IP_ALREADY_EXIST}'"
        echo "  ERROR ipconfig_utils.sh: Please check your '${IP_CONFIG_FILE}' file."
        echo ""
        exit 1
    fi
}
