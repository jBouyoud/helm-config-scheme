# Tests

This tests suite use the [bats-core](https://github.com/bats-core/bats-core) framework.

Some test extension libraries are included in this project as git submodule.

Run

```bash
git submodule update --init --force
```

to checkout the submodules.

## Wording

Inside helm-secrets we have 2 groups of tests:

- **unit tests**

  Can be run without an reachable kubernetes cluster
  Located under [./unit/](./unit)

- **integration tests**

  Depends against a reachable kubernetes cluster
  Located under [./it/](./it)

## Requirements

To execute the tests have to install some utilities first.

### bats

Then follow the installation instruction for bats here: https://github.com/bats-core/bats-core#installation

More information's here: https://github.com/bats-core/bats-core

## Run

If possible start the tests from the root of the repository. Then execute:

```bash
# Unit Tests
bats -r tests/unit

# IT Tests
bats -r tests/it
```

If bats is not installed locally, you could run bats directory from this repo:

```bash
# Unit Tests
./tests/bats/core/bin/bats -r tests/unit

# IT Tests
./tests/bats/core/bin/bats -r tests/it
```

This method is described as "Run bats from source" inside the bats-core documentation.

More information about running single tests or filtering tests can be found here: https://github.com/bats-core/bats-core#usage
