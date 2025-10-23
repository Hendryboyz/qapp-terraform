# output "postgres_connection_string" {
#   value     = "postgresql://${aws_db_instance.postgres-db-instance[0].username}:${aws_db_instance.postgres-db-instance[0].password}@${aws_db_instance.postgres-db-instance[0].endpoint}:${aws_db_instance.postgres-db-instance[0].port}"
#   sensitive = true

#   precondition {
#     condition = var.is_postgres_enabled
#     error_message = "DB provision is disabled. No connection string"
#   }

#   depends_on = [ aws_db_instance.postgres-db-instance ]
# }

# output "local_developer_access_key_id" {
#   value     = aws_iam_access_key.local_developer.id
#   sensitive = true
# }

# output "local_developer_secret_access_key" {
#   value     = aws_iam_access_key.local_developer.secret
#   sensitive = true
# }
