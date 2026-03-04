#!/usr/bin/env bats

load '../lib/helper'
load '../bats/extensions/bats-support/load'
load '../bats/extensions/bats-assert/load'
load '../bats/extensions/bats-file/load'

@test "help: plugin is installed" {
    run helm plugin list
    assert_success
    assert_output --partial 'config-scheme'

    _helm_major=$(helm version --template '{{.Version}}' 2>/dev/null | sed 's/v\([0-9]*\).*/\1/')
    if [ "${_helm_major}" -ge 4 ] 2>/dev/null; then
        _yq_dir="${GIT_ROOT}/plugins/helm-config-scheme-cli/.bin"
    else
        _yq_dir=".bin"
    fi

    if is_windows; then
        assert_file_exist "${_yq_dir}/yq.exe"
    else
        assert_file_exist "${_yq_dir}/yq"
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
