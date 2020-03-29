#!/bin/bash
#########
## DO NOT USE THIS SCRIPT DIRECTLY!
## This script will be loaded by the 'k8s-jcasc.sh' script.

##########
# This functions will check, if the IP is correct
#
# argument 1: IP address
# argument 2: variable in which the result should be written (return value)
#             true = IP address was correct
#             false = IP address has not correct syntax
##########
function validateIpAddress() {
    # arguments
    local ARG_IP_ADDRESS=$1
    local ARG_RETVALUE=$2

    # validation constants
    local __INTERNAL_IP_REGEX_PATTERN="^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$"

    if [[ ! "${ARG_IP_ADDRESS}" =~ ^[0-9]+(\.[0-9]+){3}$ ]]; then
        echo ""
        echo "  ERROR validator_utils.sh: IP address validation failed. Please check your IP!"
        echo ""
        eval ${ARG_RETVALUE}="false"
    else
        eval ${ARG_RETVALUE}="true"
    fi
}

##########
# This functions will check, if the namespace is correct (RFC 952 and RFC 1123 (DNS LABEL))
#
# argument 1: Namespace name
# argument 2: variable in which the result should be written (return value)
#             true = namespace was correct
#             false = namespace has not correct syntax
##########
function validateNamespace() {
    # arguments
    local ARG_NAMESPACE=$1
    local ARG_RETVALUE=$2

    local __INTERNAL_RETVALUE="true"

    # validation constants
    local __INTERNAL_NAMESPACE_MAX_LENGTH=63
    local __INTERNAL_NAMESPACE_PATTERN="^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])$"

    # check max length of namespaces
    if [[ ${#ARG_NAMESPACE} -ge ${__INTERNAL_NAMESPACE_MAX_LENGTH} ]]; then
        echo ""
        echo "  ERROR validator_utils.sh: Namespace is too long!"
        echo ""
        __INTERNAL_RETVALUE="false"
    fi

    # check if namespace fits to RFC 952 and RFC 1123 (DNS LABEL)
    if [[ ! "${ARG_NAMESPACE}" =~ ${__INTERNAL_NAMESPACE_PATTERN} ]]; then
        echo ""
        echo "  ERROR validator_utils.sh: Namespace has syntactical error!"
        echo ""
        __INTERNAL_RETVALUE="false"
    fi
    eval ${ARG_RETVALUE}="\${__INTERNAL_RETVALUE}"
}
