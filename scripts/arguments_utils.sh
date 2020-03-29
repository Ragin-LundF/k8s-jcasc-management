#!/bin/bash
#########
## DO NOT USE THIS SCRIPT DIRECTLY!
## This script will be loaded by the 'k8s-jcasc.sh' script.

function processArguments() {
    # check arguments
    for i in "$@"
    do
        case ${i} in
            ## options
            # directory, where the project configuration is located
            -p=*|--projectdir=*)
                PROJECT_NAME="${i#*=}"
                SED_BASE_DIR=projects/${PROJECT_NAME}
                shift # past argument=value
            ;;
            # name of the namespace
            -n=*|--namespace=*)
                NAMESPACE="${i#*=}"
                shift # past argument=value
            ;;
            # name of the deployment
            -d=*|--deploymentname=*)
                NAME="${i#*=}"
                shift # past argument=value
            ;;

            ## arguments
            # install Jenkins
            install)
                TYPE="install"
                shift # past argument=value
            ;;
            # uninstall Jenkins
            uninstall)
                TYPE="uninstall"
                shift # past argument=value
            ;;
            # encrypt the secrets
            encryptsecrets)
                TYPE="encrypt"
                shift # past argument=value
            ;;
            # decrypt the secrets
            decryptsecrets)
                TYPE="decrypt"
                shift # past argument=value
            ;;
            # apply secrets to kubernetes
            applysecrets)
                TYPE="applysecrets"
                shift # past argument=value
            ;;
            # create new project
            createproject)
                TYPE="createproject"
                shift # past argument=value
            ;;
            *)
                # unknown option
            ;;
        esac
    done
}