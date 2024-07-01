#!/bin/bash

# Define variables
SUBMISSION_DIR="/home/myc/workspace/quiz/submissions-test"
PROJECT_DIR="/home/myc/workspace/quiz"
EXPECTED_SUBSTRING="Hello World"
RESULT_FILE="${PROJECT_DIR}/grading_results.csv"
TIMEOUT=30  # Timeout in seconds

# Create the result file and add headers
echo "student_name,student_id,passed" > $RESULT_FILE

# Function to find the project root directory
find_project_root() {
    local search_dir=$1
    local project_root=$(find "$search_dir" -type d -name "kube-yaml" -print -quit)
    echo $(dirname "$project_root")
}

# Function to wait for a pod to be in running status
wait_for_pod() {
    local pod_name=$1
    local start_time=$(date +%s)
    while true; do
        pod_status=$(kubectl get pod $pod_name -o jsonpath="{.status.phase}")
	echo $pod_status
        if [[ "$pod_status" == "Running" ]]; then
            return 0
        fi
        current_time=$(date +%s)
        if (( current_time - start_time > TIMEOUT )); then
            return 1
        fi
        sleep 2
    done
}

# Pre-cleaning function to kill any existing port-forward processes and remove temp_submission folder
pre_clean() {
    # Kill any existing port-forward processes
    pkill -f "kubectl port-forward" 2>/dev/null
    
    # Remove the temp_submission folder if it exists
    sudo rm -rf temp_submission

    kubectl delete pod http-server http-proxy
}

# Loop through each submission
for SUBMISSION_ZIP in $SUBMISSION_DIR/*.zip; do
    # Pre-cleaning before processing each submission
    pre_clean
    
    # Extract student name and id from the file name
    FILE_NAME=$(basename -- "$SUBMISSION_ZIP")
    STUDENT_NAME=$(echo $FILE_NAME | cut -d'_' -f1)
    STUDENT_ID=$(echo $FILE_NAME | cut -d'_' -f4 | cut -d'.' -f1)
    
    # Unzip the student's submission
    unzip "$SUBMISSION_ZIP" -d temp_submission
    rm -rf temp_submission/__MACOSX
    
    # Find the project root directory
    PROJECT_ROOT=$(find_project_root temp_submission)
    
    # Check if the project root is found inside a subfolder
    if [ -z "$PROJECT_ROOT" ]; then
        # Try to locate subfolders and find the project root again
        for SUBFOLDER in temp_submission/*/; do
            PROJECT_ROOT=$(find_project_root "$SUBFOLDER")
            if [ -n "$PROJECT_ROOT" ]; then
                break
            fi
        done
    fi
    
    # If project root is still not found, mark as failed and continue to next submission
    if [ -z "$PROJECT_ROOT" ]; then
        echo "$STUDENT_NAME,$STUDENT_ID,failed" >> $RESULT_FILE
        rm -rf temp_submission
        continue
    fi
    
    # Navigate to the project root directory
    cd "$PROJECT_ROOT"
    
    # Step 1: Deploy to Kubernetes
    kubectl apply -f kube-yaml/server-pod.yaml
    kubectl apply -f kube-yaml/proxy-pod.yaml
    
    # Wait for the server pod to be running
    if ! wait_for_pod "http-server"; then
        echo "$STUDENT_NAME,$STENT_ID,failed" >> $RESULT_FILE
        kubectl delete -f kube-yaml/server-pod.yaml
        kubectl delete -f kube-yaml/proxy-pod.yaml
        cd $PROJECT_DIR
        sudo rm -rf temp_submission
        continue
    fi
    
    # Wait for the proxy pod to be running
    if ! wait_for_pod "http-proxy"; then
        echo "$STUDENT_NAME,$STUDENT_ID,failed" >> $RESULT_FILE
        kubectl delete -f kube-yaml/server-pod.yaml
        kubectl delete -f kube-yaml/proxy-pod.yaml
        cd $PROJECT_DIR
        sudo rm -rf temp_submission
        continue
    fi
    
    # Step 2: Set up port-forwarding
    kubectl port-forward --address 0.0.0.0 http-proxy 8881:8888 &
    PORT_FORWARD_PID=$!
    
    # Step 3: Get Server IP
    SERVER_IP=$(kubectl get pod http-server --template "{{.status.podIP}}")
    
    # Step 4: Run the client and check output
    OUTPUT=$(python3 client/client.py localhost 8881 ${SERVER_IP} 8080 "${EXPECTED_SUBSTRING}")
    echo $OUTPUT
    
    # Kill the port-forward process
    kill $PORT_FORWARD_PID
    
    # Check the output and determine if the student passed
    if [[ "$OUTPUT" == *"$EXPECTED_SUBSTRING"* ]]; then
        PASSED="passed"
    else
        PASSED="failed"
    fi
    
    # Log the result to the CSV file
    echo "$STUDENT_NAME,$STUDENT_ID,$PASSED"
    echo "$STUDENT_NAME,$STUDENT_ID,$PASSED" >> $RESULT_FILE
    
    # Cleanup Kubernetes resources
    kubectl delete -f kube-yaml/server-pod.yaml
    kubectl delete -f kube-yaml/proxy-pod.yaml
    
    # Navigate back to the project directory and cleanup
    cd $PROJECT_DIR
    sudo rm -rf temp_submission
done

echo "Grading completed. Results are saved in $RESULT_FILE."

