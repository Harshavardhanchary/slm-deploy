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

resource "aws_instance" "api_vm" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type_api
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.api_sg.id]
  key_name                    = var.key_name
  user_data = file("${path.module}/userdata/api.sh")
  associate_public_ip_address = true

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  tags = {
    Name = "api-vm"
  }
}

resource "aws_instance" "caller_worker_vm" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type_worker
  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.worker_sg.id]
  key_name               = var.key_name
  user_data = file("${path.module}/userdata/caller.sh")

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  tags = {
    Name = "caller-worker-vm"
  }
}

resource "aws_instance" "inference_worker_vm" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type_worker
  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.worker_sg.id]
  key_name               = var.key_name
  user_data = file("${path.module}/userdata/inference.sh")

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  tags = {
    Name = "inference-worker-vm"
  }
}