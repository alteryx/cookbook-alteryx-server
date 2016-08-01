Testing
-------
This cookbook comes with linting, unit tests (ChefSpec), and integration tests (test-kitchen and InSpec).

### Linting
From the root of the repository, run `rake style`.

### Unit tests
From the root of the repository, run `RUBYOPT='-W0' rake unit`.

### Linting & Unit tests
From the root of the repository, run `RUBYOPT='-W0' rake default`.

### Integration tests
Use the included `.kitchen.yml` file as a base and add customizations to `.kitchen.local.yml` to create an instance in test-kitchen. Run `kitchen verify` to execute the integration tests.
