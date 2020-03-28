# Helm overview #

This directory contains the helm charts, that will be used for the deployment.

## jenkins-master ##
This is an edited copy of https://github.com/helm/charts/tree/master/stable/jenkins.

### Changes ###
To have more flexibility and to add the possibility to deploy directly from Jenkins, it was necessary to change some things in the default Helm Charts.

These changes are listed here:
 - changed: `jenkins-master/templates/config.yaml`
 - added: `jenkins-master/templates/k8s-mgmt-jenkins-agent-deploy-rbac.yaml`

### k8s-mgmt-jenkins-agent-deploy-rbac.yaml ##
This file defines additional roles, that the Jenkins slaves are able to deploy an application.

 All changes are marked with an `K8S-Jenkins-Management` comment and some `====`, that it is possible to upgrade them easily.

## nginx-ingress-controller ##

This is a custom copy of https://github.com/kubernetes/ingress-nginx/tree/master/deploy/static.

It contains the minimum configuration for the ingress controller and loadbalancer and creates the initial Jenkins ingress route.
