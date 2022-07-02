# Outline of project:

App of apps (helm waves)

1. Wave 1
 * Install Longhorn with ArgoCD app of apps (helm with prometheus exporter)
 * Install kube-prometheus (helm)
 * Install ingress-nginx (the kubernetes one with helm)
 * Install cert-manager (helm)
 * Install Keycloak (helm)
 * Install Postgres (helm)
 * Install Minio (helm)

2. Wave 2
 * my certs (internal: self signed) (external: lets encrypt)
 * my ingresses
 * my prometheus/grafana customization
 * my postgres db
 * my github runner

3. Wave 3
 * my app (with ArgoRollouts) (inprogress (gauge), time (summary/histo), n requests (counter))
 * my canary (time (summary/histo), failures (counter), successes (counter))
 * App prometheus customization (ServiceMonitors)
 * custom app grafana dashboard

### Bootstrap notes:
0. Make a cluster. I used this (https://github.com/techno-tim/k3s-ansible), but you could run this pretty much anywhere, GKE, Rancher, kubespray, etc.

1. Install argocd:
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

2. Manage argocd:
```
kubectl port-forward svc/argocd-server -n argocd 8080:443
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
argocd login localhost:8080
# use this after ingress has been installed:
# argocd login argocd.dev.leetcyber.com
argocd account update-password
```

3. Point external DNS at the external ingress load balancer VIP

4. Bootstrap all the infra:
argocd app create apps --repo https://github.com/patrickbreen/k8s-auto.git --path dev/apps --dest-server https://kubernetes.default.svc --dest-namespace default
argocd app sync apps --prune

5. Cert manager failed me, so I had to manually "kubectl edit" the ingresses it created for ACME to add the right ingress class "ingressClassName: external-nginx"

6. There are a couple more things below, but that is basically it.


There was (atleast) one thing I had to manually apply this CRD manifest because argo/helm/kubernetes thought it was too long
`k create -f https://raw.githubusercontent.com/prometheus-community/helm-charts/main/charts/kube-prometheus-stack/crds/crd-prometheuses.yaml`

### Infra environment promotion strategy:
1. no auto syncing in argocd (I'm going to allow auto syncing in dev though)
2. Merge request triggers kubesec scan
3. on merge to main, pipeline deploys to dev, checks health, then deploys to prod, checks health etc.


### App repo layout:
```
app/code/
app/Dockerfile
canary/code/
canary/Dockerfile
runner/Dockerfile
```
#### On app repo merge request (also have a script.sh that can do this all locally, and pre-commit):
1. Build code and Docker image
2. Test Container (maybe parallel tests)
3. Use kustomize or helm to generate manifests for each environment with the @hash of the docker image
   And verify that the generated manifests match the pre-commit generated manifests

#### On app repo merge:
1. Push container
2. Make merge request to infra repository to update the image @hash

### Hosted github runner:
```
# Instructions here: https://github.com/actions-runner-controller/actions-runner-controller
kubectl create secret generic controller-manager -n actions-runner-system --from-literal=github_token=${GITHUB_TOKEN}
```

### Further things to do:
* storage: figure out storage replication
* db: actually handle the dbs in a safe way
* management: upgrades, HPA, pod antiaffinity, day 2 ops (automation)
* network: layer3 VIPs with BGP, more segmentation, etc.
* environments: actually run multi cluster multi environments
* security: OPA gatekeeper, falco, audit, trivy
* logging: Some centralized logging solution thing
* scaling teams: talk through how to split out teams/apps/repos, how to do multi prod.


