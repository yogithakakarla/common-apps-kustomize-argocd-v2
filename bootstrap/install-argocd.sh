# curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
# sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
# rm argocd-linux-amd64

kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

#kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
#kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'

#kubectl wait --for=condition=available deployment/argocd-dex-server -n argocd --timeout=300s

#ARGOCD_SERVER=$(kubectl get svc argocd-server -n argocd -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
#ARGOCD_SECRET=$(kubectl get secret -n argocd argocd-initial-admin-secret -ojsonpath="{.data.password}" | base64 --decode)

#sleep 30 

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

#kubectl apply -f ./bootstrap/argo-users.yaml -f ./bootstrap/argo-rbac.yaml
#argocd login $ARGOCD_SERVER --username admin --password $ARGOCD_SECRET --insecure 
#argocd account update-password --account admin --current-password $ARGOCD_SECRET --new-password "Test1234" 



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
