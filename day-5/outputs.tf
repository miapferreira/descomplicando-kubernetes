# Outputs do Terraform - Informações do Cluster Kubernetes

# IP público do Control Plane
output "control_plane_public_ip" {
  description = "IP público do Control Plane"
  value       = aws_instance.control_plane[0].public_ip
}

# IP privado do Control Plane
output "control_plane_private_ip" {
  description = "IP privado do Control Plane"
  value       = aws_instance.control_plane[0].private_ip
}

# IPs públicos dos Worker Nodes
output "worker_nodes_public_ips" {
  description = "IPs públicos dos Worker Nodes"
  value       = aws_instance.worker_nodes[*].public_ip
}

# IPs privados dos Worker Nodes
output "worker_nodes_private_ips" {
  description = "IPs privados dos Worker Nodes"
  value       = aws_instance.worker_nodes[*].private_ip
}

# Comando SSH para acessar o Control Plane
output "ssh_control_plane" {
  description = "Comando SSH para acessar o Control Plane"
  value       = "ssh -i ~/.ssh/${var.key_name}.pem ubuntu@${aws_instance.control_plane[0].public_ip}"
}

# Comandos SSH para acessar os Worker Nodes
output "ssh_worker_nodes" {
  description = "Comandos SSH para acessar os Worker Nodes"
  value = [
    for i, worker in aws_instance.worker_nodes :
    "ssh -i ~/.ssh/${var.key_name}.pem ubuntu@${worker.public_ip}"
  ]
}

# Informações do Security Group
output "security_group_id" {
  description = "ID do Security Group criado"
  value       = aws_security_group.k8s_cluster.id
}

# Comando para verificar status do cluster
output "check_cluster_status" {
  description = "Comando para verificar status do cluster"
  value       = "ssh -i ~/.ssh/${var.key_name}.pem ubuntu@${aws_instance.control_plane[0].public_ip} 'kubectl get nodes'"
}

# Comando para verificar pods do sistema
output "check_system_pods" {
  description = "Comando para verificar pods do sistema"
  value       = "ssh -i ~/.ssh/${var.key_name}.pem ubuntu@${aws_instance.control_plane[0].public_ip} 'kubectl get pods -n kube-system'"
}

# Informações do cluster
output "cluster_info" {
  description = "Informações gerais do cluster"
  value = {
    name             = var.cluster_name
    region           = var.aws_region
    control_plane_ip = aws_instance.control_plane[0].public_ip
    worker_count     = var.worker_count
    instance_type    = var.instance_type
  }
}
