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

sleep 20

kubectl get crd gateways.gateway.networking.k8s.io &> /dev/null || \
  kubectl apply --server-side -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.4.0/experimental-install.yaml


helm repo add istio https://istio-release.storage.googleapis.com/charts
helm repo update

# # Install Istio
curl -L https://istio.io/downloadIstio | sh -
export ISTIO_VERSION=1.28.1 # Replace with the latest version you downloaded
export PATH="$PWD/istio-$ISTIO_VERSION/bin:$PATH"
istioctl install --set profile=demo -y

sleep 30

kubectl label namespace default istio-injection=enabled
kubectl apply -f istio-1.28.2/samples/bookinfo/platform/kube/bookinfo.yaml
kubectl apply -f istio-1.28.2/samples/bookinfo/gateway-api/bookinfo-gateway.yaml
kubectl annotate gateway bookinfo-gateway networking.istio.io/service-type=ClusterIP --namespace=default
