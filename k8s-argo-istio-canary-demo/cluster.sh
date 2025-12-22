# Create Kind network if needed
docker network create kind || true
# Delete Kind cluster if it exists
kind delete cluster || true

# Wait for the cluster to clean up
sleep 2

# Create Kind cluster with three worker nodes
echo "Creating Kind cluster with three worker nodes..."
kind create cluster --config - <<EOF
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
- role: worker
- role: worker
- role: worker
EOF

sleep 10

# # Install Istio
curl -L https://istio.io/downloadIstio | sh -
export ISTIO_VERSION=1.28.1 # Replace with the latest version you downloaded
export PATH="$PWD/istio-$ISTIO_VERSION/bin:$PATH"
istioctl install --set profile=demo -y

# Label namespace for Istio Sidecar Injection
kubectl label namespace default istio-injection=enabled
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.28/samples/addons/prometheus.yaml


#Install ArgoCD
kubectl create namespace argocd
kubectl apply -n argocd \
  -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

kubectl create namespace argo-rollouts
kubectl apply -n argo-rollouts \
  -f https://github.com/argoproj/argo-rollouts/releases/latest/download/install.yaml