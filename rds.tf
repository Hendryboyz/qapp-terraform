resource "aws_db_instance" "postgres-db-instance" {
  count               = 0
  allocated_storage   = 20
  engine              = "postgres"
  engine_version      = "11.5"
  identifier          = "${var.app_name}-${var.environment}-postgres-db"
  instance_class      = "db.t2.micro"
  password            = "mypostgrespassword"
  skip_final_snapshot = true
  storage_encrypted   = false
  publicly_accessible = true
  username            = "postgres"
  apply_immediately   = true
}