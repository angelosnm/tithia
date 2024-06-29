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