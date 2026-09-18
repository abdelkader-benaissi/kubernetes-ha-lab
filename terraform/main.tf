resource "libvirt_network" "k8s" {
  name      = var.network_name
  mode      = "nat"
  domain    = "k8s.lab"
  addresses = [var.network_cidr]
  autostart = true

  dhcp {
    enabled = false
  }
}

resource "libvirt_volume" "node" {
  for_each = var.nodes
  name     = "${each.key}.qcow2"
  pool     = var.pool
  source   = var.ubuntu_image
  format   = "qcow2"
}

resource "libvirt_cloudinit_disk" "node" {
  for_each = var.nodes
  name     = "${each.key}-cloudinit.iso"
  pool     = var.pool
  user_data = templatefile("${path.module}/cloud-init.yml.tftpl", {
    hostname       = each.key
    ssh_public_key = var.ssh_public_key
  })
  network_config = templatefile("${path.module}/network.yml.tftpl", {
    ip            = each.value.ip
    prefix_length = split("/", var.network_cidr)[1]
    gateway       = cidrhost(var.network_cidr, 1)
  })
}

resource "libvirt_domain" "node" {
  for_each  = var.nodes
  name      = each.key
  vcpu      = each.value.vcpu
  memory    = each.value.memory_mb
  cloudinit = libvirt_cloudinit_disk.node[each.key].id
  autostart = true

  network_interface {
    network_id     = libvirt_network.k8s.id
    wait_for_lease = false
  }

  disk {
    volume_id = libvirt_volume.node[each.key].id
  }

  console {
    type        = "pty"
    target_type = "serial"
    target_port = "0"
  }
}

resource "local_file" "ansible_inventory" {
  filename = "${path.module}/../inventory/generated-hosts.yml"
  content = yamlencode({
    all = {
      vars = {
        ansible_user               = "ubuntu"
        ansible_python_interpreter = "/usr/bin/python3"
        api_vip                    = cidrhost(var.network_cidr, 10)
      }
      children = {
        control_plane = {
          hosts = {
            for name, node in var.nodes : name => { ansible_host = node.ip }
            if node.role == "control_plane"
          }
        }
        workers = {
          hosts = {
            for name, node in var.nodes : name => { ansible_host = node.ip }
            if node.role == "worker"
          }
        }
      }
    }
  })
}
