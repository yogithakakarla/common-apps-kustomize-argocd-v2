#!/bin/bash

# Install docker	
docker --version >/dev/null;
if [ $? -eq 0 ]; then 
    echo "Docker already installed..."; 
else 
    echo "Installing Docker engine ..."; 
    apt update && apt install docker.io; 
fi


# Install kubectl
kubectl version  >/dev/null
if [ $? -eq 0 ]; then 
    echo "Kubectl already installed..."
else 
    echo "Installing kubectl ..."
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
fi
	


# Install helm
helm version >/dev/null
if [ $? -eq 0 ]; then
    echo "helm is installed already"
else
    echo "installing helm"
    curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
    chmod 700 get_helm.sh
    ./get_helm.sh
fi

# Install kustomize
kustomize  version >/dev/null
if [ $? -eq 0 ]; then
    echo "kustomize  is installed already"
else
    echo "installing kustomize"
    curl -fsSL -o "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" 
    sudo mv ./kustomize /usr/local/bin/
    kustomize version
fi


