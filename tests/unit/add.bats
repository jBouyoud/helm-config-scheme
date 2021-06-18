#!/usr/bin/env bats

load '../lib/helper'
load '../bats/extensions/bats-support/load'
load '../bats/extensions/bats-assert/load'
load '../bats/extensions/bats-file/load'
load '../lib/asserts-config-repository'

@test "add: show help" {
    run helm config-scheme add

    assert_failure 1
    assert_output --partial 'helm config-scheme add NAME FILE-URI...'
}

@test "add -h: show help" {
    run helm config-scheme add -h

    assert_success
    assert_output --partial 'helm config-scheme add NAME FILE-URI...'
}

@test "add --help: show help" {
    run helm config-scheme add --help

    assert_success
    assert_output --partial 'helm config-scheme add NAME FILE-URI...'
}

@test "add help: show help" {
    run helm config-scheme add help

    assert_success
    assert_output --partial 'helm config-scheme add NAME FILE-URI...'
}

@test "add scheme: show help" {
    run helm config-scheme add scheme1

    assert_failure 1
    assert_output --partial 'helm config-scheme add NAME FILE-URI...'
}

@test "add scheme uri: create scheme" {
    run helm config-scheme add scheme1 test.yaml

    assert_success
    assert_output --partial "[config-scheme][registry] Creating 'scheme1'"
    assert_output --partial "[config-scheme][registry] Add file uri 'test.yaml' to scheme 'scheme1'"
    assert_config_repository_scheme "scheme1" "test.yaml"
}

@test "add scheme uri: fail if scheme already exists" {
    helm config-scheme add scheme1 ori.yaml

    run helm config-scheme add scheme1 test.yaml

    assert_failure 2
    assert_output --partial "[config-scheme][add] Scheme 'scheme1' already exists"
    assert_config_repository_scheme "scheme1" "ori.yaml"
}

@test "add scheme uris: create scheme" {
    run helm config-scheme add scheme1 test.yaml config/test.yaml config/sub/test.yaml

    assert_success
    assert_output --partial "[config-scheme][registry] Creating 'scheme1'"
    assert_output --partial "[config-scheme][registry] Add file uri 'test.yaml' to scheme 'scheme1'"
    assert_output --partial "[config-scheme][registry] Add file uri 'config/test.yaml' to scheme 'scheme1'"
    assert_output --partial "[config-scheme][registry] Add file uri 'config/sub/test.yaml' to scheme 'scheme1'"
    assert_config_repository_scheme "scheme1" $'test.yaml\nconfig/test.yaml\nconfig/sub/test.yaml'
}

@test "add scheme uri substitution: create scheme" {
    if is_windows; then
        skip
    fi

    run helm config-scheme add scheme1 "{{namespace}}.yaml"

    assert_success
    assert_output --partial "[config-scheme][registry] Creating 'scheme1'"
    assert_output --partial "[config-scheme][registry] Add file uri '{{namespace}}.yaml' to scheme 'scheme1'"
    assert_config_repository_scheme "scheme1" "\${namespace:-}.yaml"
}

@test "add scheme uris substitution: create scheme" {
    if is_windows; then
        skip
    fi

    run helm config-scheme add scheme1 local/file.yaml "https://my.repo.com/config/{{namespace}}/file.yaml" "git+https://github.com/user/repo/{{chart}}.yaml?ref=master" "secrets://local/{{release}}.yaml" "local/{{my_env}}.yaml"

    assert_success
    assert_output --partial "[config-scheme][registry] Creating 'scheme1'"
    assert_output --partial "[config-scheme][registry] Add file uri 'local/file.yaml' to scheme 'scheme1'"
    assert_output --partial "[config-scheme][registry] Add file uri 'https://my.repo.com/config/{{namespace}}/file.yaml' to scheme 'scheme1'"
    assert_output --partial "[config-scheme][registry] Add file uri 'git+https://github.com/user/repo/{{chart}}.yaml?ref=master' to scheme 'scheme1'"
    assert_output --partial "[config-scheme][registry] Add file uri 'secrets://local/{{release}}.yaml' to scheme 'scheme1'"
    assert_output --partial "[config-scheme][registry] Add file uri 'local/{{my_env}}.yaml' to scheme 'scheme1'"
    assert_config_repository_scheme "scheme1" $'local/file.yaml\nhttps://my.repo.com/config/${namespace:-}/file.yaml\ngit+https://github.com/user/repo/${chart:-}.yaml?ref=master\nsecrets://local/${release:-}.yaml\nlocal/${my_env:-}.yaml'
}
