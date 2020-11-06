#!/usr/bin/env bats

load '../lib/helper'
load '../bats/extensions/bats-support/load'
load '../bats/extensions/bats-assert/load'
load '../bats/extensions/bats-file/load'
load '../lib/asserts-config-repository'

@test "remove: show help" {
    run helm config-scheme remove

    assert_failure 1
    assert_output --partial 'helm config-scheme remove NAME'
}

@test "remove -h: show help" {
    run helm config-scheme remove -h

    assert_success
    assert_output --partial 'helm config-scheme remove NAME'
}

@test "remove --help: show help" {
    run helm config-scheme remove --help

    assert_success
    assert_output --partial 'helm config-scheme remove NAME'
}

@test "remove help: show help" {
    run helm config-scheme remove help

    assert_success
    assert_output --partial 'helm config-scheme remove NAME'
}

@test "remove scheme: show error if not exists" {
    helm config-scheme add scheme1 a.yaml
    helm config-scheme add scheme2 a.yaml b.yaml

    run helm config-scheme remove bob

    assert_failure 2
    assert_output --partial "[config-scheme][remove] Scheme 'bob' doesn't exists"
}

@test "remove scheme: remove the scheme" {
    helm config-scheme add scheme1 a.yaml
    helm config-scheme add scheme2 a.yaml b.yaml

    run helm config-scheme remove scheme1

    assert_success
    assert_config_repository_scheme_not_exist "scheme1"
    assert_config_repository_scheme "scheme2" $'a.yaml\nb.yaml'
}
