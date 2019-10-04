# Cluster

Before you begin, of using Docker toolbox, make sure that the virtual machine used by it, has at least 8GB ram and
2 cores. Otherwise the deployment will fail and eat up the docker client.

## Examples

Example:

```bash
./cluster.sh --config=multi_node_setup.yaml wizard
```

```bash
# Creates the replication deployment and the storage
./cluster.sh -s -r --config=multi_node_setup.yaml wizard
```

```bash
# Different version than master
./cluster.sh -v=v1.1.1 --config=multi_node_setup.yaml wizard
```

```bash
# Default values
./cluster.sh wizard
```

```bash
# Individual commands
./cluster.sh create-cluster
# Export the cluster config
export KUBECONFIG="$(kind get kubeconfig-path --name="kind")"
# Deploy arango resources
./cluster.sh deploy
```

Running tests

```bash
./cluster.sh test
```

Ignoring tests is as easy as prefixing a folder with `ignore_`.

## Accessing the database

```bash
k port-forward service/single-server-ea 8529
```

This is needed because it's much less problematic to ping this then dealing with docker and ip addresses.

Then in the browser: https://127.0.0.1:8529

Note, http will not work!

# Waiters

If this has value:

```
kubectl get arangodeployment/cluster-server -o=jsonpath='{range .status.members.agents[*]}{.conditions}{"\n"}{end}'
```

That means that the objects are created and the pods are initializing. Now we need to wait for the pods to be Phase Ready.