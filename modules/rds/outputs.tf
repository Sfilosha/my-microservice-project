output "db_instance_endpoint" {
  description = "Endpoint стандартної RDS інстанції"
  value       = var.use_aurora ? "" : aws_db_instance.standard[0].endpoint
}

output "aurora_cluster_endpoint" {
  description = "Endpoint Aurora кластеру"
  value       = var.use_aurora ? aws_rds_cluster.aurora[0].endpoint : ""
}