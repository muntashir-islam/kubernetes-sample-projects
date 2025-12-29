# Create Kind network if needed
docker network create kind || true

# Wait for the cluster to clean up
sleep 2

# Create Kind cluster with three worker nodes
echo "Creating Kind cluster with three worker nodes..."
kind create cluster --name cluster1 --config - <<EOF
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
- role: worker
- role: worker
- role: worker
EOF

helm repo add istio https://istio-release.storage.googleapis.com/charts
helm repo add metallb https://metallb.github.io/metallb
helm repo update

# Install MetalLB
helm upgrade --wait --install metallb metallb/metallb --namespace metallb-system --create-namespace

echo "Waiting for MetalLB to stabilize..."

sleep 80

KIND_NET_CIDR=$(docker network inspect kind -f '{{(index .IPAM.Config 0).Subnet}}')
KIND_NET_BASE=$(echo "${KIND_NET_CIDR}" | cut -d'.' -f1-2 )
METALLB_IP_START="${KIND_NET_BASE}.255.1"
METALLB_IP_END="${KIND_NET_BASE}.255.10"
METALLB_IP_RANGE="${METALLB_IP_START}-${METALLB_IP_END}"

kubectl apply -f - <<EOF
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  namespace: metallb-system
  name: default-address-pool
spec:
  addresses:
  - ${METALLB_IP_RANGE}
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  namespace: metallb-system
  name: default
EOF