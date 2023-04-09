
# install cert-manager
k apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.11.0/cert-manager.yaml

# install ingress (just internal with self signed cert for dev env)
helm upgrade ingress-nginx ingress-nginx --install \
  --repo https://kubernetes.github.io/ingress-nginx \
  --namespace ingress-nginx --create-namespace \
  --values ./ingress_values.yaml # TODO change this to use repo values.yaml

# install longhorn
k patch storageclass local-path -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
k apply -f https://raw.githubusercontent.com/longhorn/longhorn/v1.4.1/deploy/longhorn.yaml

# TODO wait for longhorn pods to be available

# install minio
helm upgrade minio minio --install \
  --repo https://charts.bitnami.com/bitnami \
  --namespace minio --create-namespace \
  --values ./minio_values.yaml  # TODO change this to use repo values.yaml

# install zalando postgres operator (maybe just use a 'simple' posgress statefulset instead?)
k create namespace zalando-postgres-operator
k -n zalando-postgres-operator create -f https://raw.githubusercontent.com/zalando/postgres-operator/master/manifests/configmap.yaml
k -n zalando-postgres-operator create -f https://raw.githubusercontent.com/zalando/postgres-operator/master/manifests/operator-service-account-rbac.yaml
k -n zalando-postgres-operator create -f https://raw.githubusercontent.com/zalando/postgres-operator/master/manifests/postgres-operator.yaml
k -n zalando-postgres-operator create -f https://raw.githubusercontent.com/zalando/postgres-operator/master/manifests/api-service.yaml

# TODO - go back and make sure that we get postgres-exporters working

# cluster issuers
k apply -f cluster_issuers.yaml # TODO change this to use repo cluster-issuers.yaml

# keycloak operator
k create namespace my-keycloak-operator
k -n my-keycloak-operator apply -f https://raw.githubusercontent.com/keycloak/keycloak-k8s-resources/21.0.1/kubernetes/keycloaks.k8s.keycloak.org-v1.yml
k -n my-keycloak-operator apply -f https://raw.githubusercontent.com/keycloak/keycloak-k8s-resources/21.0.1/kubernetes/keycloakrealmimports.k8s.keycloak.org-v1.yml
k -n my-keycloak-operator apply -f https://raw.githubusercontent.com/keycloak/keycloak-k8s-resources/21.0.1/kubernetes/kubernetes.yml



# keycloak objects
kubectl create secret generic keycloak-db-secret \
  --from-literal=username=postgress \
  --from-literal=password=mysecretpassword
k -n my-keycloak-operator apply -f ./keycloak_objects.yaml # TODO change this to repo file


# prometheus operator stack (monitoring namespace)
helm upgrade kube-prometheus-stack kube-prometheus-stack --install \
  --repo https://prometheus-community.github.io/helm-charts \
  --namespace monitoring --create-namespace \
  # --values ./prometheus_values.yaml  # TODO change this to use repo .yaml

k apply -f permissions_for_prom_operator.yaml # TODO change this to use repo .yaml

# install service monitors for all previously installed services
k apply -f service_monitors.yaml # TODO change this to use repo .yaml

# ingresses (all internal for dev) for all previously installed services
k apply -f ingresses.yaml # TODO change this to use repo ingresses.yaml

###########################################################################
# TODO validate the above works, can go to UI in browser via ingress, etc
# always use the existing, although outdated, repo as a guide
###########################################################################

# try new things - knative or some serverless, and gateway

# TODO centralized persistent logging (loki?)


# TODO application (canary, deployment, )