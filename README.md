# Outline of projects:

App of apps (helm waves)
   1. Wave 1
    * Install Longhorn with ArgoCD app of apps (helm with prometheus exporter)
    * Install kube-prometheus (helm)
    * Install nginx-ingress (the kubernetes one with helm)
    * Install cert-manager (helm)
    * Install Keycloak (helm)
    * Install Postgres (helm)
    * Install Minio (helm)
   2. Wave 2
    * my certs (lets encrypt)
    * my ingresses
    * my prometheus/grafana customization
    * my postgres db
   3. Wave 3
    * my app
    * my canary

### Bootstrap notes:
 1. Install argocd:
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

2. Manage argocd:
kubectl port-forward svc/argocd-server -n argocd 8080:443
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
argocd login <ARGOCD_SERVER>
argocd account update-password

3. Bootstrap all the infra:
argocd app create apps --repo https://github.com/patrickbreen/k8s-auto.git --path apps --dest-server https://kubernetes.default.svc --dest-namespace default
argocd app sync apps --prune

4. Point external DNS at the ingress load balancer VIP

5. The end
