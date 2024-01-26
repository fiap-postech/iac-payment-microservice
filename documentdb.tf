resource "aws_s3_bucket" "cert_bucket" {
  bucket        = local.documentdb.bucket.name
  force_destroy = true

  tags = {
    Name = local.documentdb.bucket.name
  }
}

resource "aws_s3_object" "static_content" {
  for_each = fileset("./certs/", "**")

  bucket        = aws_s3_bucket.cert_bucket.id
  key           = each.value
  source        = "./certs/${each.value}"
  force_destroy = true
  etag          = filemd5("./certs/${each.value}")

  depends_on = [aws_s3_bucket.cert_bucket]
}

resource "aws_security_group" "documentdb_sg" {
  name        = local.documentdb.sg.name
  description = local.documentdb.sg.description
  vpc_id      = data.aws_vpc.main.id

  ingress = [
    {
      description      = local.documentdb.sg.ingress.description
      from_port        = local.documentdb.sg.ingress.from_port
      to_port          = local.documentdb.sg.ingress.to_port
      protocol         = local.documentdb.sg.ingress.protocol
      cidr_blocks      = local.documentdb.sg.ingress.cidr_blocks
      ipv6_cidr_blocks = local.documentdb.sg.ingress.ipv6_cidr_blocks
      prefix_list_ids  = local.documentdb.sg.ingress.prefix_list_ids
      security_groups = [
        aws_security_group.alb_sg.id
      ]
      self = local.documentdb.sg.ingress.self
    }
  ]

  egress {
    from_port        = local.documentdb.sg.egress.from_port
    to_port          = local.documentdb.sg.egress.to_port
    protocol         = local.documentdb.sg.egress.protocol
    cidr_blocks      = local.documentdb.sg.egress.cidr_blocks
    ipv6_cidr_blocks = local.documentdb.sg.egress.ipv6_cidr_blocks
  }

  tags = {
    Name = local.documentdb.sg.name
  }

  depends_on = [
    aws_security_group.alb_sg
  ]
}

resource "aws_docdb_cluster_parameter_group" "docddb_parameter_group" {
  family = local.documentdb.cluster.parameter_group.family

  parameter {
    name  = local.documentdb.cluster.parameter_group.parameter.name
    value = local.documentdb.cluster.parameter_group.parameter.value
  }

  tags = {
    Name = local.documentdb.cluster.parameter_group.name
  }
}

resource "aws_db_subnet_group" "docdb_subnet_group" {
  name       = local.documentdb.cluster.subnet_group.name
  subnet_ids = [for s in data.aws_subnet.database_selected : s.id]

  tags = {
    Name = local.documentdb.cluster.subnet_group.name
  }

  depends_on = [data.aws_subnet.database_selected]
}

resource "aws_secretsmanager_secret" "app_database_password_secret" {
  name                    = local.documentdb.cluster.master_secret_name
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "app_database_password_version" {
  secret_id     = aws_secretsmanager_secret.app_database_password_secret.id
  secret_string = var.app_database_password

  depends_on = [aws_secretsmanager_secret.app_database_password_secret]
}

resource "aws_docdb_cluster" "docdb_cluster" {
  cluster_identifier      = local.documentdb.cluster.cluster_identifier
  engine                  = local.documentdb.cluster.engine
  master_username         = local.documentdb.cluster.master_username
  master_password         = aws_secretsmanager_secret_version.app_database_password_version.secret_string
  backup_retention_period = local.documentdb.cluster.backup_retention_period
  skip_final_snapshot     = local.documentdb.cluster.skip_final_snapshot
  vpc_security_group_ids = [
    aws_security_group.documentdb_sg.id
  ]
  db_subnet_group_name = aws_db_subnet_group.docdb_subnet_group.name
  storage_encrypted    = local.documentdb.cluster.storage_encrypted
  deletion_protection  = local.documentdb.cluster.deletion_protection
  availability_zones   = local.documentdb.cluster.availability_zones

  depends_on = [
    aws_db_subnet_group.docdb_subnet_group,
    aws_security_group.documentdb_sg,
    aws_secretsmanager_secret_version.app_database_password_version
  ]
}

resource "aws_docdb_cluster_instance" "approval_flow_instance" {
  count              = local.documentdb.cluster.instance.count
  cluster_identifier = aws_docdb_cluster.docdb_cluster.id
  instance_class     = local.documentdb.cluster.instance.instance_class
  identifier         = "${local.documentdb.cluster.instance.identifier}-${count.index}"
  apply_immediately  = local.documentdb.cluster.instance.apply_immediately

  lifecycle {
    prevent_destroy = false
  }

  depends_on = [aws_docdb_cluster.docdb_cluster]
}