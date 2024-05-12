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
python3 server.py # run a server on port 8080
```

2. Access HTTP Server:

```
python3 client.py localhost 8080 # or access from browser: localhost:8080
```

### Run as Docker Container

There are two images to be built, i.e., `server` and `client` image. We first build two images and then run different methods to access them.


1. Build and push Server and Client Image to Dockerhub:

```
cd server/
docker build -t ${user}/server-image .
docker push ${user}/server-image
cd client/
docker build -t ${user}/client-image .
docker push ${user}/client-image
```



2. Run Server Container:

```
docker run --name server --rm -d ${user}/server-image
```


3. Access HTTP Server inside the container:

```
docker ps # To check the Server ${Container_ID}
docker exec -i -t ${Container_ID} /bin/bash
python3 client.py localhost 8080
```

4. Access HTTP Server from another container:

```
docker run --name client  --rm -d ${user}/client-image
docker ps # To check the ${Client_Container_ID}
docker inspect server # Check and get server ${Server_Container_IP}
docker exec -i -t ${Client_Container_ID} /bin/bash
python3 client.py ${Server_Container_IP} 8080
```

5. Access HTTP Server externally:

```
docker run --name server  --rm -d -p 8081:8080 ${user}/server-image
# Access from browser: localhost:8081
```

### Run as Kubernetes Pods

All Kubernetes YAML Files are in `kube-yaml`.

1. Run HTTP Server Pod:

```
kubectl apply -f server-pod.yaml
```

2. Access HTTP Server inside container:

```
kubectl exec -i -t http-server -- /bin/bash
python3 client.py localhost 8080
```

3. Access HTTP Server from other pods:

```
kubectl describe pod http-server # Check description and get ${POD_IP}
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

