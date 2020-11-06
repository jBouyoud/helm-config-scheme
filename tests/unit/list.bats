#!/usr/bin/env bats

load '../lib/helper'
load '../bats/extensions/bats-support/load'
load '../bats/extensions/bats-assert/load'
load '../bats/extensions/bats-file/load'

@test "list -h: show help" {
    run helm config-scheme list -h

    assert_success
    assert_output --partial 'helm config-scheme list'
}

@test "list --help: show help" {
    run helm config-scheme list --help

    assert_success
    assert_output --partial 'helm config-scheme list'
}

@test "list help: show help" {
    run helm config-scheme list help

    assert_success
    assert_output --partial 'helm config-scheme list'
}

@test "list: show none" {
    run helm config-scheme list

    assert_success
    assert_output ''
}

@test "list: show all" {
    helm config-scheme add scheme1 a.yaml
    helm config-scheme add scheme2 a.yaml b.yaml
    helm config-scheme add scheme3 a.yaml b.yaml b.yaml

    run helm config-scheme list

    assert_success
    assert_output --partial 'scheme1	1 file-uri(s)'
    assert_output --partial 'scheme2	2 file-uri(s)'
    assert_output --partial 'scheme3	3 file-uri(s)'
}
