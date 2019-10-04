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

kill_spinner() {
    pid=$1
    if ps -p $pid > /dev/null; then
        kill -9 $pid > /dev/null
    fi
    exit 0
}

# This should not used for tests where there are more complex deployments
# and we need to wait for a ready state 1/1.
wait_for_deployment() {
    selector=$1
    spin &
    SPIN_PID=$!

    trap "kill_spinner ${SPIN_PID}" `seq 0 15`
    while :
    do
        output=$(kubectl get pods --field-selector=status.phase=Running --selector=${selector} -o jsonpath='{.items[*].status.phase}' | tr ' ' '\n' | uniq)
        if [ "${output}" == "Running" ]; then
            echo -e "\ncluster finished deployment"
            kill -9 $SPIN_PID
            break
        fi
        sleep 0.5
    done
}

wait_for_deployment_ready_state() {
    name=$1

    spin &
    SPIN_PID=$!

    trap "kill_spinner ${SPIN_PID}" `seq 0 15`
    # TODO: Implement complex search for cluster deployment ready state.
    JSONPATH='{range .items[*]}{@.metadata.name}:{range @.status.conditions[*]}{@.type}={@.status};{end}{end}'
    while :
    do
        kubectl get arangodeployment/${name} -o=jsonpath='{range .status.members.agents[*]}{.phase}' | grep -v "Created"
        if [[  $? -eq 0 ]]; then
            echo "All pods are in Ready 1/1 state."
            kill -9 $SPIN_PID
            break
        fi
    done
}

wait_for_arango_deployment() {
    name=$1

}