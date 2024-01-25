provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      "workload" = "payment-service"
    }
  }
}

provider "mysql" {
  username = aws_db_instance.tech_challenge_db.username
  password = aws_db_instance.tech_challenge_db.password
  endpoint = aws_db_instance.tech_challenge_db.endpoint
}
