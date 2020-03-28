#!/bin/bash

##########
# This function checks, if the namespace argument was not empty.
# If it is empty, it exits with 1
#
# argument 1: The namespace, which should be cleaned up
##########
function validateNamespaceArgument() {
    local ARG_NAMESPACE=$1

    # validate arguments
    if [[ -z "${ARG_NAMESPACE}" ]]; then
        echo "ERROR cleanup_k8s.sh: No namespace was defined."
        echo ""
        exit 1
    fi
}

##########
# This function deletes all nginx-ingress controller roles.
#
# argument 1: The namespace, which should be cleaned up
##########
function cleanupK8sNginxIngressRoles() {
    local ARG_NAMESPACE=$1

    validateNamespaceArgument "${ARG_NAMESPACE}"

    echo "Delete roles of the nginx-ingress controller"
    local ROLES=$(kubectl -n ${ARG_NAMESPACE} get role | grep nginx-ingress | awk '{print $1}')
    if [[ ! -z "${ROLES}" ]]; then
        kubectl -n ${ARG_NAMESPACE} delete role ${ROLES}
    fi
}

##########
# This function deletes all nginx-ingress controller role bindings.
#
# argument 1: The namespace, which should be cleaned up
##########
function cleanupK8sNginxIngressRoleBindings() {
    local ARG_NAMESPACE=$1

    validateNamespaceArgument "${ARG_NAMESPACE}"

    echo "Delete rolebindings of the nginx-ingress controller"
    local ROLE_BINDINGS=$(kubectl -n ${ARG_NAMESPACE} get rolebindings | grep nginx-ingress | awk '{print $1}')
    if [[ ! -z "${ROLE_BINDINGS}" ]]; then
        kubectl -n ${ARG_NAMESPACE} delete rolebindings ${ROLE_BINDINGS}
    fi
}

##########
# This function deletes all nginx-ingress controller service accounts.
#
# argument 1: The namespace, which should be cleaned up
function cleanupK8sNginxIngressServiceAccounts() {
    local ARG_NAMESPACE=$1

    validateNamespaceArgument "${ARG_NAMESPACE}"

    echo "Delete service accounts of the nginx-ingress controller"
    local SERVICE_ACCOUNTS=$(kubectl -n ${ARG_NAMESPACE} get sa | grep nginx-ingress | awk '{print $1}')
    if [[ ! -z "${SERVICE_ACCOUNTS}" ]]; then
        kubectl -n ${ARG_NAMESPACE} delete sa ${SERVICE_ACCOUNTS}
    fi
}

##########
# This function deletes all nginx-ingress controller cluster roles.
#
# argument 1: The namespace, which should be cleaned up
function cleanupK8sNginxIngressClusterRoles() {
    local ARG_NAMESPACE=$1

    validateNamespaceArgument "${ARG_NAMESPACE}"

    echo "Delete clusterroles of the nginx-ingress controller"
    local CLUSTER_ROLES=$(kubectl -n ${ARG_NAMESPACE} get clusterrole | grep nginx-ingress-clusterrole-${ARG_NAMESPACE} | awk '{print $1}')
    if [[ ! -z "${CLUSTER_ROLES}" ]]; then
        kubectl -n ${ARG_NAMESPACE} delete clusterrole ${CLUSTER_ROLES}
    fi
}

##########
# This function deletes all nginx-ingress controller cluster role bindings.
#
# argument 1: The namespace, which should be cleaned up
function cleanupK8sNginxIngressClusterRoleBinding() {
    local ARG_NAMESPACE=$1

    validateNamespaceArgument "${ARG_NAMESPACE}"

    echo "Delete clusterrole binding of the nginx-ingress controller"
    local CLUSTER_ROLE_BINDING=$(kubectl -n ${ARG_NAMESPACE} get clusterrolebinding | grep nginx-ingress-clusterrole-nisa-binding-${ARG_NAMESPACE} | awk '{print $1}')
    if [[ ! -z "${CLUSTER_ROLE_BINDING}" ]]; then
        kubectl -n ${ARG_NAMESPACE} delete clusterrolebinding ${CLUSTER_ROLE_BINDING}
    fi
}

##########
# This function deletes all nginx-ingress controller ingress definition for Jenkins.
#
# argument 1: The namespace, which should be cleaned up
function cleanupK8sNginxIngress() {
    local ARG_NAMESPACE=$1

    validateNamespaceArgument "${ARG_NAMESPACE}"

    echo "Delete ingress definition of the nginx-ingress controller (Jenkins ingress)"
    local INGRESS=$(kubectl -n ${ARG_NAMESPACE} get ingress | grep nginx-ingress | awk '{print $1}')
    if [[ ! -z "${INGRESS}" ]]; then
        kubectl -n ${ARG_NAMESPACE} delete ingress ${INGRESS}
    fi
}

##########
# Aggregator function to simply uninstall all nginx-ingress-controller user, roles, bindings and ingress
#
# argument 1: The namespace, which should be cleaned up
function cleanupK8sNginxIngressControllerComplete() {
    local ARG_NAMESPACE=$1
    validateNamespaceArgument "${ARG_NAMESPACE}"

    cleanupK8sNginxIngressRoles "${ARG_NAMESPACE}"
    cleanupK8sNginxIngressRoleBindings "${ARG_NAMESPACE}"
    cleanupK8sNginxIngressServiceAccounts "${ARG_NAMESPACE}"
    cleanupK8sNginxIngressClusterRoles "${ARG_NAMESPACE}"
    cleanupK8sNginxIngressClusterRoleBinding "${ARG_NAMESPACE}"
    cleanupK8sNginxIngress "${ARG_NAMESPACE}"
}
