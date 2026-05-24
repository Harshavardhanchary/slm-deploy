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
  connection {
  type        = "ssh"
  user        = "ubuntu"
  private_key = tls_private_key.ssh_key.private_key_pem
  host        = self.public_ip
}

provisioner "file" {
  content     = tls_private_key.ssh_key.private_key_pem
  destination = "/home/ubuntu/slm-key.pem"
}

provisioner "remote-exec" {
  inline = [
    "chmod 400 /home/ubuntu/slm-key.pem"
  ]
}

  tags = {
    Name = "api-vm"
  }

  depends_on = [
    aws_nat_gateway.nat
  ]
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

  tags = {
    Name = "inference-worker-vm"
  }

  depends_on = [
    aws_instance.api_vm
  ]
}