

# configure linux bridge:

```
# source:
https://www.answertopia.com/ubuntu/creating-an-ubuntu-kvm-networked-bridge-interface/

# use /etc/netplan/01-netcfg.yaml netplan config
# apply host networking:
sudo netplan apply

# verify bridge
networkctl status -a
```

# install dnsmasq and use config dnsmasq.conf (this is what I use for home DNS)

# install FRR

http://docs.frrouting.org/projects/dev-guide/en/latest/building-frr-for-ubuntu2004.html

# configure vms:
```
# get img file
wget https://cloud-images.ubuntu.com/releases/22.04/release/ubuntu-22.04-server-cloudimg-amd64.img
qemu-img resize ubuntu-22.04-server-cloudimg-amd64.img 200G


# terraform:
sudo terraform plan
sudo terraform apply
sudo terraform destroy


# libvirt
sudo virsh list --all
sudo virsh console ubuntu-terraform
sudo virsh undefine <name>
```



