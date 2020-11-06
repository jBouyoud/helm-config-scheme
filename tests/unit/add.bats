#!/usr/bin/env bats

load '../lib/helper'
load '../bats/extensions/bats-support/load'
load '../bats/extensions/bats-assert/load'
load '../bats/extensions/bats-file/load'

@test "add:" {
    run helm config-scheme add
    assert_failure 2
    assert_output --partial 'Error: Not yet implemented.'
}
