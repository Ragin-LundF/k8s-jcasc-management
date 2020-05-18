#!/bin/bash

setUp() {
    echo "Start setup.."
    IP_CONFIG_FILE="ip_config.cnf.tst"
    IP_CONFIG_FILE_DUMMY_PREFIX="dummy"
    _K8S_MGMT_TEST_IP="1.1.1.1"
    _K8S_MGMT_TEST_NS="my-namespace"
    echo "${_K8S_MGMT_TEST_NS} ${_K8S_MGMT_TEST_IP}" > "${IP_CONFIG_FILE}"
    echo "" >> "${IP_CONFIG_FILE}"
}

tearDown() {
    echo "finishing test"
    rm "${IP_CONFIG_FILE}"
}

testReadNamespacesFromFile() {
    local _RETVAL
    echo "additional-namespace 2.2.2.2" >> "${IP_CONFIG_FILE}"
    . ../scripts/ipconfig_utils.sh && readNamespacesFromFile _RETVAL > /dev/null
    assertEquals "Namespaces are wrong." "${_K8S_MGMT_TEST_NS},additional-namespace" "${_RETVAL}"
}

testReadNamespacesFromFileWithDummyPrefix() {
    local _RETVAL
    echo "additional-namespace 2.2.2.2" >> "${IP_CONFIG_FILE}"
    echo "dummy_mydummynamespace 1.1.1.1" >> "${IP_CONFIG_FILE}"
    . ../scripts/ipconfig_utils.sh && readNamespacesFromFile _RETVAL
    assertEquals "Namespaces are wrong." "${_K8S_MGMT_TEST_NS},additional-namespace" "${_RETVAL}"
}

testValidateIfIpAlreadyExistsWithTrue() {
    local _RETVAL
    . ../scripts/ipconfig_utils.sh && validateIfIpAlreadyExists "${_K8S_MGMT_TEST_IP}" _RETVAL > /dev/null
    assertEquals "IP ${_K8S_MGMT_TEST_IP} not found." "${_K8S_MGMT_TEST_NS}" "${_RETVAL}"
}

testValidateIfIpAlreadyExistsWithFalse() {
    local _RETVAL
    . ../scripts/ipconfig_utils.sh && validateIfIpAlreadyExists "0.0.0.0" _RETVAL > /dev/null
    assertEquals  "Found IP 0.0.0.0 with namespace. Something should be wrong" "false" "${_RETVAL}"
}

testAddIpToIpConfiguration() {
    local ip="38.38.38.38"
    local ns="our-new-namespace"
    . ../scripts/validator_utils.sh && . ../scripts/ipconfig_utils.sh && addIpToIpConfiguration "${ip}" "${ns}" > /dev/null
    local ipLine=$(cat "${IP_CONFIG_FILE}" | grep "${ip}")

    assertEquals "IP and namespace was not added to file" "${ipLine}" "${ns} ${ip}"
}

testAddIpToIpConfigurationWithWrongIp() {
    local ip="38.38.38"
    local ns="our-new-namespace"
    $(. ../scripts/validator_utils.sh && . ../scripts/ipconfig_utils.sh && addIpToIpConfiguration "${ip}" "${ns}"  > /dev/null)

    assertEquals "Script has accepted wrong IP without errors" "1" "$?"
}

testAddIpToIpConfigurationWithWrongNs() {
    local ip="38.38.38.38"
    local ns="---our-new-namespace"
    $(. ../scripts/validator_utils.sh && . ../scripts/ipconfig_utils.sh && addIpToIpConfiguration "${ip}" "${ns}"  > /dev/null)

    assertEquals "Script has accepted wrong Namespace without errors" "1" "$?"
}

. shunit2

