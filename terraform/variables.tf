variable "libvirt_uri" {
  type    = string
  default = "qemu:///system"
}

variable "pool" {
  type    = string
  default = "default"
}

variable "network_name" {
  type    = string
  default = "k8s-ha"
}

variable "network_cidr" {
  type    = string
  default = "10.10.20.0/24"
}

variable "ubuntu_image" {
  type    = string
  default = "/var/lib/libvirt/images/ubuntu-24.04-server-cloudimg-amd64.img"
}

variable "ssh_public_key" {
  type      = string
  sensitive = true
}

variable "nodes" {
  type = map(object({
    role      = string
    ip        = string
    vcpu      = number
    memory_mb = number
  }))
  default = {
    cp-01 = {
      role      = "control_plane"
      ip        = "10.10.20.11"
      vcpu      = 2
      memory_mb = 3072
    }
    cp-02 = {
      role      = "control_plane"
      ip        = "10.10.20.12"
      vcpu      = 2
      memory_mb = 3072
    }
    cp-03 = {
      role      = "control_plane"
      ip        = "10.10.20.13"
      vcpu      = 2
      memory_mb = 3072
    }
    worker-01 = {
      role      = "worker"
      ip        = "10.10.20.21"
      vcpu      = 2
      memory_mb = 2048
    }
    worker-02 = {
      role      = "worker"
      ip        = "10.10.20.22"
      vcpu      = 2
      memory_mb = 2048
    }
    worker-03 = {
      role      = "worker"
      ip        = "10.10.20.23"
      vcpu      = 2
      memory_mb = 2048
    }
  }
}
