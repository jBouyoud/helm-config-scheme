#!/usr/bin/env sh

set -eu

file_uri_substitution_help() {
    cat <<EOF

FILE-URI specify values in a YAML file or a URL

File uri support some substitutions:

| variable      | substituted by                                       | default value |
| ------------- | ---------------------------------------------------- | ------------- |
| {{namespace}} | Helm command namespace                               | unknown       |
| {{release}}   | Helm release name                                    | RELEASE-NAME  |
| {{chart}}     | Helm chart name                                      | CHART_NAME    |
| {{env}}       | Replaced by the environment variable value for "env" | unknown       |

Example:
- local/file.yaml
- https://my.repo.com/config/{{namespace}}/file.yaml
- git+https://github.com/user/repo/{{chart}}.yaml?ref=master
- secrets://local/{{release}}.yaml
- local/{{my_env}}.yaml

EOF
}

file_uri_subst() {
    file_uri="${1}"

    if [ -z "${file_uri}" ]; then
        log_error "No file uri specified"
        exit 1
    fi

    echo "${file_uri}" | sed 's/{{/${/g' | sed 's/}}/}/g'
}
