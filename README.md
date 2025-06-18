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
task deploy-postgresql-server

task deploy-postgresql-database

# create db schema with atlas operator
task deploy-postgresql-atlas-schema
```

Run various demo database-instances and deploy XRD and XR with SQL-Provider/Atlas-Operator:
```shell
# deploy CRD and demo db instances
task deploy-demo-db-instances

# deploy definition (XRD) and composition (XR)
task deploy-demo-xrd-and-xr

# render XR local
crossplane render --extra-resources=examples/api/bedag_database/configmap.yaml examples/api/bedag_database/xr.yaml examples/api/bedag_database/composition.yaml examples/api/bedag_database/functions.yaml

# deploy demo claim
kubectl apply -f examples/api/bedag_database/claim.yaml

# check status of crossplane resources
crossplane beta trace database.database.bedag.ch db1 -n db1

# check status of atlas schema
kubectl wait --namespace db1 --for=condition=ready atlasschemas.db.atlasgo.io/db1-schema --timeout=90s

# check database tables
kubectl exec -n bedag-db -it $(kubectl get pods -n bedag-db -l instance=co-backend-bronze -o jsonpath='{.items[0].metadata.name}') -- psql -U postgres -d db1 -c "\dt"
```

Setup demo REST-API with [Pode](https://github.com/Badgerati/Pode):
```shell
task deploy-pode
```

Send requests with [http crossplane provider](https://github.com/crossplane-contrib/provider-http):
```shell
# run a DisposableRequest (https://github.com/crossplane-contrib/provider-http/blob/main/resources-docs/disposablerequest_docs.md)
kubectl apply -f examples/provider-http-with-pode/disposablerequest.yaml
#- check response secret
kubectl get secrets notification-response -o jsonpath='{.data.message}' | base64 -d

# run a Request (https://github.com/crossplane-contrib/provider-http/blob/main/resources-docs/request_docs.md)
kubectl apply -f examples/provider-http-with-pode/request.yaml
#- check response
kubectl get requests.http.crossplane.io msi-manage-db -o json | jq -r '.status.response.body'
```