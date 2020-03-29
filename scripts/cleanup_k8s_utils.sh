#!/bin/bash
#########
## DO NOT USE THIS SCRIPT DIRECTLY!
## This script will be loaded by the 'k8s-jcasc.sh' script.

##########
# This function deletes all nginx-ingress controller roles.
#
# argument 1: The namespace, which should be cleaned up
##########
function cleanupK8sNginxIngressRoles() {
    local ARG_NAMESPACE=$1

    echo ""
    echo "  INFO: Delete nginx-ingress-controller role from Kubernetes..."
    echo ""
    local __INTERNAL_ROLES=$(kubectl -n ${ARG_NAMESPACE} get role | grep ${NGINX_INGRESS_DEPLOYMENT_NAME} | awk '{print $1}')
    if [[ ! -z "${__INTERNAL_ROLES}" ]]; then
        kubectl -n ${ARG_NAMESPACE} delete role ${__INTERNAL_ROLES}
    fi
}

##########
# This function deletes all nginx-ingress controller role bindings.
#
# argument 1: The namespace, which should be cleaned up
##########
function cleanupK8sNginxIngressRoleBindings() {
    local ARG_NAMESPACE=$1

    echo ""
    echo "  INFO: Delete nginx-ingress-controller rolebindings from Kubernetes..."
    echo ""
    local __INTERNAL_ROLE_BINDINGS=$(kubectl -n ${ARG_NAMESPACE} get rolebindings | grep ${NGINX_INGRESS_DEPLOYMENT_NAME} | awk '{print $1}')
    if [[ ! -z "${__INTERNAL_ROLE_BINDINGS}" ]]; then
        kubectl -n ${ARG_NAMESPACE} delete rolebindings ${__INTERNAL_ROLE_BINDINGS}
    fi
}

##########
# This function deletes all nginx-ingress controller service accounts.
#
# argument 1: The namespace, which should be cleaned up
function cleanupK8sNginxIngressServiceAccounts() {
    local ARG_NAMESPACE=$1

    echo ""
    echo "  INFO: Delete nginx-ingress-controller service accounts from Kubernetes..."
    echo ""
    local __INTERNAL_SERVICE_ACCOUNTS=$(kubectl -n ${ARG_NAMESPACE} get sa | grep ${NGINX_INGRESS_DEPLOYMENT_NAME} | awk '{print $1}')
    if [[ ! -z "${__INTERNAL_SERVICE_ACCOUNTS}" ]]; then
        kubectl -n ${ARG_NAMESPACE} delete sa ${__INTERNAL_SERVICE_ACCOUNTS}
    fi
}

##########
# This function deletes all nginx-ingress controller cluster roles.
#
# argument 1: The namespace, which should be cleaned up
function cleanupK8sNginxIngressClusterRoles() {
    local ARG_NAMESPACE=$1

    echo ""
    echo "  INFO: Delete nginx-ingress-controller clusterrole from Kubernetes..."
    echo ""
    local __INTERNAL_CLUSTER_ROLES=$(kubectl -n ${ARG_NAMESPACE} get clusterrole | grep ${NGINX_INGRESS_DEPLOYMENT_NAME}-clusterrole-${ARG_NAMESPACE} | awk '{print $1}')
    if [[ ! -z "${__INTERNAL_CLUSTER_ROLES}" ]]; then
        kubectl -n ${ARG_NAMESPACE} delete clusterrole ${__INTERNAL_CLUSTER_ROLES}
    fi
}

##########
# This function deletes all nginx-ingress controller cluster role bindings.
#
# argument 1: The namespace, which should be cleaned up
function cleanupK8sNginxIngressClusterRoleBinding() {
    local ARG_NAMESPACE=$1

    echo ""
    echo "  INFO: Delete nginx-ingress-controller clusterrolebinding from Kubernetes..."
    echo ""
    local __INTERNAL_CLUSTER_ROLE_BINDING=$(kubectl -n ${ARG_NAMESPACE} get clusterrolebinding | grep ${NGINX_INGRESS_DEPLOYMENT_NAME}-clusterrole-nisa-binding-${ARG_NAMESPACE} | awk '{print $1}')
    if [[ ! -z "${__INTERNAL_CLUSTER_ROLE_BINDING}" ]]; then
        kubectl -n ${ARG_NAMESPACE} delete clusterrolebinding ${__INTERNAL_CLUSTER_ROLE_BINDING}
    fi
}

##########
# This function deletes all nginx-ingress controller ingress definition for Jenkins.
#
# argument 1: The namespace, which should be cleaned up
function cleanupK8sNginxIngress() {
    local ARG_NAMESPACE=$1

    echo ""
    echo "  INFO: Delete nginx-ingress-controller ingress (Jenkins) from Kubernetes..."
    echo ""
    local __INTERNAL_INGRESS=$(kubectl -n ${ARG_NAMESPACE} get ingress | grep ${NGINX_INGRESS_DEPLOYMENT_NAME} | awk '{print $1}')
    if [[ ! -z "${__INTERNAL_INGRESS}" ]]; then
        kubectl -n ${ARG_NAMESPACE} delete ingress ${__INTERNAL_INGRESS}
    fi
}

##########
# Aggregator function to simply uninstall all nginx-ingress-controller user, roles, bindings and ingress
function cleanupK8sNginxIngressControllerComplete() {
    # get namespace from global variables or ask for the name
    local __INTERNAL_NAMESPACE
    dialogAskForNamespace __INTERNAL_NAMESPACE

    cleanupK8sNginxIngressRoles "${__INTERNAL_NAMESPACE}"
    cleanupK8sNginxIngressRoleBindings "${__INTERNAL_NAMESPACE}"
    cleanupK8sNginxIngressServiceAccounts "${__INTERNAL_NAMESPACE}"
    cleanupK8sNginxIngressClusterRoles "${__INTERNAL_NAMESPACE}"
    cleanupK8sNginxIngressClusterRoleBinding "${__INTERNAL_NAMESPACE}"
    cleanupK8sNginxIngress "${__INTERNAL_NAMESPACE}"
}
