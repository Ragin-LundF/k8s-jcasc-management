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
- Bugfixes and test improvment with `shunit2`

# 1.2.0 #
- Adding support for GPG in addition of openssl.
  - Can be configured with the `K8S_MGMT_ENCRYPTION_TOOL` configuration.
- Addding support for nginx ingress controller per namespace for better NACL (network access control list)


# 1.0.0 #

- Initial release version