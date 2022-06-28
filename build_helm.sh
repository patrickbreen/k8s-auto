helm template wave2-infra-dev ./wave2-infra -f ./wave2-infra/dev-values.yaml > ./dev/wave2-infra/manifest.yaml
helm template wave3-app-tasks-dev ./wave3-app-tasks -f ./wave3-app-tasks/dev-values.yaml > ./dev/wave3-app-tasks/manifest.yaml
git add dev/wave2-infra/manifest.yaml
git add dev/wave3-app-tasks/manifest.yaml


