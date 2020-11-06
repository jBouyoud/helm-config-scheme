# Usage and examples

```
$ helm config-scheme help
Repeatable configuration scheme for Helm Charts

This plugin provides a convenient way to manage a set of configuration scheme
And allow to use those defined scheme in your chart operations

Available Commands:
  add     Create a new configuration scheme
  edit    Edit a configuration scheme
  list    List existing configuration scheme
  remove  Remove a configuration scheme
  view    View a configuration scheme

Configuration scheme usage with : 'config://<scheme-name>'
```

## Config scheme management commands

```
  add     Create a new configuration scheme
  edit    Edit a configuration scheme
  list    List existing configuration scheme
  remove  Remove a configuration scheme
  view    View a configuration scheme
```

Each command have its own help reachable with : `helm config-scheme <cmd> help`

A config scheme consist of a list of files uri to be use in your Helm commands

Files uri in scheme supports some variable substitution.

### File uri variable substitution

List of available substitution

| variable        | substituted by                                       | default value |
| --------------- | ---------------------------------------------------- | ------------- |
| `{{namespace}}` | Helm command namespace                               | unknown       |
| `{{release}}`   | Helm release name                                    | RELEASE-NAME  |
| `{{chart}}`     | Helm chart name                                      | CHART_NAME    |
| `{{env}}`       | Replaced by the environment variable value for `env` | unknown       |

#### Caveats

This plugin doesn't support variable substitution with those helm flags :

- `-g`, `--generate-name` : default value for release will be used instead
- `--name-templte` : default value for release will be used instead

### Create a config scheme

TODO

### Edit an existing config scheme

TODO

### List all existing config schemes

TODO

### Remove an existing config scheme

TODO

### View an existing config scheme

TODO

## Config scheme usage

You are able to use your config scheme with `-f` option of Helm command.
This is done through Helm [downloader plugin](https://helm.sh/docs/topics/plugins/#downloader-plugins),
with the scheme : `config://<scheme-name>`

By using this it will fill-in the Helm config file with all files present in your scheme (only if those configured files exists)

```
helm upgrade . -f config://<scheme name>
```

For example:

```
helm config-scheme add my-scheme -f /config-repo/default.yaml -f /config-repo/<namespace>/default.yaml

helm install . -f config://my-scheme -n my-ns
# Equilavent to helm install . -f /config-repo/default.yaml -f /config-repo/ns/default.yaml
# If all files configured in the scheme exists

helm upgrade . -f config://my-scheme -n my-ns
# Equilavent to helm upgrade . -f /config-repo/default.yaml -f /config-repo/ns/default.yaml
# If all files configured in the scheme exists
```
