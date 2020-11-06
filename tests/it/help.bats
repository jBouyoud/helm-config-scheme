#!/usr/bin/env bats

load '../lib/helper'
load '../bats/extensions/bats-support/load'
load '../bats/extensions/bats-assert/load'
load '../bats/extensions/bats-file/load'

@test "help: plugin is installed" {
    run helm plugin list
    assert_success
    assert_output --partial 'config-scheme'
}
