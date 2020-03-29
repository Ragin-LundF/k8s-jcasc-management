#!/bin/bash
#########
## DO NOT USE THIS SCRIPT DIRECTLY!
## This script will be loaded by the 'k8s-jcasc.sh' script.

##########
# Ask for namespace, if global K8S mgmt namespace variable was not set.
# If the namespace is wrong the dialog calls itself again until the user
# enters a valid name
#
# argument 1: variable in which the result should be written (return value)
##########
function dialogAskForNamespace() {
    # arguments
    local ARG_RETVALUE=$1

    # first check, if global namespace variable was not set
    if [[ -z "${K8S_MGMT_NAMESPACE}" ]]; then
        # get data from user
        read -p "Please enter the namespace for your installation: " __INTERNAL_NAMESPACE

        # validate
        local __INTERNAL_NAMESPACE_VALID
        validateNamespace "${__INTERNAL_NAMESPACE}" __INTERNAL_NAMESPACE_VALID
        # if namespace was invalid ask again, else return namespace
        if [[ "${__INTERNAL_NAMESPACE_VALID}" == "false" ]]; then
            local __INTERNAL_NAMESPACE_RECURSIVE_DUMMY
            dialogAskForNamespace __INTERNAL_NAMESPACE_RECURSIVE_DUMMY
        fi
    else
        __INTERNAL_NAMESPACE="${K8S_MGMT_NAMESPACE}"
    fi
    eval ${ARG_RETVALUE}="\${__INTERNAL_NAMESPACE}"
}

##########
# Ask for IP address, if global K8S mgmt IP variable was not set.
# If the IP address is wrong the dialog calls itself again until the user
# enters a valid IP
#
# argument 1: variable in which the result should be written (return value)
##########
function dialogAskForIpAddress() {
    # arguments
    local ARG_RETVALUE=$1

    # first check, if global IP variable was not set
    if [[ -z "${K8S_MGMT_IP_ADDRESS}" ]]; then
        # get data from user
        read -p "Please enter the loadbalancer IP for your installation: " __INTERNAL_IP_ADDRESS

        # validate
        local __INTERNAL_IP_ADDRESS_VALID
        validateIpAddress "${__INTERNAL_IP_ADDRESS}" __INTERNAL_IP_ADDRESS_VALID
        # if IP address was invalid ask again, else return IP
        if [[ "${__INTERNAL_IP_ADDRESS_VALID}" == "false" ]]; then
            local __INTERNAL_IP_ADDRESS_DUMMY
            dialogAskForIpAddress __INTERNAL_IP_ADDRESS_DUMMY
        fi
    else
        __INTERNAL_IP_ADDRESS="${K8S_MGMT_IP_ADDRESS}"
    fi
    eval ${ARG_RETVALUE}="\${__INTERNAL_IP_ADDRESS}"
}

##########
# Ask for Jenkins system message.
#
# argument 1: variable in which the result should be written (return value)
##########
function dialogAskForJenkinsSystemMessage() {
    # arguments
    local ARG_RETVALUE=$1

    # get data from user
    local __INTERNAL_JENKINS_SYSMSG
    read -p "Please enter the Jenkins system message or leave empty for default (can be changed later in the JCasC file): " __INTERNAL_JENKINS_SYSMSG

    eval ${ARG_RETVALUE}="\${__INTERNAL_JENKINS_SYSMSG}"
}

##########
# Ask for Jenkins job configuration repository.
#
# argument 1: variable in which the result should be written (return value)
##########
function dialogAskForJenkinsJobConfigurationRepository() {
    # arguments
    local ARG_RETVALUE=$1

    # generate the message
    local READ_MESSAGE
    if [[ -z "${JENKINS_JOBDSL_BASE_URL}" ]]; then
        READ_MESSAGE="Please enter the URL to the job configuration repository"
    else
        READ_MESSAGE="Please enter the URL or URI to the job configuration repository (URI must be the part after '${JENKINS_JOBDSL_BASE_URL}')"
    fi
    # get data from user
    read -p "${READ_MESSAGE}: " __INTERNAL_JENKINS_JOB_REPO

    # validate entry if pattern was there
    if [[ ! -z "${JENKINS_JOBDSL_REPO_VALIDATE_PATTERN}" ]]; then
        if [[ ! "${__INTERNAL_JENKINS_JOB_REPO}" =~ ${JENKINS_JOBDSL_REPO_VALIDATE_PATTERN} ]]; then
            echo "ERROR dialogs.sh: The Jenkins job configuration repository has a wrong syntax."
            echo "ERROR dialogs.sh: It must match the pattern: '${JENKINS_JOBDSL_REPO_VALIDATE_PATTERN}'"
            echo ""
            local __INTERNAL_RECURSIVE_JOB_REPO_DUMMY
            dialogAskForJenkinsJobConfigurationRepository __INTERNAL_RECURSIVE_JOB_REPO_DUMMY
        fi
    fi

    ## generate the final result
    if [[ ! -z "${JENKINS_JOBDSL_BASE_URL}" ]]; then
        # if JENKINS_JOBDSL_BASE_URL was defined, check if there is something with "://" (ssh/http/https...)
        if [[ "${__INTERNAL_JENKINS_JOB_REPO}" != *"://"* ]]; then
            # add a slash if base url does not end with slash and new repo does not start with slash
            if [[ "${JENKINS_JOBDSL_BASE_URL}" != *"/" && "${__INTERNAL_JENKINS_JOB_REPO}" != "/"* ]]; then
                __INTERNAL_JENKINS_JOB_REPO="/${__INTERNAL_JENKINS_JOB_REPO}"
            fi
            # should be no URL, so add the base url
            __INTERNAL_JENKINS_JOB_REPO="${JENKINS_JOBDSL_BASE_URL}${__INTERNAL_JENKINS_JOB_REPO}"
        fi
    fi
    eval ${ARG_RETVALUE}="\${__INTERNAL_JENKINS_JOB_REPO}"
}
