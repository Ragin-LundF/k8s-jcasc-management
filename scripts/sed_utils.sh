#!/bin/bash
#########
## DO NOT USE THIS SCRIPT DIRECTLY!
## This script will be loaded by the 'k8s-jcasc.sh' script.

##########
# Function replace a string in a file
#
# It uses sed to replace the strings and write them into a new file.
# This ensures that no data is cut off.
#
# argument 1: string to replace
# argument 2: the new string
# argument 3: file in which the replacement should happen
##########
function replaceStringInFile() {
    local ARG_STR_TO_REPLACE=$1
    local ARG_STR_REPLACEMENT=$2
    local ARG_FILE_TO_PROCESS=$3

    # validate arguments
    if [[ -z "${ARG_STR_TO_REPLACE}" ]]; then
        echo "ERROR sed_utils.sh: No argument of the string to replace found."
        exit 1
    fi
    if [[ -z "${ARG_STR_REPLACEMENT}" ]]; then
        echo "ERROR sed_utils.sh: No argument of the replacement string found."
        exit 1
    fi
    if [[ -z "${ARG_FILE_TO_PROCESS}" ]]; then
        echo "ERROR sed_utils.sh: No argument of the file found, were something should be replaced."
        exit 1
    fi
    if [[ ! -f "${ARG_FILE_TO_PROCESS}" ]]; then
        echo "ERROR sed_utils.sh: File (${ARG_FILE_TO_PROCESS}) in which something should be replaced does not exist."
        exit 1
    fi

    # ensure, that the files does not contain double slashes
    if [[ "${ARG_FILE_TO_PROCESS}" == *"//"* ]]; then
        ARG_FILE_TO_PROCESS=$(echo ${ARG_FILE_TO_PROCESS} | sed -e 's|'//'|'/'|')
    fi

    # replace the string and write a new file via tee.
    sed -e 's|'"${ARG_STR_TO_REPLACE}"'|'"${ARG_STR_REPLACEMENT}"'|' ${ARG_FILE_TO_PROCESS} | tee ${ARG_FILE_TO_PROCESS}.new > /dev/null
    # move the new file to the old file, which ensures that no data is cut off.
    mv ${ARG_FILE_TO_PROCESS}.new ${ARG_FILE_TO_PROCESS}
}
