# Tithia

Born from the Sky and Earth, <em>Tithia</em> is the perfect blend of two powerful forces. From the sky, we gather satellite data and maps, providing a bird's-eye view of our world. From the Earth, we harness geospatial insights—the very ground we walk on, rich with invaluable information.

Together, they create <em>Tithia</em>. A cutting-edge platform designed to bring you the best of both worlds. Just as the union of Sky and Earth gave birth to <em>Tithia</em> in ancient times, today, our platform seamlessly merges advanced satellite imagery with precise geospatial data, offering unparalleled insights.

<em>Tithia</em>, because understanding the world starts from above, and ends beneath our feet.

# Architecture

![alt text](resources/tithia-architecture.png "Title")

# Documentation

For develpoment purposes, `Vagrant` has been utilized for provisioning of playground virtual machines.
Thus this requires `VirtualBox` to be installed on host machine as this is the default provider of this setup.

Once this is installed, you can follow the below guide to create the necessary VMs.

### Create VMs
```
vagrant up
```

### SSH connection to VMs
```
ssh -i .vagrant/machines/spark-master/virtualbox/private_key vagrant@192.168.56.101
ssh -i .vagrant/machines/spark-worker-1/virtualbox/private_key vagrant@192.168.56.102
ssh -i .vagrant/machines/spark-worker-2/virtualbox/private_key vagrant@192.168.56.103
```

### Pass your personal SSH key (optional)
```
ssh-copy-id -i ~/.ssh/id_rsa.pub -o IdentityFile=.vagrant/machines/spark-master/virtualbox/private_key -f vagrant@192.168.56.101
ssh-copy-id -i ~/.ssh/id_rsa.pub -o IdentityFile=.vagrant/machines/spark-worker-1/virtualbox/private_key -f vagrant@192.168.56.102
ssh-copy-id -i ~/.ssh/id_rsa.pub -o IdentityFile=.vagrant/machines/spark-worker-2/virtualbox/private_key -f vagrant@192.168.56.103
```

### Stop VMs
```
vagrant halt
```

### Delete VMs (Force)
```
vagrant destroy -f
```

## Ansible

Below command uses the `--user` argument in order to define with which user will connect to the hosts.

```
ansible-playbook -i hosts.ini --user vagrant install_spark.yml
```

## Local Docker environment

The `docker-compose.yaml` file has a preconfigured containerized environment for interracting with the Spark cluster.

Simply `docker compose up` and then execute `docker logs spark` to find the token.

## Kubernetes

### Ingress NGINX Controller

```
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx

helm repo update

helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx -n ingress-nginx --create-namespace -f ./kube/ingress-nginx/values.yaml --version 4.11.2
```


### cert-manager

```
helm repo add jetstack https://charts.jetstack.io

helm repo update

helm show values jetstack/cert-manager > ./kube/cert-manager/values.yaml

helm upgrade --install cert-manager jetstack/cert-manager -n cert-manager --create-namespace --version 1.15.3 --set crds.enabled=true
```

#### HTTP Cluster Issuer Configuration (https://cert-manager.io/docs/configuration/acme/dns01/route53/)
Create a ClusterIssuer component which is responsible for making HTTP challenges to verify the ownership of the domain:

`kubectl apply -f ./kube/cert-manager/clusterIssuer-letsencrypt-http.yaml`


### Longhorn

**`open-iscsi` is required to be installed on the hosts prior installing Longhorn

```
helm repo add longhorn https://charts.longhorn.io

helm repo update

helm show values longhorn/longhorn > ./kube/longhorn/values.yaml

helm upgrade --install longhorn longhorn/longhorn -n longhorn --create-namespace --version 1.7.1 -f ./kube/longhorn/values.yaml

k apply -f ./kube/longhorn/certificate.yaml
```

##### Creating basic-auth credentials for ingress

```
USER=koukos; PASSWORD=metagkisi; echo "${USER}:$(openssl passwd -stdin -apr1 <<< ${PASSWORD})" >> ./kube/longhorn/auth`

kubectl -n longhorn create secret generic basic-auth --from-file=./kube/longhorn/auth

k apply -f ./kube/longhorn/ingress.yaml
```

### db

`Postgres` is used as the database of the system. (It is required for Keycloak & JupyterHub)

```
k apply -f ./kube/db
```

### Keycloak

`providers` subdirectory (`/opt/keycloak/`) is persisted by PVC in order to deploy the [`keywind`](https://github.com/lukin/keywind/tree/master) theme.

```
k apply -f ./kube/keycloak
```

#### Keywind theme installation

```
git clone https://github.com/lukin/keywind.git
docker run -it node:20 -v... 
pnpm install
pnpm build
pnpm build:jar
```
##### Copy .jar file to Keycloak pod

```
k cp ...
```


### Jupyterhub
```
helm repo add jupyterhub https://jupyterhub.github.io/helm-chart/

helm repo update

helm show values jupyterhub/jupyterhub > ./kube/jupyterhub/values.yaml
```

Prior installing the Helm chart, a relevant database needs to be created for `JupyterHub` on `Postgres`

```


```

helm upgrade jupyterhub jupyterhub/jupyterhub --install --cleanup-on-fail -n jupyterhub --create-namespace --version 3.3.8 --timeout 1200s -f ./kube/jupyterhub/values.yaml --set hub.db.url="postgresql+psycopg2://myuser:mypassword@postgres.db.svc.cluster.local:5432/jupyterhub"

k apply -f ./kube/jupyterhub/certificate.yaml

k apply -f ./kube/jupyterhub/ingress.yaml
```

### Spark

```
helm repo add bitnami https://charts.bitnami.com/bitnami

helm repo update

helm show values bitnami/spark > ./kube/spark/values.yaml

helm upgrade spark bitnami/spark --install --cleanup-on-fail -n spark --create-namespace --version 9.2.11 -f ./kube/spark/values.yaml
```