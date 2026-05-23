variable "aws_region" {
  default = "ap-south-1"
}

variable "project_name" {
  default = "ai-worker-mesh"
}

variable "key_name" {
  description = "Existing AWS EC2 key pair name"
  type        = string
}

variable "public_key_path" {
  description = "Path to public SSH key"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "my_ip" {
  description = "Your public IP for SSH access"
  type        = string
}

variable "instance_type_api" {
  default = "t3.medium"
}

variable "instance_type_worker" {
  default = "t3.large"
}