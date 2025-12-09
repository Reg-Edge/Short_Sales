# outputs.tf
# Output instance ID and private IP
# See: https://developer.hashicorp.com/terraform/language/values/outputs

output "instance_id" {
  value = aws_instance.pbi.id
}

output "private_ip" {
  value = aws_instance.pbi.private_ip
}
