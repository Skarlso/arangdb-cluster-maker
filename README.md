# Cluster

The tool:

```
$ python cluster.py --help

 _______  _______  _______  _        _______  _______  ______   ______     _______  _                 _______ _________ _______  _______
(  ___  )(  ____ )(  ___  )( (    /|(  ____ \(  ___  )(  __  \ (  ___ \   (  ____ \( \      |\     /|(  ____ \__   __/(  ____ \(  ____ )
| (   ) || (    )|| (   ) ||  \  ( || (    \/| (   ) || (  \  )| (   ) )  | (    \/| (      | )   ( || (    \/   ) (   | (    \/| (    )|
| (___) || (____)|| (___) ||   \ | || |      | |   | || |   ) || (__/ /   | |      | |      | |   | || (_____    | |   | (__    | (____)|
|  ___  ||     __)|  ___  || (\ \) || | ____ | |   | || |   | ||  __ (    | |      | |      | |   | |(_____  )   | |   |  __)   |     __)
| (   ) || (\ (   | (   ) || | \   || | \_  )| |   | || |   ) || (  \ \   | |      | |      | |   | |      ) |   | |   | (      | (\ (
| )   ( || ) \ \__| )   ( || )  \  || (___) || (___) || (__/  )| )___) )  | (____/\| (____/\| (___) |/\____) |   | |   | (____/\| ) \ \__
|/     \||/   \__/|/     \||/    )_)(_______)(_______)(______/ |/ \___/   (_______/(_______/(_______)\_______)   )_(   (_______/|/   \__/

Usage: cluster.py [OPTIONS] COMMAND [ARGS]...

Options:
  --help  Show this message and exit.

Commands:
  add-db
  create-arango-deployment
  create-cluster
  destroy-cluster
  wizard
```

## Creating the cluster and the deployment in one wizard

```
$ python cluster.py wizard --config multi_node_setup.yaml

 _______  _______  _______  _        _______  _______  ______   ______     _______  _                 _______ _________ _______  _______
(  ___  )(  ____ )(  ___  )( (    /|(  ____ \(  ___  )(  __  \ (  ___ \   (  ____ \( \      |\     /|(  ____ \__   __/(  ____ \(  ____ )
| (   ) || (    )|| (   ) ||  \  ( || (    \/| (   ) || (  \  )| (   ) )  | (    \/| (      | )   ( || (    \/   ) (   | (    \/| (    )|
| (___) || (____)|| (___) ||   \ | || |      | |   | || |   ) || (__/ /   | |      | |      | |   | || (_____    | |   | (__    | (____)|
|  ___  ||     __)|  ___  || (\ \) || | ____ | |   | || |   | ||  __ (    | |      | |      | |   | |(_____  )   | |   |  __)   |     __)
| (   ) || (\ (   | (   ) || | \   || | \_  )| |   | || |   ) || (  \ \   | |      | |      | |   | |      ) |   | |   | (      | (\ (
| )   ( || ) \ \__| )   ( || )  \  || (___) || (___) || (__/  )| )___) )  | (____/\| (____/\| (___) |/\____) |   | |   | (____/\| ) \ \__
|/     \||/   \__/|/     \||/    )_)(_______)(_______)(______/ |/ \___/   (_______/(_______/(_______)\_______)   )_(   (_______/|/   \__/

Creating cluster and deploying arango deployments.
exporting cluster settings
exporting kind config path /Users/hannibal/.kube/kind-config-kind
Creating cluster done... deploying arango
done.
run kind get kubeconfig-path --name="kind" to setup your local shell for the cluster
```

## Can call creation individually if desired

```
$ python cluster.py create-cluster --config multi_node_setup.yaml
```

```
$ python cluster.py create_arango_deployment --version master --storage --replication
```

## Deploy the DB

```
python cluster.py add-db --config arangodb/single-server.yaml
```

# Accessing the database

```bash
k port-forward service/single-server-ea 8529
```

Then in the browser: https://127.0.0.1:8529

Note, http will not work!

# Bash version

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
