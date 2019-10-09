#!/bin/bash

# Sourcing waiter
source ../../src/waiter.sh

# Setup

echo "Setting up db for testing..."
kubectl apply -f single-server.yaml
if [[ $? -ne 0 ]]; then
    echo "Failed to apply config file"
    return 1
fi
wait_for_deployment_ready_state "single-server"

sleep 10
echo "Forwarding port..."
kubectl port-forward service/single-server 8529 &
PID=$!
echo "PID for port-forward: ${PID}"

# need to wait a couple of seconds for the above command to run
sleep 5

# Test
echo "Performing CURL"
status=$(curl -X GET --insecure -s -o /dev/null -I -w "%{http_code}" https://127.0.0.1:8529/_db/_system/_admin/aardvark/index.html)
ret=0
if [[ $status -ne 200 ]]; then
    ret=1
fi

echo "Return status of curl is: ${status}"

# Killing the port-forward
kill -9 $PID

# Cleanup
kubectl delete -f single-server.yaml

return $ret