#!/usr/bin/env bats

load '../lib/helper'
load '../bats/extensions/bats-support/load'
load '../bats/extensions/bats-assert/load'
load '../bats/extensions/bats-file/load'
load '../lib/assert-downloader'

@test "lint: ok" {
    if is_windows; then
        skip
    fi
    if is_coverage; then
        skip
    fi

    create_chart
    create_config_scheme test

    run helm lint "${TEST_TEMP_DIR}/chart" -f config://test -n namespace 2>&1
    assert_success
    assert-downloader-output "namespace" "CHART-NAME" "RELEASE-NAME" "test"
}
