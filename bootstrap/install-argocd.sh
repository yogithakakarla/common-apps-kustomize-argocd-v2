

kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml





# Install ArgoCD cli
kubectl config set-context --current --namespace=argocd

argocd version >/dev/null
if [ $? -eq 0 ]; then 
    
    echo "argocdcli already installed..."
else 
    echo "Installing argocdcli ..."
    curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64 
    sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd 
    rm argocd-linux-amd64
fi



DATA_TO_APPEND='{"data":{"kustomize.buildOptions":"--enable-helm --load-restrictor LoadRestrictionsNone"}}'

# Patch the ConfigMap with the new data
kubectl patch configmap argocd-cm -n argocd --type merge --patch "$DATA_TO_APPEND"


DATA_TO_SET='{"data":{"applicationsetcontroller.enable.progressive.syncs":"true"}}'

# Patch the ConfigMap with the new data
kubectl patch configmap argocd-cmd-params-cm -n argocd --type merge --patch "$DATA_TO_SET"

#kubectl port-forward svc/argocd-server  8081:80
#ARGOCD_SECRET=$(kubectl get secret -n argocd argocd-initial-admin-secret -ojsonpath="{.data.password}" | base64 --decode)


#echo -e '
##############################################################
#ARGOCD_SERVER: http://localhost:8081
#ARGOCD_PASSWORD: '$ARGOCD_SECRET'
