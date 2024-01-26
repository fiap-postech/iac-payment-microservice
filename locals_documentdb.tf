locals {
  documentdb = {
    sg = {
      name        = "${local.project_name}-documentdb-sg"
      description = "${local.project_name} documentdb security group"

      ingress = {
        description      = "Allow Request From ECS"
        from_port        = 27017
        to_port          = 27017
        protocol         = "tcp"
        cidr_blocks      = []
        ipv6_cidr_blocks = []
        prefix_list_ids  = []
        self             = null
      }

      egress = {
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
      }
    }

    cluster = {
      parameter_group = {
        name   = "${local.project_name}-cluster-parameter-group"
        family = "docdb4.0"
        parameter = {
          name  = "tls"
          value = "disabled"
        }
      }

      instance = {
        count             = 2
        instance_class    = "db.t3.medium"
        identifier        = "instance-${local.project_name}-"
        apply_immediately = true
      }

      subnet_group = {
        name = "${local.project_name}-docdb-subnet-group"
      }

      cluster_identifier      = "${local.project_name}-cluster"
      engine                  = "docdb"
      master_username         = "sys_${replace(local.project_name, "-", "_")}"
      master_secret_name      = "service/${local.context_name}/Database/Credential"
      backup_retention_period = 0
      skip_final_snapshot     = true
      storage_encrypted       = true
      deletion_protection     = false
      availability_zones = [
        "sa-east-1a"
      ]
    }
  }
}