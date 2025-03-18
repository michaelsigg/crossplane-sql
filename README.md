# DEV Setup



Install and run [devbox](https://www.jetify.com/docs/devbox/) shell:
```shell
curl -fsSL https://get.jetify.com/devbox | bash

devbox shell
```

Setup cluster with [kind](https://kind.sigs.k8s.io/) and all necessary things:
```shell
task setup-cluster
```

Run postgresql and create sample database with [sql crossplane provider](https://github.com/crossplane-contrib/provider-sql):
```shell
task deploy-postgresql-pod

task deploy-postgresql-database
```
