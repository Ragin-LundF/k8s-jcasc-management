# 1.12.0
Adding support for cloud template selection

In this release it is possible to create the project configurations more dynamically by selecting different cloud templates.
The file `jcasc_config.yaml` should now have a `##K8S_MGMT_JENKINS_CLOUD_TEMPLATES##` placeholder:

```yaml
  clouds:
    - kubernetes:
        name: "jenkins-build-slaves"
        serverUrl: ""
        serverCertificate: ##KUBERNETES_SERVER_CERTIFICATE##
        directConnection: false
        skipTlsVerify: true
        namespace: "##NAMESPACE##"
        jenkinsUrl: "http://##JENKINS_MASTER_DEPLOYMENT_NAME##:8080"
        maxRequestsPerHostStr: 64
        retentionTimeout: 5
        connectTimeout: 10
        readTimeout: 20
        templates:
##K8S_MGMT_JENKINS_CLOUD_TEMPLATES##
```

**It is important, that the placeholder is at the beginning of the line.**

If a folder called `cloud-templates` is existing in the `templates` folder, then all files in this directory will be shown as possible cloud-templates.
The user can then select which (none or multiple) sub-templates should be added to the main template.

These sub-templates must also start on the beginning of the line.
For an example have a look here: [templates/cloud-templates/node.yaml](./templates/cloud-templates/node.yaml)


# 1.11.0
Adding support to disable Jenkins ingress as default while installing ingress controller.

If Jenkins should deploy applications to other namespaces, it will deploy the ingress controller (if active) also to the other namespaces, but without the ingress of Jenkins.

To create the needed project, there is a new menu point called `createDeploymentOnlyProject`. This function will only ask for directory, namespace and IP and creates only the ingress and loadbalancer relevant files.

The installation for such projects is looking for Jenkins Helm Chart values and if they are not available it skips the installation of Jenkins and sets an internal flag to prevent the installation of a Jenkins ingress routing.


# 1.10.1
Hotfix for MacOS/BSD

MacOS/BSD does not support `find -printf`. Now it uses the default `ls` command for directory listening.


# 1.10.0
Shell script support and directory selection.

With `dialog` and `whiptail` it is now possible to select the directory in a selection dialog instead of an input dialog.

For better support for additional tools and installations, `k8s-jcasc.sh` now checks after (de-)installing Jenkins, if the selected project directory contains shell scripts in a directory called `scripts`.

To use this feature it is required to have the following naming conventions:

- `i_*.sh` -> Scripts for installation
- `d_*.sh` -> Scripts for deinstallation

The deinstallation scripts can only be executed if the project directory matches the namespace name. This is necessary because normally only the namespace and no directory selection is required for deinstallation.


# 1.9.0
Adding support for deployments in other namespaces.

With the following section in the `jenkins_helm_values.yaml` it is possible to add other namespaces to the RBAC binding.
This allows Jenkins to deploy applications into those namespaces later on a CI/CD pipeline.


```yaml
k8smanagement:
  rbac:
    # list of additional namespaces that should be deployable (adds RBAC roles to those namespaces)
    additionalNamespaces: []
```

# 1.8.0 #
- Improved scripts
  - Missing dialog for apply secrets to a namespace added
- Support for dummy entries in `ip_config.cnf` file
  - can be used for IP reservation
  - configuration of the prefix for dummy entries can be done with the `IP_CONFIG_FILE_DUMMY_PREFIX` variable
- `whiptail` support
  - If `dialog` and `whiptail` are installed, the order is:
    - `whiptail`
    - `dialog`
    - `nodialog`

# 1.7.0 #
- Upgrade of Jenkins Helm charts to version 1.11.3
  - Includes accepted PR for advanced changes in `charts/jenkins-master/templates/config.yaml`
  - Removes the old custom `k8sJenkinsMgmtExtension.jenkins.mode: "EXCLUSIVE"` with the new `master.executorMode: "EXCLUSIVE"` value in `jenkins_helm_values.yaml` file.

# 1.6.0 #
- Adding support for encrypted passwords for admin instead of writing them as plain text into the Helm `values.yaml`.
  - Supports also to configure more users with advanced rights via `securityRealms` in JCasC configuration file.

# 1.5.0 #
- Upgrade of Jenkins Helm charts to version 1.11.3

# 1.4.0 #
- Adding support for `dialog` for better experience

# 1.3.0 #
- Bugfixes and test improvement with `shunit2`

# 1.2.0 #
- Adding support for GPG in addition of openssl.
  - Can be configured with the `K8S_MGMT_ENCRYPTION_TOOL` configuration.
- Addding support for nginx ingress controller per namespace for better NACL (network access control list)


# 1.0.0 #

- Initial release version
