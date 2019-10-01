#!/bin/bash


# Default values of arguments
VERSION="master"
CONFIG="master-cluster.yaml"
STORAGE=0
REPLICATION=0

create_cluster() {
    echo "Creating cluster"
    kind create cluster --config ${CONFIG}
    if [ $? != 0 ]; then
        echo "Error when creating cluster..."
        exit $?
    fi
    export KUBECONFIG="$(kind get kubeconfig-path)"
}

delete_cluster() {
    echo "Delete cluster"
    kind delete cluster
    if [ $? != 0 ]; then
        echo "Error when deleting cluster..."
        exit $?
    fi
}

create_arango_deployment() {
    echo "Creating deployment"
    kubectl apply -f https://raw.githubusercontent.com/arangodb/kube-arangodb/${VERSION}/manifests/arango-crd.yaml
    kubectl apply -f https://raw.githubusercontent.com/arangodb/kube-arangodb/${VERSION}/manifests/arango-deployment.yaml
    if [ $STORAGE -eq 1 ]; then
        kubectl apply -f https://raw.githubusercontent.com/arangodb/kube-arangodb/${VERSION}/manifests/arango-storage.yaml
    fi
    if [ $REPLICATION -eq 1 ]; then
        kubectl apply -f https://raw.githubusercontent.com/arangodb/kube-arangodb/${VERSION}/manifests/arango-deployment-replication.yaml
    fi
    wait_for_cluster
}

spin()
{
    spinner="/|\\-/|\\-"
    while :
    do
        for i in `seq 0 7`
        do
            echo -e "\r[${spinner:$i:1}] Waiting for deployment to finish..."
            echo -en "\033[1A"
            sleep 1
        done
    done
}

wait_for_cluster() {
    spin &
    SPIN_PID=$!
    trap "kill -9 $SPIN_PID && exit 0" `seq 0 15`
    while :
    do
        output=$(kubectl get pods --field-selector=status.phase=Running -o jsonpath='{.items[*].status.phase}' | tr ' ' '\n' | uniq)
        if [ "${output}" == "Running" ]; then
            echo -e "\ncluster finished deployment"
            kill -9 $SPIN_PID
            exit 0
        fi
        sleep 0.5
    done
}

wizard() {
    create-cluster
    create-arango-deployment
}

echo "
 _______  _______  _______  _        _______  _______  ______   ______     _______  _                 _______ _________ _______  _______
(  ___  )(  ____ )(  ___  )( (    /|(  ____ \(  ___  )(  __  \ (  ___ \   (  ____ \( \      |\     /|(  ____ \\__   __/(  ____ \(  ____ )
| (   ) || (    )|| (   ) ||  \  ( || (    \/| (   ) || (  \  )| (   ) )  | (    \/| (      | )   ( || (    \/   ) (   | (    \/| (    )|
| (___) || (____)|| (___) ||   \ | || |      | |   | || |   ) || (__/ /   | |      | |      | |   | || (_____    | |   | (__    | (____)|
|  ___  ||     __)|  ___  || (\ \) || | ____ | |   | || |   | ||  __ (    | |      | |      | |   | |(_____  )   | |   |  __)   |     __)
| (   ) || (\ (   | (   ) || | \   || | \_  )| |   | || |   ) || (  \ \   | |      | |      | |   | |      ) |   | |   | (      | (\ (
| )   ( || ) \ \__| )   ( || )  \  || (___) || (___) || (__/  )| )___) )  | (____/\| (____/\| (___) |/\____) |   | |   | (____/\| ) \ \__
|/     \||/   \__/|/     \||/    )_)(_______)(_______)(______/ |/ \___/   (_______/(_______/(_______)\_______)   )_(   (_______/|/   \__/
"

# Checking if necessary binaries exist
if ! [ -x "$(command -v kind)" ]; then
echo 'kind not installed.' >&2
exit 1
fi

if ! [ -x "$(command -v kubectl)" ]; then
echo 'kubectl not installed.' >&2
exit 1
fi

# Loop through arguments and process them
for arg in "$@"
do
    case $arg in
        -s|--storage)
        STORAGE=1
        shift # storage --setup persistent storage
        ;;
        -r|--replication)
        REPLICATION=1
        shift # replication --deploy arangodb replication
        ;;
        -v=*|--version=*)
        VERSION="${arg#*=}"
        shift # version --version= to define what version to deploy
        ;;
        -o=*|--config=*)
        CONFIG="${arg#*=}"
        shift # config --config= the config file to use to create the cluster
        ;;
        create-cluster)
        create_cluster
        ;;
        delete-cluster)
        delete_cluster
        ;;
        deploy)
        create_arango_deployment
        ;;
        wizard)
        wizard
        ;;
        *)
        OTHER_ARGUMENTS+=("$1")
        shift # Remove generic argument from processing
        ;;
    esac
done
