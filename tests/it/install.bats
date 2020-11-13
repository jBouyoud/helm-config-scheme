#!/usr/bin/env bats

load '../lib/helper'
load '../bats/extensions/bats-support/load'
load '../bats/extensions/bats-assert/load'
load '../bats/extensions/bats-file/load'
load '../lib/assert-downloader'

@test "install: helm install w/ chart" {
    if is_windows; then
        skip
    fi
    RELEASE="install-$(date +%s)-${SEED}"
    create_chart
    create_config_scheme test

    run helm install --create-namespace --wait "${RELEASE}" "${TEST_TEMP_DIR}/chart" -f config://test -n namespace 2>&1
    assert_success
    assert-downloader-output-base
    assert_output --partial "[config-scheme][downloader] Ignored config source : ${TEST_TEMP_DIR}/rand-assets/values.yaml"
    assert_output --partial "[config-scheme][downloader] Loaded config source : ${TEST_TEMP_DIR}/assets/values.yaml"
    assert_output --partial "[config-scheme][downloader] Loaded config source : ${TEST_TEMP_DIR}/assets/chart.yaml"
    assert_output --partial "[config-scheme][downloader] Ignored config source : ${TEST_TEMP_DIR}/assets/${RELEASE}.yaml"
    assert_output --partial "[config-scheme][downloader] Loaded config source : ${TEST_TEMP_DIR}/assets/test.yaml"
    assert_output --partial "[config-scheme][downloader] Loaded config source : ${TEST_TEMP_DIR}/assets/namespace/values.yaml"
    assert_output --partial "[config-scheme][downloader] Loaded config source : ${TEST_TEMP_DIR}/assets/namespace/chart.yaml"
    assert_output --partial "[config-scheme][downloader] Ignored config source : ${TEST_TEMP_DIR}/assets/namespace/${RELEASE}.yaml"
    assert_output --partial "[config-scheme][downloader] Loaded config source : ${TEST_TEMP_DIR}/assets/namespace/test.yaml"
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
