default:
	@echo "Use one of the options below:"
	@echo "- pre : Install all pre-requsites like docker, kubectl, argocdcli,helm ,kustomize"
	@echo "- install-argocd: Install ArgoCD."
	@echo "- install-commonapps: Install commonapps."




pre: 
	@# Install pre-requsites like docker, k8s, argocdcli
	@bash ./bootstrap/install-prereq.sh





install-argocd: ## Install ArgoCD
	@echo "Installing ArgoCD"
	@cd bootstrap && bash install-argocd.sh




install-commonapps: ## Install common apps using argocdmanifest
	@echo "Installing apps"
	@cd helm-chart &&  helm install argocd-apps .  && argocd app list
