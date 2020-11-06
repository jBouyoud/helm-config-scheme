#!/usr/bin/env bats

load '../lib/helper'
load '../bats/extensions/bats-support/load'
load '../bats/extensions/bats-assert/load'
load '../bats/extensions/bats-file/load'

@test "quiet: default" {
    run helm config-scheme add scheme1 test.yaml
    assert_success
    assert_output --partial "[config-scheme][registry] Creating 'scheme1'"
    assert_output --partial "[config-scheme][registry] Add file uri 'test.yaml' to scheme 'scheme1'"
}

@test "quiet: -q" {
    run helm config-scheme -q add scheme1 test.yaml
    assert_success
    refute_output --partial "[config-scheme][registry] Creating 'scheme1'"
    refute_output --partial "[config-scheme][registry] Add file uri 'test.yaml' to scheme 'scheme1'"
}

@test "quiet: --quiet" {
    run helm config-scheme --quiet add scheme1 test.yaml
    assert_success
    refute_output --partial "[config-scheme][registry] Creating 'scheme1'"
    refute_output --partial "[config-scheme][registry] Add file uri 'test.yaml' to scheme 'scheme1'"
}

@test "quiet: env var" {
    HELM_CONFIG_SCHEME_QUIET=true run helm config-scheme -q add scheme1 test.yaml
    assert_success
    refute_output --partial "[config-scheme][registry] Creating 'scheme1'"
    refute_output --partial "[config-scheme][registry] Add file uri 'test.yaml' to scheme 'scheme1'"
}
