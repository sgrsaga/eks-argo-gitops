#! /bin/bash
# Check if the EKS cluster exists
cluster_status=$(aws eks describe-cluster --region $REGION --name $CLUSTER_NAME --query "cluster.status" --output text 2>/dev/null)
if [ $? -eq 0 ]; then
    # The cluster exists, and the AWS CLI command was successful
    if [ "$cluster_status" == "ACTIVE" ]; then
        # The cluster is active, so run a simple command (replace with your command)
        echo "EKS cluster is active. Configuring the kubectl environment"
        cd ../${GITHUB_REF##*/}
        aws eks --region $REGION update-kubeconfig --name $CLUSTER_NAME
        kubectl get nodes
    else
        echo "EKS cluster exists but is not yet active."
    fi
else
    # The AWS CLI command failed, indicating the cluster might not exist
    echo "EKS cluster does not exist or there was an issue retrieving its status."
fi