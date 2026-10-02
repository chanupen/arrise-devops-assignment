output "instance_ids" {
  description = "instance name -> instance id"
  value       = module.fleet.instance_ids
}

output "instance_private_ips" {
  description = "instance name -> private ip"
  value       = module.fleet.instance_private_ips
}
