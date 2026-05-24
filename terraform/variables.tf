variable "aws_region" {
  default = "ap-south-2"
}

variable "project_name" {
  default = "slm-deployment"
}

variable "my_ip" {
  description = "Your public IP for SSH access"
  type        = string
}

variable "instance_type_api" {
  default = "m7i-flex.large"
}

variable "instance_type_worker" {
  default = "m7i-flex.large"
}