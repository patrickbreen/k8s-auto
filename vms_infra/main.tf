
terraform {
  required_version = ">= 0.13"
    required_providers {
      libvirt = {
        source  = "dmacvicar/libvirt"
        version = "0.6.14"
    }
  }
}

# instance the provider
provider "libvirt" {
  uri = "qemu:///system"
}

resource "libvirt_pool" "ubuntu" {
  name = "ubuntu"
  type = "dir"
  path = "/tmp/terraform-provider-libvirt-pool-ubuntu"
}

# Create the network
resource "libvirt_network" "kube_network" {
  name = "k8snet"
  mode = "bridge"
  bridge = "br0"
}

# I made my own module that will create each instace, and disk and userdata etc.
module "libvirt-instances" {
  source = "./modules/libvirt-instance"
  for_each = toset(var.hostnames)
  hostname = each.value
  pool_name = libvirt_pool.ubuntu.name
}
