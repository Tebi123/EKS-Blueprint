output "postgres_db_name" {
  value = module.rds-aurora.aurora_cluster_database_name
}

output "postgres_host" {
  value = module.rds-aurora.aurora_cluster_instance_endpoints
}

output "postgres_port" {
  value = module.rds-aurora.aurora_cluster_port
}

output "postgres_username" {
  value = module.rds-aurora.aurora_cluster_master_username
}

output "postgres_password" {
  value     = module.rds-aurora.aurora_cluster_master_password
  sensitive = true
}
