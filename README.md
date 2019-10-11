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

`kubectl get pods -o name | grep cluster-server`

# Test

First passing test:

```
 $ ./cluster.sh test

 _______  _______  _______  _        _______  _______  ______   ______     _______  _                 _______ _________ _______  _______
(  ___  )(  ____ )(  ___  )( (    /|(  ____ \(  ___  )(  __  \ (  ___ \   (  ____ \( \      |\     /|(  ____ \__   __/(  ____ \(  ____ )
| (   ) || (    )|| (   ) ||  \  ( || (    \/| (   ) || (  \  )| (   ) )  | (    \/| (      | )   ( || (    \/   ) (   | (    \/| (    )|
| (___) || (____)|| (___) ||   \ | || |      | |   | || |   ) || (__/ /   | |      | |      | |   | || (_____    | |   | (__    | (____)|
|  ___  ||     __)|  ___  || (\ \) || | ____ | |   | || |   | ||  __ (    | |      | |      | |   | |(_____  )   | |   |  __)   |     __)
| (   ) || (\ (   | (   ) || | \   || | \_  )| |   | || |   ) || (  \ \   | |      | |      | |   | |      ) |   | |   | (      | (\ (
| )   ( || ) \ \__| )   ( || )  \  || (___) || (___) || (__/  )| )___) )  | (____/\| (____/\| (___) |/\____) |   | |   | (____/\| ) \ \__
|/     \||/   \__/|/     \||/    )_)(_______)(_______)(______/ |/ \___/   (_______/(_______/(_______)\_______)   )_(   (_______/|/   \__/

Running tests.
Running test under ./tests/cluster-deployment
Setting up db for testing...
arangodeployment.database.arangodb.com/cluster-server created
Waiting for name: cluster-server and pod count: 9
Error from server (NotFound): pods "cluster-server-crdn-hrilbu19-20ce4e" not found
Error from server (NotFound): pods "cluster-server-crdn-3oit0n1c-20ce4e" not found
Error from server (NotFound): pods "cluster-server-id-b026ee" not found
All pods are in Ready 1/1 state.nish...
Forwarding port...
PID for port-forward: 74781
Forwarding from 127.0.0.1:8529 -> 8529
Forwarding from [::1]:8529 -> 8529
Performing CURL
Handling connection for 8529
Return status of curl is: 200
arangodeployment.database.arangodb.com "cluster-server" deleted
Test Passed!
```

For cluster deployment.

Running a single test case:

```
./cluster.sh -t=single-server test
```

# TODOS

Just parse for `1/1` with awk. To be precise `x/x`.
