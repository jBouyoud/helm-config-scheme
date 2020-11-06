#!/usr/bin/env bats

load '../lib/helper'
load '../bats/extensions/bats-support/load'
load '../bats/extensions/bats-assert/load'
load '../bats/extensions/bats-file/load'

@test "view: show help" {
    run helm config-scheme view

    assert_failure 1
    assert_output --partial 'helm config-scheme view NAME'
}

@test "view -h: show help" {
    run helm config-scheme view -h

    assert_success
    assert_output --partial 'helm config-scheme view NAME'
}

@test "view --help: show help" {
    run helm config-scheme view --help

    assert_success
    assert_output --partial 'helm config-scheme view NAME'
}

@test "view help: show help" {
    run helm config-scheme view help

    assert_success
    assert_output --partial 'helm config-scheme view NAME'
}

@test "view scheme: show error if not exists" {
    helm config-scheme add scheme1 a.yaml
    helm config-scheme add scheme2 a.yaml b.yaml

    run helm config-scheme view bob

    assert_failure 2
    assert_output --partial "[config-scheme][view] Scheme 'bob' doesn't exists"
}

@test "view scheme: show scheme detail for the file uri" {
    helm config-scheme add scheme1 a.yaml
    helm config-scheme add scheme2 a.yaml b.yaml

    run helm config-scheme view scheme1

    assert_success
    assert_output --partial "1 a.yaml"
}

@test "view scheme: show scheme detail for many files uri" {
    helm config-scheme add scheme1 a.yaml
    helm config-scheme add scheme2 a.yaml b.yaml

    run helm config-scheme view scheme2

    assert_success
    assert_output --partial $'1 a.yaml\n2 b.yaml'
}
