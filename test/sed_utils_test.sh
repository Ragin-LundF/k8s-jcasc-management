#!/bin/bash

######### test sed script errors
testSedUtilsWithoutFirstArgument() {
    $(. ../scripts/sed_utils.sh && replaceStringInFile "" "second" "myfile" > /dev/null)

    assertEquals "sed_utils.sh accepted empty first argument" "1" "$?"
}

testSedUtilsWithoutSecondArgument() {
    $(. ../scripts/sed_utils.sh && replaceStringInFile "first" "" "myfile" > /dev/null)

    assertEquals "sed_utils.sh accepted empty second argument" "1" "$?"
}

testSedUtilsWithoutThirdArgument() {
    $(. ../scripts/sed_utils.sh && replaceStringInFile "first" "second" "" > /dev/null)

    assertEquals "sed_utils.sh accepted empty third argument" "1" "$?"
}

. shunit2