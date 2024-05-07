## Stateless Quiz for Summer School

### Environment Setup

1. Python 3.X
2. Install [Docker](https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository)
   ```
    # Add Docker's official GPG key:
    sudo apt-get update
    sudo apt-get install ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc
    # Add the repository to Apt sources:
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo docker run hello-world
    sudo usermod -aG docker ${USER}
   ```
3. Install [Minikube](https://minikube.sigs.k8s.io/docs/start/)
   ```
   curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
   sudo install minikube-linux-amd64 /usr/local/bin/minikube && rm minikube-linux-amd64
   minikube start
   alias kubectl="minikube kubectl --"
   ```

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

