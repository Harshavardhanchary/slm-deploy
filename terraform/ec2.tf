data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

# -----------------------------
# API VM (Public)
# -----------------------------
resource "aws_instance" "api_vm" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type_api
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.api_sg.id]
  key_name                    = aws_key_pair.generated_key.key_name
  associate_public_ip_address = true

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  tags = {
    Name = "api-vm"
  }

  depends_on = [
    aws_nat_gateway.nat
  ]

  # -----------------------------
  # SSH Connection
  # -----------------------------
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = tls_private_key.ssh_key.private_key_pem
    host        = self.public_ip
  }

  # -----------------------------
  # Copy API setup script
  # -----------------------------
  provisioner "file" {
    source      = "${path.module}/../scripts/api-vm.sh"
    destination = "/home/ubuntu/api-vm.sh"
  }

  # -----------------------------
  # Copy SSH private key
  # -----------------------------
  provisioner "file" {
    content     = tls_private_key.ssh_key.private_key_pem
    destination = "/home/ubuntu/slm-key.pem"
  }

  # -----------------------------
  # Execute setup
  # -----------------------------
  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/ubuntu/api-vm.sh",
      "chmod 400 /home/ubuntu/slm-key.pem",
      "/home/ubuntu/api-vm.sh"
    ]
  }
}

# -----------------------------
# Caller Worker VM (Private)
# -----------------------------
resource "aws_instance" "caller_worker_vm" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type_worker
  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.worker_sg.id]
  key_name               = aws_key_pair.generated_key.key_name

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

    provisioner "file" {
    source      = "${path.module}/../scripts/caller-worker.sh"
    destination = "/home/ubuntu/caller-worker.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/ubuntu/caller-worker.sh",
      "/home/ubuntu/caller-worker.sh"
    ]
  }

  tags = {
    Name = "caller-worker-vm"
  }

  depends_on = [
    aws_instance.api_vm
  ]
}

# -----------------------------
# Inference Worker VM (Private)
# -----------------------------
resource "aws_instance" "inference_worker_vm" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type_worker
  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.worker_sg.id]
  key_name               = aws_key_pair.generated_key.key_name

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }
    provisioner "file" {
    source      = "${path.module}/../scripts/inference-worker.sh"
    destination = "/home/ubuntu/inference-worker.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/ubuntu/inference-worker.sh",
      "/home/ubuntu/inference-worker.sh"
    ]
  }

  tags = {
    Name = "inference-worker-vm"
  }

  depends_on = [
    aws_instance.api_vm
  ]
}