#!/usr/bin/env bats

load '../lib/helper'
load '../bats/extensions/bats-support/load'
load '../bats/extensions/bats-assert/load'
load '../bats/extensions/bats-file/load'
load '../lib/asserts-config-repository'

@test "edit: show help" {
    run helm config-scheme edit

    assert_failure 1
    assert_output --partial 'helm config-scheme edit NAME SUB-COMMAND SUB-COMMAND-ARGS'
}

@test "edit -h: show help" {
    run helm config-scheme edit -h

    assert_success
    assert_output --partial 'helm config-scheme edit NAME SUB-COMMAND SUB-COMMAND-ARGS'
}

@test "edit --help: show help" {
    run helm config-scheme edit --help

    assert_success
    assert_output --partial 'helm config-scheme edit NAME SUB-COMMAND SUB-COMMAND-ARGS'
}

@test "edit help: show help" {
    run helm config-scheme edit help

    assert_success
    assert_output --partial 'helm config-scheme edit NAME SUB-COMMAND SUB-COMMAND-ARGS...'
}

@test "edit whatever: show help" {
    run helm config-scheme edit whatever

    assert_failure 1
    assert_output --partial 'helm config-scheme edit NAME SUB-COMMAND SUB-COMMAND-ARGS...'
}

@test "edit whatever append: error" {
    helm config-scheme add scheme0 z.yaml

    run helm config-scheme edit whatever append

    assert_failure 2
    assert_output --partial "[config-scheme][edit] Scheme 'whatever' doesn't exists"
}

@test "edit NAME append: error" {
    helm config-scheme add scheme1 a.yaml

    run helm config-scheme edit scheme1 append

    assert_failure 1
    assert_output --partial 'helm config-scheme edit NAME SUB-COMMAND SUB-COMMAND-ARGS...'
}

@test "edit NAME insert-at: error" {
    helm config-scheme add scheme1 a.yaml

    run helm config-scheme edit scheme1 insert-at

    assert_failure 1
    assert_output --partial 'helm config-scheme edit NAME SUB-COMMAND SUB-COMMAND-ARGS...'
}

@test "edit NAME replace: error" {
    helm config-scheme add scheme1 a.yaml

    run helm config-scheme edit scheme1 replace

    assert_failure 1
    assert_output --partial 'helm config-scheme edit NAME SUB-COMMAND SUB-COMMAND-ARGS...'
}

@test "edit NAME append uri: append one uri to scheme" {
    helm config-scheme add scheme0 z.yaml
    helm config-scheme add scheme1 a.yaml b.yaml c.yaml
    helm config-scheme add scheme2 y.yaml

    run helm config-scheme edit scheme1 append test.yaml

    assert_success
    assert_output --partial "[config-scheme][registry] Add file uri 'test.yaml' to scheme 'scheme1'"
    assert_config_repository_scheme "scheme0" "z.yaml"
    assert_config_repository_scheme "scheme2" "y.yaml"
    assert_config_repository_scheme "scheme1" $'a.yaml\nb.yaml\nc.yaml\ntest.yaml'
}

@test "edit NAME append uris: append uris to scheme" {
    helm config-scheme add scheme0 z.yaml
    helm config-scheme add scheme1 a.yaml b.yaml c.yaml
    helm config-scheme add scheme2 y.yaml

    run helm config-scheme edit scheme1 append test.yaml test2.yaml test3.yaml

    assert_success
    assert_output --partial "[config-scheme][registry] Add file uri 'test.yaml' to scheme 'scheme1'"
    assert_output --partial "[config-scheme][registry] Add file uri 'test2.yaml' to scheme 'scheme1'"
    assert_output --partial "[config-scheme][registry] Add file uri 'test3.yaml' to scheme 'scheme1'"
    assert_config_repository_scheme "scheme0" "z.yaml"
    assert_config_repository_scheme "scheme2" "y.yaml"
    assert_config_repository_scheme "scheme1" $'a.yaml\nb.yaml\nc.yaml\ntest.yaml\ntest2.yaml\ntest3.yaml'
}

@test "edit NAME insert-at idx: error" {
    helm config-scheme add scheme0 z.yaml
    helm config-scheme add scheme1 a.yaml b.yaml c.yaml
    helm config-scheme add scheme2 y.yaml

    run helm config-scheme edit scheme1 insert-at 0

    assert_failure 1
    assert_output --partial 'helm config-scheme edit NAME SUB-COMMAND SUB-COMMAND-ARGS...'
}

@test "edit NAME insert-at -1 uri: error" {
    helm config-scheme add scheme0 z.yaml
    helm config-scheme add scheme1 a.yaml b.yaml c.yaml
    helm config-scheme add scheme2 y.yaml

    run helm config-scheme edit scheme1 insert-at -1 test.yaml

    assert_failure 2
    assert_output --partial '[config-scheme][edit] INDEX must be in [O;3['
}

@test "edit NAME insert-at n+1 uri: error" {
    helm config-scheme add scheme0 z.yaml
    helm config-scheme add scheme1 a.yaml b.yaml c.yaml
    helm config-scheme add scheme2 y.yaml

    run helm config-scheme edit scheme1 insert-at 4 test.yaml

    assert_failure 2
    assert_output --partial '[config-scheme][edit] INDEX must be in [O;3['
}

@test "edit NAME insert-at idx uri: success" {
    helm config-scheme add scheme0 z.yaml
    helm config-scheme add scheme1 a.yaml b.yaml c.yaml
    helm config-scheme add scheme2 y.yaml

    run helm config-scheme edit scheme1 insert-at 1 test.yaml

    assert_success
    assert_output --partial "[config-scheme][registry] Add file uri 'test.yaml' to scheme 'scheme1'"
    assert_config_repository_scheme "scheme0" "z.yaml"
    assert_config_repository_scheme "scheme2" "y.yaml"
    assert_config_repository_scheme "scheme1" $'a.yaml\ntest.yaml\nb.yaml\nc.yaml'
}

@test "edit NAME insert-at idx uris: success" {
    helm config-scheme add scheme0 z.yaml
    helm config-scheme add scheme1 a.yaml b.yaml c.yaml
    helm config-scheme add scheme2 y.yaml

    run helm config-scheme edit scheme1 insert-at 1 test.yaml test2.yaml test3.yaml

    assert_success
    assert_output --partial "[config-scheme][registry] Add file uri 'test.yaml' to scheme 'scheme1'"
    assert_output --partial "[config-scheme][registry] Add file uri 'test2.yaml' to scheme 'scheme1'"
    assert_output --partial "[config-scheme][registry] Add file uri 'test3.yaml' to scheme 'scheme1'"
    assert_config_repository_scheme "scheme0" "z.yaml"
    assert_config_repository_scheme "scheme2" "y.yaml"
    assert_config_repository_scheme "scheme1" $'a.yaml\ntest.yaml\ntest2.yaml\ntest3.yaml\nb.yaml\nc.yaml'
}

@test "edit NAME replace idx: error" {
    helm config-scheme add scheme0 z.yaml
    helm config-scheme add scheme1 a.yaml b.yaml c.yaml
    helm config-scheme add scheme2 y.yaml

    run helm config-scheme edit scheme1 replace 0

    assert_failure 1
    assert_output --partial 'helm config-scheme edit NAME SUB-COMMAND SUB-COMMAND-ARGS...'
}

@test "edit NAME replace -1 uri: error" {
    helm config-scheme add scheme0 z.yaml
    helm config-scheme add scheme1 a.yaml b.yaml c.yaml
    helm config-scheme add scheme2 y.yaml

    run helm config-scheme edit scheme1 replace -1 test.yaml

    assert_failure 2
    assert_output --partial '[config-scheme][edit] INDEX must be in [O;3['
}

@test "edit NAME replace n+1 uri: error" {
    helm config-scheme add scheme0 z.yaml
    helm config-scheme add scheme1 a.yaml b.yaml c.yaml
    helm config-scheme add scheme2 y.yaml

    run helm config-scheme edit scheme1 replace 4 test.yaml

    assert_failure 2
    assert_output --partial '[config-scheme][edit] INDEX must be in [O;3['
}

@test "edit NAME replace idx uri: success" {
    helm config-scheme add scheme0 z.yaml
    helm config-scheme add scheme1 a.yaml b.yaml c.yaml
    helm config-scheme add scheme2 y.yaml

    run helm config-scheme edit scheme1 replace 1 test.yaml

    assert_success
    assert_output --partial "[config-scheme][registry] Add file uri 'test.yaml' to scheme 'scheme1'"
    assert_config_repository_scheme "scheme0" "z.yaml"
    assert_config_repository_scheme "scheme2" "y.yaml"
    assert_config_repository_scheme "scheme1" $'a.yaml\ntest.yaml\nc.yaml'
}

@test "edit NAME replace idx uris: success" {
    helm config-scheme add scheme0 z.yaml
    helm config-scheme add scheme1 a.yaml b.yaml c.yaml
    helm config-scheme add scheme2 y.yaml

    run helm config-scheme edit scheme1 replace 1 test.yaml test2.yaml test3.yaml

    assert_failure 1
    assert_output --partial 'helm config-scheme edit NAME SUB-COMMAND SUB-COMMAND-ARGS...'
}
