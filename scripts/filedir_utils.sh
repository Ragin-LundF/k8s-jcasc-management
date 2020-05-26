#!/bin/bash

##########
# This functions is reading the project directory and returns the directories as array
#
# argument 1: Variable for result
##########
function readProjectDirectoriesForDialog() {
    local ARG_RESULT_DIR=$1
    local __DIRECTORIES_ARRAY
    local __DIRECTORY_NAME
    local __DIRECTORIES_STRING_LIST

    # find directories
    __DIRECTORIES_ARRAY=($(ls "${PROJECTS_BASE_DIRECTORY}" | sort))

    # prepare them for dialogs
    for __INTERNAL_FOLDERS in "${__DIRECTORIES_ARRAY[@]}"
    do
        __DIRECTORY_NAME=$(echo "${__INTERNAL_FOLDERS}" | sed -e 's|'"${PROJECTS_BASE_DIRECTORY}"'||')
        __DIRECTORIES_STRING_LIST="${__DIRECTORIES_STRING_LIST} ${__DIRECTORY_NAME} ___ "
        # set selection to OFF after first run
    done

    if [[ -z "${__DIRECTORIES_STRING_LIST}" ]]; then
        echo ""
        echo "ERROR: No project directories found. Please first create some..."
        echo ""
    fi

    eval ${ARG_RESULT_DIR}="\${__DIRECTORIES_STRING_LIST}"
}