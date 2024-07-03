# Stateful Demo for Summer School

1. PV + PVC + Stateful Pod

```
kubectl apply -f pv.yaml
kubectl apply -f pvc.yaml
kubectl apply -f server-pod-pv.yaml
kubectl apply -f client-pod.yaml
kubectl exec -i -t http-client -- /bin/bash
python3 client.py ${server_ip} 8080 # Execute this command twice, the first time will be "File Not Found", the second time will be "Hello World"
kubectl delete -f server-pod-pv.yaml
kubectl apply -f server-pod-pv.yaml
python3 client.py ${server_ip} 8080 # Execute this command will be "Hello World"
```

