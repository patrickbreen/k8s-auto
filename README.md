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
 * my github runner

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

3. Point external DNS at the ingress load balancer VIP

4. Bootstrap all the infra:
argocd app create apps --repo https://github.com/patrickbreen/k8s-auto.git --path apps --dest-server https://kubernetes.default.svc --dest-namespace default
argocd app sync apps --prune

5. The end


There was one thing I had to manually apply this CRD manifest because argo/helm/kubernetes thought it was too long
`k create -f https://raw.githubusercontent.com/prometheus-community/helm-charts/main/charts/kube-prometheus-stack/crds/crd-prometheuses.yaml`

### App repo layout:
code/
Dockerfile
manifests/
  /gamma/
  /prod/

#### On merge request (also have a script.sh that can do this all locally, and pre-commit):
  1. Build code and Docker image
  2. Test Container (maybe parallel tests)
  3. Use kustomize or helm to generate manifests for each environment with the @hash of the docker image
     And verify that the generated manifests match the pre-commit generated manifests
  4. Push container

#### On merge:
  1. Make commit to main and ArgoCD will pick it up and deploy it

### Further things to do:
storage: figure out storage replication
environments: actually run multi cluster multi environments
security: OPA gatekeeper, falco, audit, trivy
logging: stuff

