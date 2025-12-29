## Install istio multi cluster primary-primary setup in Kind-local environment
Install Istio as primary in cluster1 using istioctl and the IstioOperator API.
```bash
apiVersion: install.istio.io/v1alpha1
kind: IstioOperator
spec:
  values:
    global:
      meshID: mesh1
      multiCluster:
        clusterName: cluster1
      network: network1
```
Apply this
```bash
istioctl install --context="${CTX_CLUSTER1}" -f cluster1.yaml
```
Install a gateway in cluster1 that is dedicated to east-west traffic. By default, this gateway will be public on the Internet. Production systems may require additional access restrictions (e.g. via firewall rules) to prevent external attacks. Check with your cloud vendor to see what options are available.

```bash
$ multicluster/gen-eastwest-gateway.sh \
    --network network1 | \
    istioctl --context="${CTX_CLUSTER1}" install -y -f -
```

Wait for the east-west gateway to be assigned an external IP address:

```bash
$ kubectl --context="${CTX_CLUSTER1}" get svc istio-eastwestgateway -n istio-system
NAME                    TYPE           CLUSTER-IP    EXTERNAL-IP    PORT(S)                                                           AGE
istio-eastwestgateway   LoadBalancer   10.96.71.95   172.20.255.2   15021:32329/TCP,15443:32455/TCP,15012:30247/TCP,15017:31430/TCP   14h
```
Expose services in cluster1
Since the clusters are on separate networks, we need to expose all services (*.local) on the east-west gateway in both clusters. While this gateway is public on the Internet, services behind it can only be accessed by services with a trusted mTLS certificate and workload ID, just as if they were on the same network.

```bash
$ kubectl --context="${CTX_CLUSTER1}" apply -n istio-system -f \
    samples/multicluster/expose-services.yaml
```
Set the default network for cluster2

If the istio-system namespace is already created, we need to set the cluster’s network there:
```bash
$ kubectl --context="${CTX_CLUSTER2}" get namespace istio-system && \
  kubectl --context="${CTX_CLUSTER2}" label namespace istio-system topology.istio.io/network=network2
```

Now Create the istioctl configuration for cluster2:

Install Istio as primary in cluster2 using istioctl and the IstioOperator API.

```bash
apiVersion: install.istio.io/v1alpha1
kind: IstioOperator
spec:
  values:
    global:
      meshID: mesh1
      multiCluster:
        clusterName: cluster2
      network: network2
```

Apply the configuration to cluster2:

```bash
$ istioctl install --context="${CTX_CLUSTER2}" -f cluster2.yaml
```

Install the east-west gateway in cluster2
As we did with cluster1 above, install a gateway in cluster2 that is dedicated to east-west traffic.

```bash
$ multicluster/gen-eastwest-gateway.sh \
    --network network2 | \
    istioctl --context="${CTX_CLUSTER2}" install -y -f -
```
Wait for the east-west gateway to be assigned an external IP address:

```bash
$ kubectl --context="${CTX_CLUSTER2}" get svc istio-eastwestgateway -n istio-system
NAME                    TYPE           CLUSTER-IP     EXTERNAL-IP    PORT(S)                                                           AGE
istio-eastwestgateway   LoadBalancer   10.96.22.188   172.19.255.2   15021:31177/TCP,15443:32067/TCP,15012:31396/TCP,15017:30845/TCP   12h
```
Expose services in cluster2 As we did with cluster1 above, expose services via the east-west gateway.

```bash
$ kubectl --context="${CTX_CLUSTER2}" apply -n istio-system -f \
    samples/multicluster/expose-services.yaml
```
Enable Endpoint Discovery
Install a remote secret in cluster2 that provides access to cluster1’s API server.We are using controllplane-api endpoint IP

```bash
$ istioctl create-remote-secret \
  --context="${CTX_CLUSTER1}" \
  --name=cluster1 \
  --server="https://172.19.0.11:6443" | \
kubectl apply -f - --context="${CTX_CLUSTER2}"
secret/istio-remote-secret-cluster1 configured
```
Install a remote secret in cluster1 that provides access to cluster2’s API server. We are using controllplane-api endpoint IP

```bash
$ istioctl create-remote-secret \
  --context="${CTX_CLUSTER2}" \
  --name=cluster2 \
  --server="https://172.20.0.14:6443" | \
kubectl apply -f - --context="${CTX_CLUSTER1}"
```

Check sync Status
```bash
istioctl remote-clusters --context="${CTX_CLUSTER1}"
NAME         SECRET                                        STATUS     ISTIOD
cluster1                                                   synced     istiod-548bc667d4-q6bmj
cluster2     istio-system/istio-remote-secret-cluster2     synced     istiod-548bc667d4-q6bmj
```
