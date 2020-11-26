
assert-downloader-output() {
    assert_file_not_exist "${HELM_CONFIG_SCHEME_TMP_DIR}"

    namespace="${1}"
    chart="${2}"
    release="${3}"
    env="${4}"
    assert_output --partial "[config-scheme][downloader] Loading values for '${TEST_TEMP_DIR}/rand-assets/values.yaml' skipped."
    assert_output --partial "[config-scheme][downloader] Loading values for '${TEST_TEMP_DIR}/assets/values.yaml' done. 1 file(s) loaded."
    assert_output --partial "[config-scheme][downloader] Loading values for '${TEST_TEMP_DIR}/assets/${chart}.yaml' done. 1 file(s) loaded."
    assert_output --partial "[config-scheme][downloader] Loading values for '${TEST_TEMP_DIR}/assets/${release}.yaml' done. 1 file(s) loaded."
    assert_output --partial "[config-scheme][downloader] Loading values for '${TEST_TEMP_DIR}/assets/${env}.yaml' done. 1 file(s) loaded."
    assert_output --partial "[config-scheme][downloader] Loading values for '${TEST_TEMP_DIR}/assets/${namespace}/values.yaml' done. 1 file(s) loaded."
    assert_output --partial "[config-scheme][downloader] Loading values for '${TEST_TEMP_DIR}/assets/${namespace}/${chart}.yaml' done. 1 file(s) loaded."
    assert_output --partial "[config-scheme][downloader] Loading values for '${TEST_TEMP_DIR}/assets/${namespace}/${release}.yaml' done. 1 file(s) loaded."
    assert_output --partial "[config-scheme][downloader] Loading values for '${TEST_TEMP_DIR}/assets/${namespace}/${env}.yaml' done. 1 file(s) loaded."
}
