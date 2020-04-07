#!/bin/bash

######### test IP address
testValidateIpAddress() {
    local _RETVAL
    . ../scripts/validator_utils.sh && validateIpAddress "1.2.3.4" _RETVAL > /dev/null

    assertEquals "IP validation failed" "true" "${_RETVAL}"
}

testValidateIpAddressWithEmptyIp() {
    local _RETVAL
    . ../scripts/validator_utils.sh && validateIpAddress "" _RETVAL > /dev/null

    assertEquals "IP validation failed" "false" "${_RETVAL}"
}

testValidateIpAddressWith3Numbers() {
    local _RETVAL
    . ../scripts/validator_utils.sh && validateIpAddress "1.2.3" _RETVAL > /dev/null

    assertEquals "IP validation failed" "false" "${_RETVAL}"
}

testValidateIpAddressWithCharacters() {
    local _RETVAL
    . ../scripts/validator_utils.sh && validateIpAddress "1.2.3.a" _RETVAL > /dev/null

    assertEquals "IP validation failed" "false" "${_RETVAL}"
}

######### test namespace
testValidateNamespace() {
    local _RETVAL
    . ../scripts/validator_utils.sh && validateNamespace "my-namespace-for-you" _RETVAL > /dev/null

    assertEquals "Namespace validation failed" "true" "${_RETVAL}"
}

testValidateNamespaceWithLeadingMinus() {
    local _RETVAL
    . ../scripts/validator_utils.sh && validateNamespace "-my-namespace-for-you" _RETVAL > /dev/null

    assertEquals "Namespace validation failed" "false" "${_RETVAL}"
}

testValidateNamespaceWithTrailingMinus() {
    local _RETVAL
    . ../scripts/validator_utils.sh && validateNamespace "my-namespace-for-you-" _RETVAL > /dev/null

    assertEquals "Namespace validation failed" "false" "${_RETVAL}"
}

testValidateNamespaceWithTooLongValue() {
    local _RETVAL
    . ../scripts/validator_utils.sh && validateNamespace "this-namespace-is-too-long-and-must-fail-else-something-is-wrong" _RETVAL > /dev/null

    assertEquals "Namespace validation failed" "false" "${_RETVAL}"
}

testValidateNamespaceWithMaxLongValue() {
    local _RETVAL
    . ../scripts/validator_utils.sh && validateNamespace "this-namespace-is-not-to-long-and-work-else-something-is-wrong" _RETVAL > /dev/null

    assertEquals "Namespace validation failed" "true" "${_RETVAL}"
}

testValidateNamespaceWithNumbers() {
    local _RETVAL
    . ../scripts/validator_utils.sh && validateNamespace "this-namespace-contains-1-number" _RETVAL > /dev/null

    assertEquals "Namespace validation failed" "true" "${_RETVAL}"
}

. shunit2