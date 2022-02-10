#!/usr/bin/env bats

load '../lib/helper'
load '../bats/extensions/bats-support/load'
load '../bats/extensions/bats-assert/load'
load '../bats/extensions/bats-file/load'
load '../lib/assert-downloader'

@test "template: full args" {
    if is_windows; then
        skip
    fi
    if is_coverage; then
        skip
    fi

    create_chart
    create_config_scheme test

    run helm template my-release "${TEST_TEMP_DIR}/chart" -f config://test -n namespace 2>&1
    assert_success
    assert-downloader-output "namespace" "chart" "my-release" "test"

    assert_output --partial "kind: Ingress"
    assert_output --partial "$(cat <<-YAML
  annotations:
    default/chart.yaml: "true"
    default/my-release.yaml: "true"
    default/test.yaml: "true"
    default/values.yaml: "true"
    ns/chart.yaml: "true"
    ns/my-release.yaml: "true"
    ns/test.yaml: "true"
    ns/values.yaml: "true"
YAML
)"
}

@test "template: full args another release" {
    if is_windows; then
        skip
    fi
    if is_coverage; then
        skip
    fi

    create_chart
    create_config_scheme test

    run helm template another-release "${TEST_TEMP_DIR}/chart" -f config://test -n other-namespace 2>&1
    assert_success
    assert_output --partial "[config-scheme][downloader] Loading values for '${TEST_TEMP_DIR}/rand-assets/values.yaml' skipped."
    assert_output --partial "[config-scheme][downloader] Loading values for '${TEST_TEMP_DIR}/assets/values.yaml' done. 1 file(s) loaded."
    assert_output --partial "[config-scheme][downloader] Loading values for '${TEST_TEMP_DIR}/assets/chart.yaml' done. 1 file(s) loaded."
    assert_output --partial "[config-scheme][downloader] Loading values for '${TEST_TEMP_DIR}/assets/another-release.yaml' skipped."
    assert_output --partial "[config-scheme][downloader] Loading values for '${TEST_TEMP_DIR}/assets/test.yaml' done. 1 file(s) loaded."
    assert_output --partial "[config-scheme][downloader] Loading values for '${TEST_TEMP_DIR}/assets/other-namespace/values.yaml' skipped."
    assert_output --partial "[config-scheme][downloader] Loading values for '${TEST_TEMP_DIR}/assets/other-namespace/chart.yaml' skipped."
    assert_output --partial "[config-scheme][downloader] Loading values for '${TEST_TEMP_DIR}/assets/other-namespace/another-release.yaml' skipped."
    assert_output --partial "[config-scheme][downloader] Loading values for '${TEST_TEMP_DIR}/assets/other-namespace/test.yaml' skipped."

    assert_output --partial "kind: Ingress"
    assert_output --partial "$(cat <<-YAML
  annotations:
    default/chart.yaml: "true"
    default/test.yaml: "true"
    default/values.yaml: "true"
YAML
)"
}

@test "template: full args without release name arg" {
    if is_windows; then
        skip
    fi
    if is_coverage; then
        skip
    fi

    create_chart
    create_config_scheme test

    run helm template "${TEST_TEMP_DIR}/chart" -f config://test -n namespace 2>&1
    assert_success
    assert-downloader-output "namespace" "chart" "RELEASE-NAME" "test"

    assert_output --partial "kind: Ingress"
    assert_output --partial "$(cat <<-YAML
  annotations:
    default/RELEASE-NAME.yaml: "true"
    default/chart.yaml: "true"
    default/test.yaml: "true"
    default/values.yaml: "true"
    ns/RELEASE-NAME.yaml: "true"
    ns/chart.yaml: "true"
    ns/test.yaml: "true"
    ns/values.yaml: "true"
YAML
)"
}

@test "template: full args, flags before" {
    if is_windows; then
        skip
    fi
    if is_coverage; then
        skip
    fi

    create_chart
    create_config_scheme test

    run helm template -f config://test -n namespace my-release "${TEST_TEMP_DIR}/chart" 2>&1
    assert_success
    assert-downloader-output "namespace" "chart" "my-release" "test"

    assert_output --partial "kind: Ingress"
    assert_output --partial "$(cat <<-YAML
  annotations:
    default/chart.yaml: "true"
    default/my-release.yaml: "true"
    default/test.yaml: "true"
    default/values.yaml: "true"
    ns/chart.yaml: "true"
    ns/my-release.yaml: "true"
    ns/test.yaml: "true"
    ns/values.yaml: "true"
YAML
)"
}

@test "template: full args, flags between" {
    if is_windows; then
        skip
    fi
    if is_coverage; then
        skip
    fi

    create_chart
    create_config_scheme test

    run helm template my-release -f config://test -n namespace "${TEST_TEMP_DIR}/chart" 2>&1
    assert_success
    assert-downloader-output "namespace" "chart" "my-release" "test"

    assert_output --partial "kind: Ingress"
    assert_output --partial "$(cat <<-YAML
  annotations:
    default/chart.yaml: "true"
    default/my-release.yaml: "true"
    default/test.yaml: "true"
    default/values.yaml: "true"
    ns/chart.yaml: "true"
    ns/my-release.yaml: "true"
    ns/test.yaml: "true"
    ns/values.yaml: "true"
YAML
)"
}

@test "template: full args, flags across" {
    if is_windows; then
        skip
    fi
    if is_coverage; then
        skip
    fi

    create_chart
    create_config_scheme test

    run helm template -n namespace my-release -f config://test "${TEST_TEMP_DIR}/chart" 2>&1
    assert_success
    assert-downloader-output "namespace" "chart" "my-release" "test"

    assert_output --partial "kind: Ingress"
    assert_output --partial "$(cat <<-YAML
  annotations:
    default/chart.yaml: "true"
    default/my-release.yaml: "true"
    default/test.yaml: "true"
    default/values.yaml: "true"
    ns/chart.yaml: "true"
    ns/my-release.yaml: "true"
    ns/test.yaml: "true"
    ns/values.yaml: "true"
YAML
)"
}

@test "template: packaged chart" {
    if is_windows; then
        skip
    fi
    if is_coverage; then
        skip
    fi

    create_chart
    create_config_scheme test
    helm package "${TEST_TEMP_DIR}/chart" -d "${TEST_TEMP_DIR}"

    run helm template my-release "${TEST_TEMP_DIR}/chart-0.1.0.tgz" -f config://test -n namespace 2>&1
    assert_success
    assert-downloader-output "namespace" "chart" "my-release" "test"

    assert_output --partial "kind: Ingress"
    assert_output --partial "$(cat <<-YAML
  annotations:
    default/chart.yaml: "true"
    default/my-release.yaml: "true"
    default/test.yaml: "true"
    default/values.yaml: "true"
    ns/chart.yaml: "true"
    ns/my-release.yaml: "true"
    ns/test.yaml: "true"
    ns/values.yaml: "true"
YAML
)"
}

@test "template: packaged chart without release" {
    if is_windows; then
        skip
    fi
    if is_coverage; then
        skip
    fi

    create_chart
    create_config_scheme test
    helm package "${TEST_TEMP_DIR}/chart" -d "${TEST_TEMP_DIR}"

    run helm template "${TEST_TEMP_DIR}/chart-0.1.0.tgz" -f config://test -n namespace 2>&1
    assert_success
    assert-downloader-output "namespace" "chart" "RELEASE-NAME" "test"

    assert_output --partial "kind: Ingress"
    assert_output --partial "$(cat <<-YAML
  annotations:
    default/RELEASE-NAME.yaml: "true"
    default/chart.yaml: "true"
    default/test.yaml: "true"
    default/values.yaml: "true"
    ns/RELEASE-NAME.yaml: "true"
    ns/chart.yaml: "true"
    ns/test.yaml: "true"
    ns/values.yaml: "true"
YAML
)"
}

@test "template: ." {
    if is_windows; then
        skip
    fi
    if is_coverage; then
        skip
    fi

    create_chart
    create_config_scheme test

    cd "${TEST_TEMP_DIR}/chart";
    run helm template my-release . -f config://test -n namespace 2>&1
    cd -
    assert_success
    assert-downloader-output "namespace" "chart" "my-release" "test"

    assert_output --partial "kind: Ingress"
    assert_output --partial "$(cat <<-YAML
  annotations:
    default/chart.yaml: "true"
    default/my-release.yaml: "true"
    default/test.yaml: "true"
    default/values.yaml: "true"
    ns/chart.yaml: "true"
    ns/my-release.yaml: "true"
    ns/test.yaml: "true"
    ns/values.yaml: "true"
YAML
)"
}

@test "template: . reversed args" {
    if is_windows; then
        skip
    fi
    if is_coverage; then
        skip
    fi

    create_chart
    create_config_scheme test

    cd "${TEST_TEMP_DIR}/chart";
    run helm template --kube-token bob --values=config://test --wait-for-jobs --namespace=namespace my-release . 2>&1
    cd -
    assert_success
    assert-downloader-output "namespace" "chart" "my-release" "test"

    assert_output --partial "kind: Ingress"
    assert_output --partial "$(cat <<-YAML
  annotations:
    default/chart.yaml: "true"
    default/my-release.yaml: "true"
    default/test.yaml: "true"
    default/values.yaml: "true"
    ns/chart.yaml: "true"
    ns/my-release.yaml: "true"
    ns/test.yaml: "true"
    ns/values.yaml: "true"
YAML
)"
}

@test "template: . without release" {
    if is_windows; then
        skip
    fi
    if is_coverage; then
        skip
    fi

    create_chart
    create_config_scheme test

    cd "${TEST_TEMP_DIR}/chart";
    run helm template . -f config://test -n namespace 2>&1
    cd -;
    assert_success
    assert-downloader-output "namespace" "chart" "RELEASE-NAME" "test"

    assert_output --partial "kind: Ingress"
    assert_output --partial "$(cat <<-YAML
  annotations:
    default/RELEASE-NAME.yaml: "true"
    default/chart.yaml: "true"
    default/test.yaml: "true"
    default/values.yaml: "true"
    ns/RELEASE-NAME.yaml: "true"
    ns/chart.yaml: "true"
    ns/test.yaml: "true"
    ns/values.yaml: "true"
YAML
)"
}

@test "template: fail with -g" {
    if is_windows; then
        skip
    fi

    create_chart
    create_config_scheme test

    run helm template "${TEST_TEMP_DIR}/chart" -g -f config://test -n namespace 2>&1
    assert_failure
    # See https://github.com/helm/helm/issues/8935
    # assert_output --partial "[config-scheme] Unable to proceed repeatable configuration with a generated name"
}

@test "template: fail with --generate-name" {
    if is_windows; then
        skip
    fi

    create_chart
    create_config_scheme test

    run helm template "${TEST_TEMP_DIR}/chart" --generate-name -f config://test -n namespace 2>&1
    assert_failure
    # See https://github.com/helm/helm/issues/8935
    # assert_output --partial "[config-scheme] Unable to proceed repeatable configuration with a generated name"
}

@test "template: fail with --name-template" {
    if is_windows; then
        skip
    fi

    create_chart
    create_config_scheme test

    run helm template "${TEST_TEMP_DIR}/chart" --name-template "bob" -f config://test -n namespace 2>&1
    assert_failure
    # See https://github.com/helm/helm/issues/8935
    # assert_output --partial "[config-scheme] name-template flag is not supported"
}
