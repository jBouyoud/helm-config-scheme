# helm-config-scheme

[![CI](https://github.com/jBouyoud/helm-config-scheme/workflows/ci/badge.svg)](https://github.com/jBouyoud/helm-config-scheme/)
[![codecov](https://codecov.io/gh/jBouyoud/helm-config-scheme/branch/main/graph/badge.svg?token=HZLCMPG5EC)](https://codecov.io/gh/jBouyoud/helm-config-scheme)
[![License](https://img.shields.io/github/license/jBouyoud/helm-config-scheme.svg)](https://github.com/jBouyoud/helm-config-scheme/blob/master/LICENSE)
[![Current Release](https://img.shields.io/github/release/jBouyoud/helm-config-scheme.svg)](https://github.com/jBouyoud/helm-config-scheme/releases/latest)
[![Production Ready](https://img.shields.io/badge/production-ready-green.svg)](https://github.com/jBouyoud/helm-config-scheme/releases/latest)
[![GitHub issues](https://img.shields.io/github/issues/jBouyoud/helm-config-scheme.svg)](https://github.com/jBouyoud/helm-config-scheme/issues)
[![GitHub pull requests](https://img.shields.io/github/issues-pr/jBouyoud/helm-config-scheme.svg)](https://github.com/jBouyoud/helm-config-scheme/pulls)

Repeatable configuration scheme for Helm Charts

## Usage

### Define a new configuration scheme

Define a configuration scheme for your chart installation

```
helm config-scheme add my-scheme scheme-file
```

where `scheme-file` can be :

```
/config-path/default/values.yaml
secrets:///config-path/default/secrets.yaml
git+https://github.com/jBouyoud/helm-config-scheme@p/config-path/values.yaml?ref=master
```

### Use your configured configuration scheme for your Chart operations

Run helm commands with a config-scheme

```
helm upgrade name . -f config-scheme://my-scheme
```

wich is equivalent to (if all scheme files exists)

```
helm upgrade name . -f /config-path/default/values.yaml -f secrets:///config-path/default/secrets.yaml -f git+https://github.com/jBouyoud/helm-config-scheme@p/config-path/values.yaml?ref=master
```

See: [USAGE.md](USAGE.md) for more information

## Installation

### Helm 4

Helm 4 requires separate packages for each plugin capability. Install both the CLI and getter plugins:

```bash
helm plugin install https://github.com/jBouyoud/helm-config-scheme/releases/download/v1.4.0/config-scheme-1.4.0.tgz --verify=false
helm plugin install https://github.com/jBouyoud/helm-config-scheme/releases/download/v1.4.0/config-scheme-getter-1.4.0.tgz --verify=false
```

The `config-scheme-getter` plugin is required if you use the `config://` protocol in your Helm value files (e.g. `helm upgrade name . -f config-scheme://my-scheme`).

### Helm 3

#### Using Helm plugin manager

```bash
# Install a specific version (recommended)
helm plugin install https://github.com/jBouyoud/helm-config-scheme --version v1.4.0

# Install latest unstable version from main branch
helm plugin install https://github.com/jBouyoud/helm-config-scheme
```

#### Manual installation

```bash
# MacOS
curl -LsSf https://github.com/jBouyoud/helm-config-scheme/releases/latest/download/helm-config-scheme.tar.gz | tar -C "$HOME/Library/helm/plugins" -xzf-

# Linux
curl -LsSf https://github.com/jBouyoud/helm-config-scheme/releases/latest/download/helm-config-scheme.tar.gz | tar -C "$HOME/.local/share/helm/plugins" -xzf-

# Windows (inside cmd)
curl -LsSf https://github.com/jBouyoud/helm-config-scheme/releases/latest/download/helm-config-scheme.tar.gz | tar -C "%APPDATA%\helm\plugins" -xzf-
```

Find the latest version here: https://github.com/jBouyoud/helm-config-scheme/releases

### Helm 2

Helm 2 is not supported.
Please consider upgrading to Helm 3+.

## Moving parts of project

- [`scripts/run.sh`](scripts/run.sh) - Main helm-config-scheme plugin code for all helm-config-scheme plugin actions available in `helm config-scheme help` after plugin install
- [`scripts/lib`](scripts/lib) - Location of libraries functions used by multiple commands
- [`scripts/commands`](scripts/commands) - Sub Commands of `helm config-scheme` are defined here.
- [`tests`](tests) - Test scripts to check if all parts of the plugin work. See [`tests/README.md`](tests/README.md) for more information.

## Copyright and license

© 2020 [Julien Bouyoud (jBouyoud)](https://github.com/jBouyoud/helm-config-scheme)

Licensed under the [Apache License, Version 2.0](LICENSE)
