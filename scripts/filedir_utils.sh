#!/bin/bash

##########
# This functions is reading the project directory and returns the directories as array
#
# argument 1: Variable for result
##########
function readProjectDirectories() {
    local ARG_RESULT_DIR=$1
    local __DIRECTORIES_ARRAY
    __DIRECTORIES_ARRAY=($(find "${PROJECTS_BASE_DIRECTORY}" -maxdepth 1 -type d -printf '%P\n' | sort))
    local __DIRECTORY_NAME
    local __DIRECTORIES_STRING_LIST

    for __INTERNAL_FOLDERS in "${__DIRECTORIES_ARRAY[@]}"
    do
        __DIRECTORY_NAME=$(echo "${__INTERNAL_FOLDERS}" | sed -e 's|'"${PROJECTS_BASE_DIRECTORY}"'||')
        __DIRECTORIES_STRING_LIST="${__DIRECTORIES_STRING_LIST} ${__DIRECTORY_NAME} ___ "
        # set selection to OFF after first run
    done

    eval ${ARG_RESULT_DIR}="\${__DIRECTORIES_STRING_LIST}"
}