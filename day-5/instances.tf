# EC2 Instances para o Cluster Kubernetes

# Control Plane Instance
resource "aws_instance" "control_plane" {
  count = var.control_plane_count

  ami                    = local.ubuntu_ami
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.k8s_cluster.id]
  subnet_id              = data.aws_subnets.default.ids[0]

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
    encrypted   = true
  }

  user_data = base64encode(templatefile("${path.module}/scripts/control-plane-setup.sh", {
    cluster_name = var.cluster_name
  }))

  tags = {
    Name = "${var.cluster_name}-control-plane-${count.index + 1}"
    Role = "control-plane"
  }

  depends_on = [aws_security_group.k8s_cluster]
}

# Worker Nodes Instances
resource "aws_instance" "worker_nodes" {
  count = var.worker_count

  ami                    = local.ubuntu_ami
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.k8s_cluster.id]
  subnet_id              = data.aws_subnets.default.ids[0]

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
    encrypted   = true
  }

  user_data = base64encode(templatefile("${path.module}/scripts/worker-setup.sh", {
    cluster_name = var.cluster_name
  }))

  tags = {
    Name = "${var.cluster_name}-worker-${count.index + 1}"
    Role = "worker"
  }

  depends_on = [aws_security_group.k8s_cluster]
}
