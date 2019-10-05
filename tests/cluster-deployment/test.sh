#!/bin/bash

# Sourcing waiter
source ../../src/waiter.sh

# Setup

echo "Setting up db for testing..."
kubectl apply -f cluster-server.yaml
if [[ $? -ne 0 ]]; then
    echo "Failed to apply config file"
    return 1
fi
# Wait for 9 pods to be in Ready state starting with the name cluster-server
wait_for_cluster_deployment "cluster-server" 9

# Test

kubectl port-forward service/cluster-server 8529 &
PID=$!

status=$(curl --insecure -s -o /dev/null -I -w "%{http_code}" https://127.0.0.1:8529)
ret=0
if [[ $status -ne 200 ]]; then
    ret=1
fi

# Killing the port-forward
kill -9 $PID

# Cleanup
kubectl delete -f cluster-server.yaml

return $ret