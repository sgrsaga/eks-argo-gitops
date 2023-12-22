# AWS EKS Complete Infrastructure project

This project will show case you some of the technologies you can use to completly configure AWS EKS cluster to host your Dockerized Kubernetes applications.

## Features

- Kubenetes platform is in AWS EKS
- Terraform is used to configure all AWS resources
- HELM provider for the Terraform is used to install utility applications for the platform
- Kubernetes provider is used to create initial resources
- GitHub Action is uses as CI/CD pipeline with Open ID Connect(OIDC)
- Kustomize is used to configure multiple environments
- Two user categories "Developer" and "Admin" also created



----------- Drafts -----------------
1. Apply the Terraform code to create the infrastructure
    This will create the EKS cluster. @ node Groups and Some AddOns such as CNI, CoreDN and kube-proxy

2. Run the command to configure the AWS CLI command for the "kubectl"
    #aws eks --region ap-south-1 update-kubeconfig --name EKS-GitOps-Cluster

3. Now need to install the Nginx-Ingress controller
    "https://github.com/kubernetes/ingress-nginx/tree/main/charts/ingress-nginx"

    #helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
    #helm repo update
    ###########helm install eks-ingress-nginx ingress-nginx/ingress-nginx
    #kubectl create ns ingress-nginx
    #helm install ingress-nginx ingress-nginx \
        --repo https://kubernetes.github.io/ingress-nginx \
        --namespace ingress-nginx \
        --set controller.metrics.enabled=true \
        --set-string controller.podAnnotations."prometheus\.io/scrape"="true" \
        --set-string controller.podAnnotations."prometheus\.io/port"="10254

4. Create sample deployment and sxpose using clusterip service
    Create deployment
    #kubectl create deploy dep1 --image=httpd --replicas=2 --port=80
    Expose deployment with service
    #kubectl expose deploy dep1 --name=my-svc --port=80 --target-port=80

5. Create Ingress Rule
    Rule will direct the traffic to "my-svc" and service will direct to one of the pods
    '''
        apiVersion: networking.k8s.io/v1
        kind: Ingress
        metadata:
        name: minimal-ingress
        annotations:
            nginx.ingress.kubernetes.io/rewrite-target: /
        spec:
        ingressClassName: nginx
        rules:
        - http:
            paths:
            - path: /testpath
                pathType: Prefix
                backend:
                service:
                    name: my-service
                    port:
                    number: 80

6. Install Promethius and Grafana

    Pre-requisites
    1. Make sure we have the Storage class with proper driver is in place.
        I added the "aws-ebs-csi-driver" add on via Terraform 
    2. We should have provided the access to the NodeGroup with "AmazonEBSCSIDriverPolicy"(arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy)
        Reference: https://www.reddit.com/r/Terraform/comments/znomk4/ebs_csi_driver_entirely_from_terraform_on_aws_eks/
        Added as Terraform resource.
    3. Now install the Prometheus
        Reference: https://docs.aws.amazon.com/eks/latest/userguide/prometheus.html
        # kubectl create namespace prometheus
        # helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
        # helm repo update prometheus-community
        # helm install my-prometheus prometheus-community/prometheus --namespace prometheus --values prometheus/values.yaml
        ## helm install prom prometheus-community/kube-prometheus-stack --namespace prometheus
        # helm upgrade -i my-prometheus prometheus-community/prometheus \
            --namespace prometheus \
            --set alertmanager.persistentVolume.storageClass="gp2",server.persistentVolume.storageClass="gp2"
