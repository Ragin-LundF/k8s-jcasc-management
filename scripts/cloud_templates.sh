#!/bin/bash

##########
# Find templates from "templates/cloud-templates" directory.
# Returns empty value if nothing was found or an array of the files
#
# argument 1: variable in which the result should be written (return value)
##########
function findJenkinsCloudTemplates() {
    # arguments
    local ARG_RETVALUE_CLOUD_TEMPLATES=$1
    local __INTERNAL_TEMPLATES_FILE_ARRAY
    if [[ -d "${TEMPLATES_BASE_DIRECTORY}cloud-templates" ]]; then
        __INTERNAL_TEMPLATES_FILE_ARRAY=($(ls "${TEMPLATES_BASE_DIRECTORY}cloud-templates" | grep yaml | sort))
    fi
    eval ${ARG_RETVALUE_CLOUD_TEMPLATES}="(\${__INTERNAL_TEMPLATES_FILE_ARRAY[@]})"
}

##########
# Read selected templates from "templates/cloud-templates" directory.
# This method will do an "echo" if the result is not empty.
# Usage: RESULT_VAR=$(readSelectedCloudTemplates "${VAR[@]}")
#
# argument 1: array with selected files
##########
function readSelectedCloudTemplates() {
    # arguments
    local ARG_CLOUD_TEMPLATES=("$@")

    for __CLOUD_TEMPLATE_NAME in "${ARG_CLOUD_TEMPLATES[@]}"
    do
        local __INTERNAL_CLOUD_TEMPLATE_CAT
        __INTERNAL_CLOUD_TEMPLATE_CAT=$(cat "${TEMPLATES_BASE_DIRECTORY}cloud-templates/${__CLOUD_TEMPLATE_NAME//\"/}")
        # if content was not empty, add it to return value
        if [[ -n "${__INTERNAL_CLOUD_TEMPLATE_CAT}" ]]; then
            echo "${__INTERNAL_CLOUD_TEMPLATE_CAT}"
        fi
    done
}
