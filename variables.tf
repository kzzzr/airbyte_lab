variable "folder_id" {
  description = "Folder ID"
  type        = string
}

variable "clickhouse_password" {
  description = "Clickhouse admin password"
  type        = string
  sensitive   = true
}

output "clickhouse_host_fqdn" {
  value = resource.yandex_mdb_clickhouse_cluster.clickhouse_starschema.host[0].fqdn
}

output "yandex_storage_bucket_name" {
  value = resource.yandex_storage_bucket.analytics_engineering_airbyte.id
}
# output "yandex_storage_bucket_domain_name" {
#   value = resource.yandex_storage_bucket.analytics_engineering_airbyte.bucket_domain_name
# }
output "yandex_iam_service_account_static_access_key" {
  value = yandex_iam_service_account_static_access_key.sa-static-key.access_key
}
output "yandex_iam_service_account_static_secret_key" {
  value     = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  sensitive = true
}

output "yandex_compute_instance_nat_ip_address" {
  value = yandex_compute_instance.airbyte.network_interface.0.nat_ip_address
}
