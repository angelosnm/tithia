# Tithia

Born from the Sky and Earth, <em>Tithia</em> is the perfect blend of two powerful forces. From the sky, we gather satellite data and maps, providing a bird's-eye view of our world. From the Earth, we harness geospatial insights—the very ground we walk on, rich with invaluable information.

Together, they create <em>Tithia</em>. A cutting-edge platform designed to bring you the best of both worlds. Just as the union of Sky and Earth gave birth to <em>Tithia</em> in ancient times, today, our platform seamlessly merges advanced satellite imagery with precise geospatial data, offering unparalleled insights.

The Tithia platform is a well-architected solution for geospatial data analysis and processing data, offering scalability, reliability, security, and efficiency. By leveraging key technologies such as Kubernetes, Apache Spark, and distributed storage, the platform provides a robust and flexible environment for data-driven applications.

<em>Tithia</em>, because understanding the world starts from above, and ends beneath our feet.

# Architecture

![alt text](resources/images/architecture.jpg)

## Key Components and Technologies

`Kubernetes`: Serving as the foundation of the platform, Kubernetes orchestrates the deployment, scaling, and management of containerized applications. It ensures high availability, fault tolerance, and efficient resource utilization.

`JupyterHub`: As a multi-user server for Jupyter notebooks, JupyterHub provides a collaborative workspace for data scientists and analysts. It enables users to share and work on data analysis tasks within a centralized environment.

`Specialized Jupyter Container Images`: These pre-configured container images offer a streamlined development experience with Python & R environments by bundling essential geospatial software and libraries for data analysis tasks.

`Keycloak`: This identity and access management (IAM) solution safeguards the platform by providing user authentication, authorization, and single sign-on (SSO) capabilities. Keycloak ensures secure access to resources and protects sensitive data.

`Apache Spark`: A distributed data processing engine, Spark is optimized for large-scale data analysis tasks. It excels at data cleaning, transformation, and machine learning, delivering exceptional performance and scalability.

`Apache Sedona`: Apache Sedona is a powerful open-source framework designed to efficiently process and analyze large-scale spatial data and operates as an extension of `Spark`. It extends these systems with a set of out-of-the-box Spatial Resilient Distributed Datasets (SRDDs) and Spatial SQL, enabling developers to easily perform complex spatial operations on massive datasets. 

`Longhorn`: Longhorn is a distributed block storage system that offers persistent storage for the users applications. It ensures high availability and performance, guaranteeing data durability and accessibility by offering distributed cloud-native persistent block storage on Kubernetes. Efficient backup mechanisms take place too on which critical data can be recovered from a disk failure by re-replicating the entire data store at minimal downtime.

`MinIO` is an open-source, high-performance object storage system designed to store unstructured data. It is used as the HDFS and the overlay storage between JupyterHub and Spark for storing data.

# Documentation

## Infrastructre

Ansible is being used to install Spark and Kubernetes accordingly. Relevant playbooks have been prepared.

## Ansible (Spark Installation)

Below command uses the `--user` argument in order to define with which user will connect to the hosts.

```bash
cd ansible
ansible-playbook -i spark_inventory.ini --user tithia spark_installation_playbook.yml
```

## OS Configuration

In order for Spark cluster to communicate with Kubernetes in terms of sending PySpark jobs from within JupyterHub, the below network configurations need to be applied

### Spark nodes
```bash
sudo ip route add 10.42.0.0/16 via 192.168.18.120
```

### On Kubernetes (control-plane node)
```bash
sudo iptables -A FORWARD -s 10.42.0.0/16 -j ACCEPT
sudo iptables -A FORWARD -d 10.42.0.0/16 -j ACCEPT
```

Persist these rules using a firewall management tool or saving them directly to `/etc/iptables/rules.v4`

```bash
sudo sysctl net.ipv4.ip_forward=1
echo "net.ipv4.ip_forward = 1" | sudo tee -a /etc/sysctl.conf
```

## Docker

A specialized container image has been prepared in order to be used by JupyterHub. The relevant content is under the `docker` directory.

## Kubernetes (K3s)

Download and install the K3s Kubernetes distribution (a lightweight Kubernetes installer for single-node or cluster setups).
```bash
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--disable traefik" sh -s -
```

Verify that the K3s node is up and running by listing the Kubernetes nodes.
```bash
sudo kubectl get nodes
```

Set the KUBECONFIG environment variable to point to your Kubernetes configuration file for kubectl.
```bash
export KUBECONFIG=~/.kube/config
```

Create the Kubernetes configuration directory if it doesn't already exist.
```bash
mkdir ~/.kube 2> /dev/null
```

Save the raw Kubernetes configuration from K3s into your KUBECONFIG file.
```bash
sudo k3s kubectl config view --raw > "$KUBECONFIG"
```

Secure the configuration file by restricting access permissions to the owner only.
```bash
chmod 600 "$KUBECONFIG"
```

Verify the nodes again to ensure kubectl is configured and can communicate with the cluster.
```bash
kubectl get nodes
```

Retrieve the node token, which is used for joining additional nodes to the K3s cluster.
```bash
sudo cat /var/lib/rancher/k3s/server/node-token
```

nstall K3s on an additional node and join it to the cluster by specifying the master node's IP and the node token.
Replace <master-ip> with the IP address of the master node and <node-token> with the retrieved token from the previous step.
```bash
curl -sfL https://get.k3s.io | K3S_URL=https://<master-ip>:6443 K3S_TOKEN=<node-token> sh -
```

Taint control plane node to prevent pods scheduling
```bash
kubectl taint nodes tithia-kube-control-plane node-role.kubernetes.io/control-plane:NoSchedule
```

Once the Kubernetes cluster has been provisioned, follow the below instructions for the installation of each component.

## Kubernetes components installation
```bash
cd kube
```

### Metrics-server
```bash
kubectl apply -f metrics-server/metrics-server.yaml
```

### Ingress NGINX Controller

```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx

helm repo update

helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx -n ingress-nginx --create-namespace -f ingress-nginx/values.yaml --version 4.11.2
```


### cert-manager

```bash
helm repo add jetstack https://charts.jetstack.io

helm repo update

helm upgrade --install cert-manager jetstack/cert-manager -n cert-manager --create-namespace --version 1.15.3 --set crds.enabled=true
```

#### HTTP Cluster Issuer Configuration (https://cert-manager.io/docs/configuration/acme/dns01/route53/)
Create a ClusterIssuer component which is responsible for making HTTP challenges to verify the ownership of the domain:

`kubectl apply -f cert-manager/clusterIssuer-letsencrypt-http.yaml`


### Longhorn

**`open-iscsi` is required to be installed on the hosts prior installing Longhorn

```bash
helm repo add longhorn https://charts.longhorn.io

helm repo update

helm upgrade --install longhorn longhorn/longhorn -n longhorn --create-namespace --version 1.7.1 --values longhorn/values.yaml

k apply -f longhorn/certificate.yaml
```

Create basic-auth credentials for ingress

```bash
USER=koukos; PASSWORD=metagkisi; echo "${USER}:$(openssl passwd -stdin -apr1 <<< ${PASSWORD})" >> longhorn/auth

kubectl -n longhorn create secret generic basic-auth --from-file=longhorn/auth

k apply -f longhorn/ingress.yaml
```

Create secret with S3 credentials for backup target

```bash
kubectl create secret generic aws-secret \
    --from-literal=AWS_ACCESS_KEY_ID=<your-aws-access-key-id> \
    --from-literal=AWS_SECRET_ACCESS_KEY=<your-aws-secret-access-key> \
    -n longhorn
```

### minio
`MinIO` is used for HDFS.

```bash
k create ns minio
k apply -f minio
```


### db

`Postgres` is used as the database of the system. (It is required for Keycloak & JupyterHub)

```bash
k create ns db
k apply -f db
```

### Keycloak

`providers` subdirectory (`/opt/keycloak/`) is persisted by PVC in order to deploy the [`keywind`](https://github.com/lukin/keywind/tree/master) theme.

```bash
k create ns keycloak
k apply -f keycloak
```

#### Keywind theme installation

```bash
cd /tmp
git clone https://github.com/lukin/keywind.git
cd keywind
docker run --rm -it -v $(pwd):/app node:20 bash
wget -qO- https://get.pnpm.io/install.sh | ENV="$HOME/.bashrc" SHELL="$(which bash)" bash - # pnpm installation
source /root/.bashrc
cd /app
pnpm install
pnpm build
pnpm build:jar
```
Now exit the container and copy .jar file to Keycloak pod, to the `providers` directory.

```bash
cat out/keywind.jar | kubectl exec -i -n keycloak <pod-name> "--" sh -c "cat > /opt/keycloak/providers/keywind.jar"
```
Then restart the Keycloak Deployment/Pod

### Jupyterhub
```bash
helm repo add jupyterhub https://jupyterhub.github.io/helm-chart/

helm repo update
```

Prior installing the Helm chart, a relevant database needs to be created for `JupyterHub` on `Postgres`

```bash
helm upgrade jupyterhub jupyterhub/jupyterhub --install --cleanup-on-fail -n jupyterhub --create-namespace --version 3.3.8 --timeout 1200s -f jupyterhub/values.yaml --set hub.db.url="postgresql+psycopg2://myuser:mypassword@postgres.db.svc.cluster.local:5432/jupyterhub" --set hub.config.GenericOAuthenticator.client_id="xxx" --set hub.config.GenericOAuthenticator.client_secret="yyy"

k apply -f jupyterhub/certificate.yaml

k apply -f jupyterhub/ingress.yaml
```

### Spark

kubectl create configmap spark-config --from-file=spark-defaults.conf --from-file=spark-env.sh -n spark