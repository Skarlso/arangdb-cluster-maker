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

wait_for_deployment() {
    selector=$1
    spin &
    SPIN_PID=$!
    trap "kill -9 $SPIN_PID && exit 0" `seq 0 15`
    while :
    do
        output=$(kubectl get pods --field-selector=status.phase=Running --selector=${selector} -o jsonpath='{.items[*].status.phase}' | tr ' ' '\n' | uniq)
        if [ "${output}" == "Running" ]; then
            echo -e "\ncluster finished deployment"
            kill -9 $SPIN_PID
            exit 0
        fi
        sleep 0.5
    done
}

wait_for_deployment_ready_state() {
    # TODO: Implement complex search for cluster deployment ready state.
    echo "TODO"
}