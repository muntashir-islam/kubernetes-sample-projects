Apply config

```bash
kubectl apply -f .
```

Test

```bash
kubectl run curl --rm -it --image=curlimages/curl -n demo -- sh

curl my-app
Hello from v1
Hello from v1
Hello from v2
```