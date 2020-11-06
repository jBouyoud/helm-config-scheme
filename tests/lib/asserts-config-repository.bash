
assert_config_repository_scheme() {
    file="${HELM_CONFIG_SCHEME_REPOSITORY}/${1}"

    assert_file_exist "${file}"
    assert_equal "$(cat "${file}")" "${2}"
}
