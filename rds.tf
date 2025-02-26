resource "aws_db_subnet_group" "default" {
  name       = "${var.app_name}-${var.environment}-main-group"
  subnet_ids = data.aws_subnets.default.ids

  tags = {
    Name = "${var.app_name} ${var.environment} DB subnet group"
  }
}

resource "aws_db_instance" "postgres-db-instance" {
  count                     = var.is_postgres_enabled ? 1 : 0
  allocated_storage         = 20
  engine                    = "postgres"
  engine_version            = "15.10"
  identifier                = "${var.app_name}-${var.environment}-postgres-db"
  instance_class            = "db.t3.micro"
  password                  = var.db_password
  skip_final_snapshot       = false
  final_snapshot_identifier = "${var.app_name}-${var.environment}-final-snapshot"
  snapshot_identifier       = var.postgres_snapshot_id
  storage_encrypted         = false
  publicly_accessible       = true
  username                  = var.db_username
  apply_immediately         = true
  db_subnet_group_name      = aws_db_subnet_group.default.name

  tags = {
    Environment = var.environment
  }

  depends_on = [aws_db_subnet_group.default]
}
