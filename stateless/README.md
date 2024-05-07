## Stateless Quiz for Summer School

### Run as Host Machine Process

1. Run HTTP Server: 

```
python3 app.py # run a server on port 8080
```

2. Access HTTP Server:

```
python3 client.py localhost 8080 # or access from browser: localhost:8080

```

### Run as Docker Container


1. Build and push App Image to Dockerhub:

```
docker build -t ${user}/app .
docker push ${user}/app
```



2. Run container with app image:

```
docker run --name app  --rm -d ${user}/app
```


3. Access HTTP Server inside container:

```
docker exec -i -t ${Container_ID} /bin/bash
python3 client.py localhost 8080
```

4. Access HTTP Server externally:

```
docker run --name app  --rm -d -p 8081:8080 ${user}/app
# Access from browser: localhost:8081
```

### Run as Kubernetes Pods

1. Run HTTP Server Pod:

```
kubectl apply -f pod.yaml
```

2. Access HTTP Server inside container:

```
kubectl exec -i -t http-server -- /bin/bash
python3 client.py localhost 8080
```

3. Access HTTP Server from other pods:

```
kubectl apply -f client-pod.yaml
kubectl exec -i -t http-client -- /bin/bash
python3 client.py ${POD_IP} 8080
```

4. Port-forward for external access:

```
kubectl port-forward --address 0.0.0.0 http-server 8081:8080
# Access from browser: localhost:8081
```

5. Create ClusterIP service to access via Service Name inside container: 

```
kubectl apply -f service-clsuterip.yaml
kubectl exec -i -t http-client -- /bin/bash
python3 client.py http-service 8080
```

