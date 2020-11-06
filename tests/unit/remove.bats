#!/usr/bin/env bats

load '../lib/helper'
load '../bats/extensions/bats-support/load'
load '../bats/extensions/bats-assert/load'
load '../bats/extensions/bats-file/load'

@test "remove:" {
    run helm config-scheme remove
    assert_failure 2
    assert_output --partial 'Error: Not yet implemented.'
}