#!/bin/bash


# Default values of arguments
VERSION="master"
CONFIG="master_cluster.yaml"
STORAGE=0
REPLICATION=0
MANIFESTS=""
TEST_NAME=""

create_cluster() {
    echo "Creating cluster"
    kind create cluster --config ${CONFIG}
    if [ $? != 0 ]; then
        echo "Error when creating cluster..."
        exit $?
    fi
    kubectl cluster-info --context kind-kind
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

    if [[ ! -z "${MANIFESTS}" ]]; then
        echo "Using manifest folder to apply configuration files."
        kubectl apply -f "${MANIFESTS}"
    else
        echo "Creating deployment from upstream with version ${VERSION}"
        kubectl apply -f https://raw.githubusercontent.com/arangodb/kube-arangodb/${VERSION}/manifests/arango-crd.yaml
        kubectl apply -f https://raw.githubusercontent.com/arangodb/kube-arangodb/${VERSION}/manifests/arango-deployment.yaml
        if [ $STORAGE -eq 1 ]; then
            kubectl apply -f https://raw.githubusercontent.com/arangodb/kube-arangodb/${VERSION}/manifests/arango-storage.yaml
        fi
        if [ $REPLICATION -eq 1 ]; then
            kubectl apply -f https://raw.githubusercontent.com/arangodb/kube-arangodb/${VERSION}/manifests/arango-deployment-replication.yaml
        fi
    fi
    wait_for_deployment "app.kubernetes.io/name=kube-arangodb"
}

test_deployment() {
    echo "Running tests."
    if [[ ! -z "${TEST_NAME}" ]]; then
        dir="./tests/${TEST_NAME}"
        if [[ ! -d "${dir}" ]]; then
            echo "Test with name ${TEST_NAME} does not exist."
            exit 1
        fi
        (
            cd $dir
            source test.sh
            if [[ $? -ne 0 ]]; then
                echo -e "Test \033[1m\033[02;91mFailed!\033[0m"
                exit 1
            fi
            echo -e "Test \033[1m\033[02;92mPassed!\033[0m"
            exit 0
        )
    else
        for dir in ./tests/*/
        do
            dir=${dir%*/}
            if [[ $dir == *"ignore_"* ]]; then
                continue
            fi
            (
                echo -e "Running test under \033[1m${dir}\033[0m"
                cd $dir
                source test.sh
                if [[ $? -ne 0 ]]; then
                    echo -e "Test \033[1m\033[02;91mFailed!\033[0m"
                    exit 1
                fi
                echo -e "Test \033[1m\033[02;92mPassed!\033[0m"
            )
        done
    fi
}

wizard() {
    create_cluster
    create_arango_deployment
}

source src/waiter.sh

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
        -m=*|--manifests=*)
        MANIFESTS="${arg#*=}"
        shift # manifests --manifests= setup a folder from where to apply arango manifest files
        ;;
        -t=*|--test-name=*)
        TEST_NAME="${arg#*=}"
        shift # test name --test-name= run a single test with folder name x
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
        test)
        test_deployment
        ;;
        *)
        OTHER_ARGUMENTS+=("$1")
        shift # Remove generic argument from processing
        ;;
    esac
done
