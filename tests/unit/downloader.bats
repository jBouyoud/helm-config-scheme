#!/usr/bin/env bats

load '../lib/helper'
load '../bats/extensions/bats-support/load'
load '../bats/extensions/bats-assert/load'
load '../bats/extensions/bats-file/load'
load '../lib/assert-downloader'

@test "downloader: invalid usage" {
    run helm config-scheme downloader
    assert_failure 1
    assert_output --partial '[config-scheme][downloader] invalid usage, please refer to'

    run helm config-scheme downloader unused
    assert_failure 1
    assert_output --partial '[config-scheme][downloader] invalid usage, please refer to'

    run helm config-scheme downloader unused unused
    assert_failure 1
    assert_output --partial '[config-scheme][downloader] invalid usage, please refer to'

    run helm config-scheme downloader unused unused unused
    assert_failure 1
    assert_output --partial '[config-scheme][downloader] invalid usage, please refer to'
}

@test "downloader: not supported uri" {
    run helm config-scheme downloader unused unused unused git://test
    assert_failure 2
    assert_output --partial "[config-scheme][downloader] URI 'git://test' not supported"
}

@test "downloader: config scheme not found" {
    run helm config-scheme downloader unused unused unused config://random
    assert_failure 2
    assert_output --partial "[config-scheme][downloader] Scheme 'random' doesn't exists"
}

@test "downloader: nominal no file in config" {
    if is_windows; then
        skip
    fi
    if is_coverage; then
        skip
    fi

    helm config-scheme add test "${TEST_TEMP_DIR}/assets/values.yaml"
    rm -rf "${TEST_TEMP_DIR}/assets"

    run helm config-scheme downloader unused unused unused config://test -n namespace 2>&1
    assert_success
    assert_file_not_exist "${HELM_CONFIG_SCHEME_TMP_DIR}"
    assert_output --partial "[config-scheme][downloader] Loading values for '${TEST_TEMP_DIR}/assets/values.yaml' skipped."

    refute_output --partial 'default/values.yaml:'
    refute_output --partial 'default/CHART-NAME.yaml:'
    refute_output --partial 'default/my-chart.yaml:'
    refute_output --partial 'default/RELEASE-NAME.yaml:'
    refute_output --partial 'default/my-release.yaml:'
    refute_output --partial 'default/test.yaml:'
    refute_output --partial 'default/git.yaml:'
    refute_output --partial 'ns/default.yaml:'
    refute_output --partial 'ns/CHART-NAME.yaml:'
    refute_output --partial 'ns/my-chart.yaml:'
    refute_output --partial 'ns/RELEASE-NAME.yaml:'
    refute_output --partial 'ns/my-release.yaml:'
    refute_output --partial 'ns/test.yaml:'
    refute_output --partial 'ns/git.yaml:'
    refute_output --partial 'config-dir/a.yaml:'
    refute_output --partial 'config-dir/b.yaml:'
    refute_output --partial 'config-dir/c.yaml:'
}

@test "downloader: nominal one file in config" {
    if is_windows; then
        skip
    fi

    helm config-scheme add test "${TEST_TEMP_DIR}/assets/values.yaml"

    run helm config-scheme downloader unused unused unused config://test -n namespace 2>&1
    assert_success
    assert_file_not_exist "${HELM_CONFIG_SCHEME_TMP_DIR}"
    assert_output --partial "[config-scheme][downloader] Loading values for '${TEST_TEMP_DIR}/assets/values.yaml' done. 1 file(s) loaded."

    assert_output --partial "$(cat <<-YAML
ingress:
  enabled: true
  annotations:
    default/values.yaml: 'true'
YAML
)"
    refute_output --partial 'default/CHART-NAME.yaml:'
    refute_output --partial 'default/my-chart.yaml:'
    refute_output --partial 'default/RELEASE-NAME.yaml:'
    refute_output --partial 'default/my-release.yaml:'
    refute_output --partial 'default/test.yaml:'
    refute_output --partial 'default/git.yaml:'
    refute_output --partial 'ns/default.yaml:'
    refute_output --partial 'ns/CHART-NAME.yaml:'
    refute_output --partial 'ns/my-chart.yaml:'
    refute_output --partial 'ns/RELEASE-NAME.yaml:'
    refute_output --partial 'ns/my-release.yaml:'
    refute_output --partial 'ns/test.yaml:'
    refute_output --partial 'ns/git.yaml:'
    refute_output --partial 'config-dir/a.yaml:'
    refute_output --partial 'config-dir/b.yaml:'
    refute_output --partial 'config-dir/c.yaml:'
}

@test "downloader: nominal only with local files" {
    if is_windows; then
        skip
    fi
    if is_coverage; then
        skip
    fi

    create_config_scheme test

    run helm config-scheme downloader unused unused unused config://test -n namespace 2>&1
    assert_success
    assert-downloader-output "namespace" "CHART-NAME" "RELEASE-NAME" "test"

    assert_output --partial "$(cat <<-YAML
ingress:
  enabled: true
  annotations:
    default/values.yaml: 'true'
    default/CHART-NAME.yaml: 'true'
    default/RELEASE-NAME.yaml: 'true'
    default/test.yaml: 'true'
    ns/values.yaml: 'true'
    ns/CHART-NAME.yaml: 'true'
    ns/RELEASE-NAME.yaml: 'true'
    ns/test.yaml: 'true'
YAML
)"

    refute_output --partial 'default/my-chart.yaml:'
    refute_output --partial 'default/my-release.yaml:'
    refute_output --partial 'default/git.yaml:'
    refute_output --partial 'ns/my-chart.yaml:'
    refute_output --partial 'ns/my-release.yaml:'
    refute_output --partial 'ns/git.yaml:'
    refute_output --partial 'config-dir/a.yaml:'
    refute_output --partial 'config-dir/b.yaml:'
    refute_output --partial 'config-dir/c.yaml:'

}

@test "downloader: nominal local dirs" {
    if is_windows; then
        skip
    fi
    if is_coverage; then
        skip
    fi

    create_config_scheme test
    helm config-scheme edit test append \
        "${TEST_TEMP_DIR}/assets/config-dir" \
        "${TEST_TEMP_DIR}/assets/config-dir/{{CUSTOM_ENV_VAR}}"

    run helm config-scheme downloader unused unused unused config://test -n namespace 2>&1
    assert_success
    assert-downloader-output "namespace" "CHART-NAME" "RELEASE-NAME" "test"
    assert_output --partial "[config-scheme][downloader] Loading values for '${TEST_TEMP_DIR}/assets/config-dir' done. 3 file(s) loaded."
    assert_output --partial "[config-scheme][downloader] Loading values for '${TEST_TEMP_DIR}/assets/config-dir/test' skipped."

    assert_output --partial "$(cat <<-YAML
ingress:
  enabled: true
  annotations:
    default/values.yaml: 'true'
    default/CHART-NAME.yaml: 'true'
    default/RELEASE-NAME.yaml: 'true'
    default/test.yaml: 'true'
    ns/values.yaml: 'true'
    ns/CHART-NAME.yaml: 'true'
    ns/RELEASE-NAME.yaml: 'true'
    ns/test.yaml: 'true'
    config-dir/a.yaml: 'true'
    config-dir/b.yaml: 'true'
    config-dir/c.yaml: 'true'
YAML
)"

    refute_output --partial 'default/my-chart.yaml:'
    refute_output --partial 'default/my-release.yaml:'
    refute_output --partial 'default/git.yaml:'
    refute_output --partial 'ns/my-chart.yaml:'
    refute_output --partial 'ns/my-release.yaml:'
    refute_output --partial 'ns/git.yaml:'
}

@test "downloader: nominal local regex" {
    if is_windows; then
        skip
    fi
    if is_coverage; then
        skip
    fi

    create_config_scheme test
    helm config-scheme edit test append \
        "${TEST_TEMP_DIR}/assets/config-dir/(a|c)\.yaml" \
        "${TEST_TEMP_DIR}/assets/config-dir/{{CUSTOM_ENV_VAR}}/(a|c)\.yaml"

    run helm config-scheme downloader unused unused unused config://test -n namespace 2>&1
    assert_success
    assert-downloader-output "namespace" "CHART-NAME" "RELEASE-NAME" "test"
    assert_output --partial "[config-scheme][downloader] Loading values for '${TEST_TEMP_DIR}/assets/config-dir/(a|c)\.yaml' done. 2 file(s) loaded."
    assert_output --partial "[config-scheme][downloader] Loading values for '${TEST_TEMP_DIR}/assets/config-dir/test/(a|c)\.yaml' skipped."

    assert_output --partial "$(cat <<-YAML
ingress:
  enabled: true
  annotations:
    default/values.yaml: 'true'
    default/CHART-NAME.yaml: 'true'
    default/RELEASE-NAME.yaml: 'true'
    default/test.yaml: 'true'
    ns/values.yaml: 'true'
    ns/CHART-NAME.yaml: 'true'
    ns/RELEASE-NAME.yaml: 'true'
    ns/test.yaml: 'true'
    config-dir/a.yaml: 'true'
    config-dir/c.yaml: 'true'
YAML
)"

    refute_output --partial 'default/my-chart.yaml:'
    refute_output --partial 'default/my-release.yaml:'
    refute_output --partial 'default/git.yaml:'
    refute_output --partial 'ns/my-chart.yaml:'
    refute_output --partial 'ns/my-release.yaml:'
    refute_output --partial 'ns/git.yaml:'
    refute_output --partial 'config-dir/b.yaml:'
}

@test "downloader: nominal" {
    if is_windows; then
        skip
    fi
    if is_coverage; then
        skip
    fi

    helm_plugin_install git

    create_config_scheme test
    helm config-scheme edit test append \
        "git+https://github.com/jBouyoud/helm-config-scheme@{{chart}}.yaml?ref=master" \
        "git+https://github.com/jBouyoud/helm-config-scheme@tests/assets/git.yaml?ref=main" \
        "git+https://github.com/jBouyoud/helm-config-scheme@tests/assets/{{namespace}}/git.yaml?ref=main"

    run helm config-scheme downloader unused unused unused config://test -n namespace 2>&1
    assert_success
    assert-downloader-output "namespace" "CHART-NAME" "RELEASE-NAME" "test"
    assert_output --partial "[config-scheme][downloader] Loading values for 'git+https://github.com/jBouyoud/helm-config-scheme@CHART-NAME.yaml?ref=master' skipped."
    assert_output --partial "[config-scheme][downloader] Loading values for 'git+https://github.com/jBouyoud/helm-config-scheme@tests/assets/git.yaml?ref=main' done. 1 file(s) loaded."
    assert_output --partial "[config-scheme][downloader] Loading values for 'git+https://github.com/jBouyoud/helm-config-scheme@tests/assets/namespace/git.yaml?ref=main' done. 1 file(s) loaded."

    assert_output --partial "$(cat <<-YAML
ingress:
  enabled: true
  annotations:
    default/values.yaml: 'true'
    default/CHART-NAME.yaml: 'true'
    default/RELEASE-NAME.yaml: 'true'
    default/test.yaml: 'true'
    ns/values.yaml: 'true'
    ns/CHART-NAME.yaml: 'true'
    ns/RELEASE-NAME.yaml: 'true'
    ns/test.yaml: 'true'
    default/git.yaml: "true"
    ns/git.yaml: "true"
YAML
)"

    refute_output --partial 'default/my-chart.yaml:'
    refute_output --partial 'default/my-release.yaml:'
    refute_output --partial 'ns/my-chart.yaml:'
    refute_output --partial 'ns/my-release.yaml:'
    refute_output --partial 'config-dir/a.yaml:'
    refute_output --partial 'config-dir/b.yaml:'
    refute_output --partial 'config-dir/c.yaml:'
}

@test "downloader: scheme with env and env vars is not defined" {
    if is_windows; then
        skip
    fi
    if is_coverage; then
        skip
    fi
    create_config_scheme test
    helm config-scheme edit test append \
        "${TEST_TEMP_DIR}/assets/{{my_env}}/values.yaml"

    run helm config-scheme downloader unused unused unused config://test -n namespace 2>&1
    assert_success
    assert-downloader-output "namespace" "CHART-NAME" "RELEASE-NAME" "test"
    assert_output --partial "$(cat <<-YAML
ingress:
  enabled: true
  annotations:
    default/values.yaml: 'true'
    default/CHART-NAME.yaml: 'true'
    default/RELEASE-NAME.yaml: 'true'
    default/test.yaml: 'true'
    ns/values.yaml: 'true'
    ns/CHART-NAME.yaml: 'true'
    ns/RELEASE-NAME.yaml: 'true'
    ns/test.yaml: 'true'
YAML
)"

    refute_output --partial 'default/my-chart.yaml:'
    refute_output --partial 'default/my-release.yaml:'
    refute_output --partial 'ns/my-chart.yaml:'
    refute_output --partial 'ns/my-release.yaml:'
    refute_output --partial 'config-dir/a.yaml:'
    refute_output --partial 'config-dir/b.yaml:'
    refute_output --partial 'config-dir/c.yaml:'
}
