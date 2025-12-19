
helm repo add hashicorp https://helm.releases.hashicorp.com
helm search repo hashicorp/consul
helm install consul hashicorp/consul --set global.name=consul --create-namespace --namespace consul