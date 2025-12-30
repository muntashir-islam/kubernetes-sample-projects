# Sample project for deploing HA PostgreSQL DB in Kubernetes using CNPG operator
![alt text](image.png)
Apply the Operator first
```bash
kubectl apply --server-side -f cnpg-1.28.0.yaml
```
Then Apply postgres-cluster.yaml file on pg namespace. 

```bash
kubectl get all -n pg
NAME                 READY   STATUS    RESTARTS   AGE
pod/app-postgres-1   1/1     Running   0          47s
pod/app-postgres-2   1/1     Running   0          28s

NAME                      TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
service/app-postgres-r    ClusterIP   10.96.215.37    <none>        5432/TCP   73s
service/app-postgres-ro   ClusterIP   10.96.253.235   <none>        5432/TCP   73s
service/app-postgres-rw   ClusterIP   10.96.121.151   <none>        5432/TCP   73s
```

Use rw svc for application config For example
```bash
postgres://app_user:your_password@app-postgres-rw.pg.svc.cluster.local:5432/app_db
```

here remember

```bash
rw — for all read and write transactions through the Master
ro — for read only transactions only from the Replicas
r — for read only transactions from any copy
```

To enable metrics using following
```bash
helm upgrade --install \                                     
  -f https://raw.githubusercontent.com/cloudnative-pg/cloudnative-pg/main/docs/src/samples/monitoring/kube-stack-config.yaml \
  prometheus-community \
  prometheus-community/kube-prometheus-stack
```