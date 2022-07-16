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

6. The helm chart for kube-prometheus also failed me, so I used kubectl to install the base stack. Maybe this can be rolled into an argo Application. I'm not sure how to do that at this time because the --server-side syntax is important, and I'm not sure how to do that in an argo Application.

```
kubectl apply --server-side -f manifests/setup
until kubectl get servicemonitors --all-namespaces ; do date; sleep 1; echo ""; done
kubectl apply -f manifests/
# I also just deleted the network policies for prometheus and grafana so that my ingresses work
# security considerations understood
# again I really need to somehow version control and CD my prometheus infra
```

7. For keycloak, I'm messing with an alpha version of a keycloak operator, so it also isn't built into argoCD at this time either:

```
kubectl create -f https://operatorhub.io/install/alpha/keycloak-operator.yaml
```

8. There are a couple more things below, but that is basically it.


### Infra environment promotion strategy (todo):
1. No auto syncing in argocd (I'm going to allow auto syncing in dev though)
2. Merge request triggers kubesec scan, trivy etc.
3. On merge to main, pipeline deploys to dev, checks health, then deploys to prod, checks health etc.

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


