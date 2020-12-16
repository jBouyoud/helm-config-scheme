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

### File uri

Files uri can be :

- Any download scheme like `http://`, `git://`, `secrets://`, built-in in helm or provided by an external helm plugin such as:
  - https://github.com/aslafy-z/helm-git
  - https://github.com/jkroepke/helm-secrets/
- A local file (`./my-values.yaml`); absolute or relative path.
- A local directory (`./config-dir`) absolute or relative path.
  The plugin will search all `(.yaml|.yml)` file in this folder not recursively sorted by their names.
- Else assume that is a regex (`config-dir/(a|c)\.yaml`).
  The plugin will find all files in the (`dirname` of regex)
  And pass your regex to `grep` command to filter these files.
  After that, the plugin will take all files sorted by their names

### File uri variable substitution

List of available substitution

| variable        | substituted by                                       | default value |
| --------------- | ---------------------------------------------------- | ------------- |
| `{{namespace}}` | Helm command namespace                               | unknown       |
| `{{release}}`   | Helm release name                                    | RELEASE-NAME  |
| `{{chart}}`     | Helm chart name                                      | CHART_NAME    |
| `{{env}}`       | Replaced by the environment variable value for `env` | N/A           |

#### Caveats

This plugin doesn't support variable substitution with those helm flags :

- `-g`, `--generate-name` : default value for release will be used instead
- `--name-templte` : default value for release will be used instead

### Create a config scheme

```
helm config-scheme add NAME FILE-URI...
```

You can use this operation to create/add a new configuration scheme.

`helm config-scheme add basic ./my-values.yaml ./another-values.yaml`

You can now use this scheme in any helm operation with :

`helm install my-chart -f config://basic`

### List all existing config schemes

```
helm config-scheme list
```

List all available configuration schemes

`helm config-scheme list`

will output something like

```
basic       2 file-uri(s)
complex  	6 file-uri(s)
```

The output list for each config his name, and the current number of file-uri registered for this scheme.

You can use `view` sub-commands to get details about one scheme.

### View an existing config scheme

`helm config-scheme view NAME`

This command will show you details about an existing configuration scheme

`helm config-scheme view basic`

will output :

```
1 my-values.yaml
2 another-values.yaml
```

The output lists all configured Files uri for the given scheme prefixed by his order number.

### Remove an existing config scheme

`helm config-scheme remove NAME`

This command can be used to remove an existing configuration scheme

`helm config-scheme remove basic`

The `basic` configuration scheme is no more usable.

### Edit an existing config scheme

```
helm config-scheme edit NAME SUB-COMMAND SUB-COMMAND-ARGS...

Edit an existing NAME configuration scheme

Available Commands:
  -  append FILE-URI...

     Add new FILE-URIs to the end of NAME configuration scheme

  -  insert-at INDEX FILE-URI...

     Add new FILE-URIs at INDEX of NAME configuration scheme

  -  replace INDEX FILE-URI

     Replace an existing file_uri at INDEX by FILE-URI of NAME configuration scheme
```

The command is used to modify an existing configuration scheme in order to add/remove/replace some file uris.

#### edit : append

`helm config-scheme edit NAME append FILE-URI...`

This sub-command is used to add file uris to an existing scheme at the end of the list

`helm config-scheme edit basic append ./my-release-values.yaml`

Now the `basic` configuration scheme contains a new file uri `./my-release-values.yaml` at the last position.

#### edit : insert-at

`helm config-scheme edit NAME insert-at INDEX FILE-URI...`

This sub-command is used to add file uris to an existing scheme at the specified index of the list

`helm config-scheme edit basic insert-at 1 ./my-release-values.yaml`

Now the `basic` configuration scheme contains a new file uri `./my-release-values.yaml` at the index 1.
All file uri present before the command at index [1;+] are now at index [2;+]

#### edit : replace

`helm config-scheme edit NAME replace INDEX FILE-URI`

This sub-command is edit ONE file uri on an existing scheme at the specified index of the list

`helm config-scheme edit basic replace 0 ./my-release-values.yaml`

Now the `basic` configuration scheme contains the same number of new file uris
But the file uri at index `0` is now `./my-release-values.yaml`.

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
