# Variáveis do Terraform

variable "aws_region" {
  description = "Região AWS onde os recursos serão criados"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "Nome do cluster Kubernetes"
  type        = string
  default     = "meu-cluster-k8s"
}

variable "instance_type" {
  description = "Tipo de instância EC2"
  type        = string
  default     = "t2.medium"
}

variable "key_name" {
  description = "Nome da chave SSH para acesso às instâncias"
  type        = string
  default     = "k8s"
}

variable "control_plane_count" {
  description = "Número de nós do control plane"
  type        = number
  default     = 1
}

variable "worker_count" {
  description = "Número de nós workers"
  type        = number
  default     = 2
}
