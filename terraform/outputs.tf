output "nodes" {
  value = {
    for name, node in var.nodes : name => {
      ip   = node.ip
      role = node.role
    }
  }
}
