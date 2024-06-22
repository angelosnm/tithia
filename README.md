For develpoment purposes, `Vagrant` has been utilized for provision of touchbase virtual machines.
Thus this requires `VirtualBox` to be installed on host machine as this is the default provider of this setup.

Once this is installed, you can follow the below guide to create the necessary VMs.

```bash
### Create VMs
vagrant up

### SSH connection to VMs
ssh -i .vagrant/machines/debian-host1/virtualbox/private_key vagrant@192.168.56.101
ssh -i .vagrant/machines/debian-host2/virtualbox/private_key vagrant@192.168.56.102
ssh -i .vagrant/machines/debian-host3/virtualbox/private_key vagrant@192.168.56.103

### Stop VMs
vagrant halt

### Delete VMs (Force)
vagrant destroy -f
```