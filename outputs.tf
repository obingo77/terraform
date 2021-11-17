#-- outputs.tf--
output "tags" {
  value = local.tags
}
# TO DO
/*output "instance_ids" {
  description = "IDs of EC2 instances"
  value       = aws_instance.app.*.id
}*/

output "ami_value" {
  value = lookup(var.aws_amis, var.aws_region)
}
