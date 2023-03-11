
```
# configure linux bridge:


# source:
https://www.answertopia.com/ubuntu/creating-an-ubuntu-kvm-networked-bridge-interface/

# host /etc/netplan/01-netcfg.yaml netplan config:
network:
  version: 2
  renderer: networkd
  ethernets:
    enp4s0:
      dhcp4: no
  bridges:
    br0:
      interfaces: [enp4s0]
      dhcp4: no
      addresses: [192.168.0.10/24]
      gateway4: 192.168.0.1
      nameservers:
        addresses: [192.168.0.1]

# apply host networking:
sudo netplan apply

# verify bridge
networkctl status -a

# configure vms:

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
