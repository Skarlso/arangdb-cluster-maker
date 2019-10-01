# Cluster

Creating the kind cluster:

```bash
kind create cluster --config multi_node_setup.yaml
```

# Running the arango connector

```bash
k apply -f ./arangodb/arango-crd.yaml
k apply -f ./arangodb/arango-deployment.yaml
k apply databases/single-server.yaml
```

Note, next time try multiple database deployments.

# Accessing the database

```bash
k port-forward service/single-server-ea 8529
```

Then in the browser: https://127.0.0.1:8529

Note, http will not work!

# Destroing the cluster

```bash
kind destroy cluster --config multi_node_setup.yaml
```

