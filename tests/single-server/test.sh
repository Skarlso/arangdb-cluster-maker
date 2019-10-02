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
wait_for_deployment "arango_deployment=single-server"

# Test

# get exposed port and ip
# do a curl
# do basic auth

# If something fails... exit 1

kubectl delete -f single-server.yaml

return 0