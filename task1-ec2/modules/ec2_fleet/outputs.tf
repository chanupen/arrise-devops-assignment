output "instance_ids" {
  value = merge(
    { for name, inst in aws_instance.fleet : name => inst.id },
    { for name, inst in aws_instance.protected : name => inst.id },
  )
}

output "instance_private_ips" {
  value = merge(
    { for name, inst in aws_instance.fleet : name => inst.private_ip },
    { for name, inst in aws_instance.protected : name => inst.private_ip },
  )
}
