
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
  path = "/home/leet/workplace/k8s-auto/vms_infra/terraform-provider-libvirt-pool-ubuntu"
}

# Create the network
resource "libvirt_network" "kube_network" {
  name = "k8snet"
  mode = "bridge"
  bridge = "br0"
  autostart = true
  dhcp {
    enabled = false
  }
  addresses = ["192.168.0.0/24",]
}

# I made my own module that will create each instace, and disk and userdata etc.
module "libvirt-instances" {
  source = "./modules/libvirt-instance"
  for_each = var.hostnames
  hostname = each.key
  static_ip = each.value
  pool_name = libvirt_pool.ubuntu.name
}

# Start all networks
#resource "null_resource" "start_networks" {
#  depends_on = [libvirt_network.kube_network]
#  provisioner "local-exec" {
#    command = "virsh net-start k8snet}"
#  }
#}

# Start all VMs
#resource "null_resource" "start_domains" {
#  depends_on = [module.libvirt-instances]
#  provisioner "local-exec" {
#    command = "virsh list --all | grep -v State | awk '{print $2}' | xargs -I {} virsh start {}"
#  }
#}