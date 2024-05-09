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

There are two images to be built, i.e., `app` and `client` image. We first build two images and then run different methods to access them.


1. Build and push Server, Proxy, and Client Images to Dockerhub:

```
cd server/
docker build -t ${user}/quiz-server .
docker push ${user}/quiz-server
cd proxy/
docker build -t ${user}/quiz-proxy .
docker push ${user}/quiz-proxy
cd client/
docker build -t ${user}/quiz-client .
docker push ${user}/quiz-client
```



2. Run Server and Proxy Container:

```
docker run --name server --rm -d ${user}/quiz-server
docker run --name proxy --rm -d -p 8881:8888 ${user}/quiz-proxy
cd client/
python3 client.py localhost 8881 ${Server_IP} 8080 "Hello world from proxy"
```


### Run as Kubernetes Pods

All Kubernetes YAML Files are in `kube-yaml`.

1. Run HTTP Server Pod:

```
kubectl apply -f server-pod.yaml
kubectl apply -f proxy-pod.yaml
```

2. Access HTTP Server inside container:

```
kubectl exec -i -t http-server -- /bin/bash
python3 client.py localhost 8080
kubectl port-forward --address 0.0.0.0 http-proxy 8881:8888
cd client/
python3 client.py localhost 8881 ${Server_IP} 8080 "Hello world from proxy"
```

