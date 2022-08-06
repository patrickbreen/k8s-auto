
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
