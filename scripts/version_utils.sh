#!/bin/bash
K8S_MGMT_VERSION_URL=https://raw.githubusercontent.com/Ragin-LundF/k8s-jcasc-management/master/VERSION
K8S_MGMT_VERSION_TMP_FILE=_tmp_version

function version {
    echo "$@" | awk -F. '{ printf("%d%03d%03d%03d\n", $1,$2,$3,$4); }' | sed 's/^0*//';
}

##########
# receive remote version via wget command
#
# argument 1: variable in which the result should be written (return value)
##########
function remoteVersionWithWget() {
    local ARG_RETVAL_VERSION=$1
    wget -q -O _tmp_version ${K8S_MGMT_VERSION_URL}
    local __INTERNAL_REMOTE_VERSION_WGET=$(cat "${K8S_MGMT_VERSION_TMP_FILE}")
    rm "${K8S_MGMT_VERSION_TMP_FILE}"
    eval ${ARG_RETVAL_VERSION}="\${__INTERNAL_REMOTE_VERSION_WGET}"
}

##########
# receive remote version via curl command
#
# argument 1: variable in which the result should be written (return value)
##########
function remoteVersionWithCurl() {
    local ARG_RETVAL_VERSION=$1
    local __INTERNAL_REMOTE_VERSION_CURL=$(curl -s "${K8S_MGMT_VERSION_URL}" | cat)
    eval ${ARG_RETVAL_VERSION}="\${__INTERNAL_REMOTE_VERSION_CURL}"
}

##########
# if configured, check version and if the version is newer than the current, tell the user,
# that an update is available
##########
function checkVersion() {
    K8S_MGMT_VERSION_CHECK_RESULT="false"

    if [[ "${K8S_MGMT_VERSION_CHECK}" == "true" ]]; then
        local __INTERNAL_REMOTE_VERSION
        if [[ "${K8S_MGMT_VERSION_CHECK_TOOL}" == "wget" ]]; then
            remoteVersionWithWget __INTERNAL_REMOTE_VERSION
        elif [[ "${K8S_MGMT_VERSION_CHECK_TOOL}" == "curl" ]]; then
            remoteVersionWithCurl __INTERNAL_REMOTE_VERSION
        fi
        local __INTERNAL_CURRENT_VERSION=$(cat VERSION)
        if [[ $(version "${__INTERNAL_REMOTE_VERSION}") -gt $(version "${__INTERNAL_CURRENT_VERSION}") ]]; then
            echo ""
            echo "  INFO: A new version of k8s-jcasc-management is available. Please upgrade your version."
            echo "  INFO: For more information, please check: https://github.com/Ragin-LundF/k8s-jcasc-management"
            echo ""
            K8S_MGMT_VERSION_CHECK_RESULT="true"
        fi
    fi
}