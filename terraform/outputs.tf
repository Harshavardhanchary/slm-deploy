output "api_public_ip" {
  value = aws_instance.api_vm.public_ip
}

output "api_private_ip" {
  value = aws_instance.api_vm.private_ip
}

output "caller_private_ip" {
  value = aws_instance.caller_worker_vm.private_ip
}

output "inference_private_ip" {
  value = aws_instance.inference_worker_vm.private_ip
}