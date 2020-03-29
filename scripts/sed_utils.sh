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

    # debug output, if something is wrong
    if [[ "${LOG_LEVEL}" == "DEBUG" ]]; then
        echo "  DEBUG: Replacing (${ARG_STR_TO_REPLACE}) with (${ARG_STR_REPLACEMENT}) in file (${ARG_FILE_TO_PROCESS})".
    fi

    # validate arguments
    if [[ -z "${ARG_STR_TO_REPLACE}" ]]; then
        echo ""
        echo "  ERROR sed_utils.sh: No argument of the string to replace found."
        echo ""
        exit 1
    fi
    if [[ -z "${ARG_STR_REPLACEMENT}" ]]; then
        echo ""
        echo "  ERROR sed_utils.sh: No argument for the replacement string found."
        echo ""
        exit 1
    fi
    if [[ -z "${ARG_FILE_TO_PROCESS}" ]]; then
        echo ""
        echo "  ERROR sed_utils.sh: No file argument found. Do not know what to replace."
        echo ""
        exit 1
    fi
    if [[ ! -f "${ARG_FILE_TO_PROCESS}" ]]; then
        echo ""
        echo "  ERROR sed_utils.sh: File (${ARG_FILE_TO_PROCESS}) in which something should be replaced does not exist."
        echo ""
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
