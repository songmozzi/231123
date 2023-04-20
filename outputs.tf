output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ids attached to the cluster control plane"
  value       = module.eks.cluster_security_group_id
}

output "region" {
  description = "AWS region"
  value       = var.region
}

output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = module.eks.cluster_name
}

output "vpc_id" {
  value = module.vpc1.vpc_id
}

output "peer_vpc_id" {
  value = module.vpc2.vpc_id
}

output "vpc_peering_connection_id" {
    value = aws_vpc_peering_connection.this.id
}

output "vpc1_private_route_table_id" {
  value = module.vpc1.private_route_table_ids[0]
}

output "vpc2_cidr_block" {
  value = module.vpc2.vpc_cidr_block
}

output "vpc2_private_route_table_id" {
  value = module.vpc2.private_route_table_ids[0]
}

output "vpc1_cidr_block" {
  value = module.vpc1.vpc_cidr_block
}

output "vpc1_public_route_table_id" {
  value = module.vpc1.public_route_table_ids[0]
}
