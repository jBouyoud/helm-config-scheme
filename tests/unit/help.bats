#!/usr/bin/env bats

load '../lib/helper'
load '../bats/extensions/bats-support/load'
load '../bats/extensions/bats-assert/load'
load '../bats/extensions/bats-file/load'

@test "help: plugin is installed" {
    run helm plugin list
    assert_success
    assert_output --partial 'config-scheme'

    if is_windows; then
        assert_file_exist ".bin/yq.exe"
    else
        assert_file_exist ".bin/yq"
    fi
}

@test "help: helm config-scheme show help" {
    run helm config-scheme 2>&1
    assert_failure
    assert_output --partial 'Repeatable configuration scheme for Helm Charts'
    assert_output --partial 'config://<scheme-name>'
}

@test "template: helm config-scheme -h show help" {
    run helm config-scheme -h 2>&1
    assert_success
    assert_output --partial 'Repeatable configuration scheme for Helm Charts'
    assert_output --partial 'config://<scheme-name>'
}

@test "template: helm config-scheme --help show help" {
    run helm config-scheme --help 2>&1
    assert_success
    assert_output --partial 'Repeatable configuration scheme for Helm Charts'
    assert_output --partial 'config://<scheme-name>'
}

@test "template: helm config-scheme help show help" {
    run helm config-scheme --help 2>&1
    assert_success
    assert_output --partial 'Repeatable configuration scheme for Helm Charts'
    assert_output --partial 'config://<scheme-name>'
}
