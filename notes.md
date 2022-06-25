 1. Install argocd
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

 2. App of apps (repo)
   1. Install Longhorn with ArgoCD app of apps (helm with prometheus exporter)
   2. Install kube-prometheus (helm)
   3. Install nginx-ingress (the kubernetes one with helm)
   4. Install cert-manager (helm)
   5. Install Keycloak (helm)
   6. Install Postgres (helm)

kubectl port-forward svc/argocd-server -n argocd 8080:443
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
argocd login <ARGOCD_SERVER>
argocd account update-password

argocd app create apps --repo https://github.com/patrickbreen/k8s-auto.git --path apps --dest-server https://kubernetes.default.svc --dest-namespace default
argocd app sync apps --prune


 3. Install custom manifests to control (repo)
   - my ingress (load balanced, ingres objects for web guis)
   - my certs (lets encrypt)
   - my prometheus/grafana customizations
 4. My App (repo)
   - app (kustomize, argocd manifests)
     - prometheus and grafana customization
   - canary (kustomize, argocd manifests) (repo)
     - prometheus and grafana cusomization
