#!/bin/sh
#
# TAP-PROCESS.SH --Test that tap is a well behaved process.
#
# Remarks:
# These tests examine the exit status of test runs, ignoring
# any output formatting etc.
#
PATH=..:$PATH
. tap.shl

plan 5

( false; . ../tap.shl; ) > /dev/null
ok_eq $? 0 '"no tests" is considered successful'

( false; . ../tap.shl; ok 0; ok 0; plan; ) > /dev/null
ok_eq $? 0 '"all tests pass" is considered successful'

( false; . ../tap.shl; ok 0; ok 1; plan; ) > /dev/null
ok_eq $? 1 '"any test failures" is considered unsuccessful'

( false; . ../tap.shl; plan 1; ok 0; ok 0; ) > /dev/null
ok_eq $? 2 'plan mis-match is considered unsuccessful'

( false; . ../tap.shl; plan 1; ok 0; ok 1; ) > /dev/null
ok_eq $? 2 'plan and test errors is considered unsuccessful'
