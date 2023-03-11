
terraform {
    required_providers {
      libvirt = {
        source  = "dmacvicar/libvirt"
        version = "0.6.14"
    }
  }
}

data "template_file" "user_data" {
  template = file("${path.module}/cloud_init.cfg")
  vars = {
    my_hostname = "${var.hostname}",
  }
}

data "template_file" "network_config" {
  template = file("${path.module}/network_config.cfg")
  vars = {
    my_static_ip = "${var.static_ip}",
  }
}

resource "libvirt_cloudinit_disk" "commoninit" {
  name           = format("%s.iso",var.hostname)
  user_data      = data.template_file.user_data.rendered
  network_config = data.template_file.network_config.rendered
  pool           = var.pool_name
}

resource "libvirt_volume" "ubuntu-qcow2" {
  name   = var.hostname
  pool   = var.pool_name
  source = "ubuntu-20.04-server-cloudimg-amd64.img"
  format = "qcow2"
}

# Create the machine
resource "libvirt_domain" "domain-ubuntu" {
  name   = var.hostname
  memory = "6000"
  vcpu   = 4

  cloudinit = libvirt_cloudinit_disk.commoninit.id

  network_interface {
    network_name = "k8snet"
    wait_for_lease = false
  }

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  console {
    type        = "pty"
    target_type = "virtio"
    target_port = "1"
  }

  disk {
    volume_id = libvirt_volume.ubuntu-qcow2.id
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}

