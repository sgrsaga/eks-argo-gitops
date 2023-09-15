# 1. Create a VPC
vpc_name              = "K8S_VPC"
vpc_cidr              = "10.0.0.0/16"
public_source_cidr    = ["0.0.0.0/0"]
public_source_cidr_v6 = ["::/0"]
#azs = ["ap-south-1a","ap-south-1b","ap-south-1c"]

# 2. Create a Internet Gateway
ig_name = "K8S_IG"

# 1.3. Create 2 Route tables
public_rt  = "PUBLIC_RT"
private_rt = "PRIVATE_RT"

# 1.4. Create 3 Public Subnets
public_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
# 1.5. Create 3 Private Subnets
private_subnets = ["10.0.5.0/24", "10.0.6.0/24", "10.0.7.0/24"]

# 1.6. Create Public access Security Group
public_access_sg_ingress_rules = [
  {
    protocol  = "-1"
    from_port = 0
    to_port   = 0
  }
]

### ----------- EC2 nodes
ami_id         = "ami-0f5ee92e2d63afc18"
ec2_node_cnt   = 1
ssh_key_name   = "NewKey"
instance_type  = "t2.micro"
role_name      = "admin"
root_sorage = 30
master_names = ["Master1"]
master_type = "t2.medium"
worker_names = ["Worker_1","Worker_2"]
worker_type = "t2.micro"
user_data_file = <<UDT
#!/bin/bash
### K8S cluster nodes
sudo apt-get update
sudo apt install net-tools -y
# check MAC
ip link show
# check product_uuid 
sudo cat /sys/class/dmi/id/product_uuid

### K8S Install
##Update the apt package index and install packages needed to use the Kubernetes apt repository:
#sudo apt-get update
#sudo apt-get install -y apt-transport-https ca-certificates curl
##Download the Google Cloud public signing key:
#curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-archive-keyring.gpg
##Add the Kubernetes apt repository:
#echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
##Update apt package index, install kubelet, kubeadm and kubectl, and pin their version:
#sudo apt-get update
#sudo apt-get install -y kubelet kubeadm kubectl
#sudo apt-mark hold kubelet kubeadm kubectl

## Swap Off
swapoff -a
sed -i '/swap/d' /etc/fstab

###########################################
# Forwarding IPv4 and letting iptables see bridged traffic
###########################################
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# sysctl params required by setup, params persist across reboots
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Apply sysctl params without reboot
sudo sysctl --system

sysctl net.bridge.bridge-nf-call-iptables net.bridge.bridge-nf-call-ip6tables net.ipv4.ip_forward

###########################################
# Insytall containerd
###########################################

#Set up the repository
#Update the apt package index and install packages to allow apt to use a repository over HTTPS:
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg
#Add Docker’s official GPG key:
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
#Use the following command to set up the repository:
echo "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
# Install containerd
sudo apt-get install -y containerd.io



#### Container runtime configuration setup
#sudo vi /etc/containerd/config.toml
sudo su
cat << EOF > /etc/containerd/config.toml
[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
  [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
    SystemdCgroup = true
EOF
exit
#Add:
#[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
#  [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
#    SystemdCgroup = true

# Restart containerd
sudo systemctl restart containerd


## Install kubeadm
#Update the apt package index and install packages needed to use the Kubernetes apt repository:
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl

#Download the Google Cloud public signing key:
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-archive-keyring.gpg

#Add the Kubernetes apt repository:
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

#Update apt package index, install kubelet, kubeadm and kubectl, and pin their version:
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl



UDT

/*
### ------------- Database related Variables
db_identifier = "eurolegue-db"
db_backup_retention_period = 7
db_class = "db.m6g.large"
db_delete_protect = "false"
db_engine = "postgres"
db_engine_version = "12.9"
db_name = "Project_db"
db_para_group_name = "default.postgres12"
db_pass = "Test-NotHere"
db_storage = 100
db_storage_type = "gp2"
db_username = "Project"
is_storage_encrypted = "true"
max_allocated_storage_value = 500
muli_az_enable = "true"
## Proxy name
db_proxy_name = "Project-db-proxy" 
## Proxy debug_logging
proxy_debug_login = "true"
## Engine Family
db_engin_family = "POSTGRESQL"
## Idel Timeout
db_proxy_idle_timeout = 1800
## proxy tls enable
tls_require = "false"  
## proxy security group
db_proxy_secret_arn = "arn:aws:secretsmanager:ca-central-1:123456789:secret:Project/db/cred-JWAyzF"
## Proxy IAM role ARV
db_proxy_role = "arn:aws:iam::285308278095:role/rds-proxy-role"

################### Cognito ############
pool_name = "Project"
client_name = "Project_client"
d_prefix = "Project_123456789"
################# DB Proxy with Proxy module ###############
kms_key_id = "44e856ea-5258-47a0-80f9-44c4ec486cf4"
env_id = "Dev"

*/