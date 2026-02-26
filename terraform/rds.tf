# DB Subnet Group (private subnets)
resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-db-subnet"
  subnet_ids = module.vpc.private_subnets
  tags = {
    Name = "${var.project_name}-db-subnet"
  }
}

# Security Group for RDS – allow MySQL from EKS nodes
resource "aws_security_group" "rds_sg" {
  name   = "${var.project_name}-rds-sg"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [module.eks.node_security_group_id]  # Allow EKS nodes
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-rds-sg"
  }
}

# Primary RDS Instance (Multi-AZ)
resource "aws_db_instance" "primary" {
  identifier              = "${var.project_name}-mysql-primary"
  engine                  = "mysql"
  engine_version          = "8.0"
  instance_class          = var.rds_instance_class
  allocated_storage       = var.rds_allocated_storage
  storage_type            = "gp3"
  storage_encrypted       = true
  db_name                 = var.db_name
  username                = var.db_username
  password                = var.db_password
  db_subnet_group_name    = aws_db_subnet_group.main.name
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]

  multi_az                = true   # High availability
  backup_retention_period = 7      # 7 days automated backups
  backup_window           = "03:00-04:00"
  maintenance_window      = "Mon:04:00-Mon:05:00"

  deletion_protection     = true   # Prevent accidental deletion
  skip_final_snapshot     = false
  final_snapshot_identifier = "${var.project_name}-final-snapshot"

  tags = {
    Name = "${var.project_name}-mysql-primary"
  }
}

# Read Replica for read scaling
resource "aws_db_instance" "read_replica" {
  identifier             = "${var.project_name}-mysql-replica"
  replicate_source_db    = aws_db_instance.primary.identifier
  instance_class         = var.rds_instance_class
  storage_encrypted      = true
  publicly_accessible    = false
  skip_final_snapshot    = true

  tags = {
    Name = "${var.project_name}-mysql-replica"
  }
}