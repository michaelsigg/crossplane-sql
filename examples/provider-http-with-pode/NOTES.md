# test pode rest-api

```shell
kubectl run tmp-shell -n default --rm -i --image nicolaka/netshoot -- curl -X POST http://pode.pode.svc.cluster.local:8080/databases \
-H "Authorization: Bearer dcbcb128-1c7a-4de4-b8c2-612566325d10" \
-H "Content-Type: application/json" \
-d '{ "dbname": "siggolinodb", "collation": "msicollation", "user": "siggolino" }'

```