#!/usr/bin/env bats

load '../lib/helper'
load '../bats/extensions/bats-support/load'
load '../bats/extensions/bats-assert/load'
load '../bats/extensions/bats-file/load'
load '../lib/assert-downloader'

@test "upgrade: helm upgrade w/ chart" {
    if is_windows; then
        skip
    fi
    RELEASE="upgrade-$(date +%s)-${SEED}"
    create_chart
    create_config_scheme test

    run helm upgrade -i --create-namespace --wait "${RELEASE}" "${TEST_TEMP_DIR}/chart" -f config://test -n namespace 2>&1
    assert_success
    assert_file_not_exist "${HELM_CONFIG_SCHEME_TMP_DIR}"
    assert_output --partial "[config-scheme][downloader] Loading values for '${TEST_TEMP_DIR}/rand-assets/values.yaml' skipped."
    assert_output --partial "[config-scheme][downloader] Loading values for '${TEST_TEMP_DIR}/assets/values.yaml' done. 1 file(s) loaded."
    assert_output --partial "[config-scheme][downloader] Loading values for '${TEST_TEMP_DIR}/assets/chart.yaml' done. 1 file(s) loaded."
    assert_output --partial "[config-scheme][downloader] Loading values for '${TEST_TEMP_DIR}/assets/${RELEASE}.yaml' skipped."
    assert_output --partial "[config-scheme][downloader] Loading values for '${TEST_TEMP_DIR}/assets/test.yaml' done. 1 file(s) loaded."
    assert_output --partial "[config-scheme][downloader] Loading values for '${TEST_TEMP_DIR}/assets/namespace/values.yaml' done. 1 file(s) loaded."
    assert_output --partial "[config-scheme][downloader] Loading values for '${TEST_TEMP_DIR}/assets/namespace/chart.yaml' done. 1 file(s) loaded."
    assert_output --partial "[config-scheme][downloader] Loading values for '${TEST_TEMP_DIR}/assets/namespace/${RELEASE}.yaml' skipped."
    assert_output --partial "[config-scheme][downloader] Loading values for '${TEST_TEMP_DIR}/assets/namespace/test.yaml' done. 1 file(s) loaded."
    assert_output --partial 'STATUS: deployed'

    run helm ls -n namespace
    assert_success
    assert_output --partial "${RELEASE}"

    run kubectl get ing -n namespace -o yaml -l "app.kubernetes.io/name=chart,app.kubernetes.io/instance=${RELEASE}"
    assert_success
    assert_output --partial "kind: Ingress"
    assert_output --partial "$(cat <<-YAML
    annotations:
      default/chart.yaml: "true"
      default/test.yaml: "true"
      default/values.yaml: "true"
      meta.helm.sh/release-name: ${RELEASE}
      meta.helm.sh/release-namespace: namespace
      ns/chart.yaml: "true"
      ns/test.yaml: "true"
      ns/values.yaml: "true"
YAML
)"
}
