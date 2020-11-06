
assert-downloader-output-base() {
    assert_output --partial "[config-scheme][downloader] Looking for '${TEST_TEMP_DIR}/rand-assets/values.yaml'..."
    assert_output --partial "[config-scheme][downloader] Looking for '${TEST_TEMP_DIR}/assets/values.yaml'..."
    assert_output --partial "[config-scheme][downloader] Looking for '${TEST_TEMP_DIR}/assets/\${chart}.yaml'..."
    assert_output --partial "[config-scheme][downloader] Looking for '${TEST_TEMP_DIR}/assets/\${release}.yaml'..."
    assert_output --partial "[config-scheme][downloader] Looking for '${TEST_TEMP_DIR}/assets/\${CUSTOM_ENV_VAR}.yaml'..."
    assert_output --partial "[config-scheme][downloader] Looking for '${TEST_TEMP_DIR}/assets/\${namespace}/values.yaml'..."
    assert_output --partial "[config-scheme][downloader] Looking for '${TEST_TEMP_DIR}/assets/\${namespace}/\${chart}.yaml'..."
    assert_output --partial "[config-scheme][downloader] Looking for '${TEST_TEMP_DIR}/assets/\${namespace}/\${release}.yaml'..."
    assert_output --partial "[config-scheme][downloader] Looking for '${TEST_TEMP_DIR}/assets/\${namespace}/\${CUSTOM_ENV_VAR}.yaml'..."

    assert_file_not_exist "${HELM_CONFIG_SCHEME_TMP_DIR}"
}

assert-downloader-output() {
    assert-downloader-output-base

    namespace="${1}"
    chart="${2}"
    release="${3}"
    env="${4}"
    assert_output --partial "[config-scheme][downloader] Ignored config source : ${TEST_TEMP_DIR}/rand-assets/values.yaml"
    assert_output --partial "[config-scheme][downloader] Loaded config source : ${TEST_TEMP_DIR}/assets/values.yaml"
    assert_output --partial "[config-scheme][downloader] Loaded config source : ${TEST_TEMP_DIR}/assets/${chart}.yaml"
    assert_output --partial "[config-scheme][downloader] Loaded config source : ${TEST_TEMP_DIR}/assets/${release}.yaml"
    assert_output --partial "[config-scheme][downloader] Loaded config source : ${TEST_TEMP_DIR}/assets/${env}.yaml"
    assert_output --partial "[config-scheme][downloader] Loaded config source : ${TEST_TEMP_DIR}/assets/${namespace}/values.yaml"
    assert_output --partial "[config-scheme][downloader] Loaded config source : ${TEST_TEMP_DIR}/assets/${namespace}/${chart}.yaml"
    assert_output --partial "[config-scheme][downloader] Loaded config source : ${TEST_TEMP_DIR}/assets/${namespace}/${release}.yaml"
    assert_output --partial "[config-scheme][downloader] Loaded config source : ${TEST_TEMP_DIR}/assets/${namespace}/${env}.yaml"
}
