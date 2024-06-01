# Create a security group for the RDS instance
resource "aws_security_group" "rds_sg" {
  vpc_id = aws_vpc.vpc_1.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.tag_name}-rds-sg"
  }

}

# Create the RDS MySQL instance
resource "aws_db_instance" "mysql" {
  allocated_storage    = 10
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  db_name              = "wordpressdb"
  username             = aws_ssm_parameter.db_username.value
  password             = aws_ssm_parameter.db_password.value
  parameter_group_name = "default.mysql8.0"
  publicly_accessible  = true
  skip_final_snapshot  = true

  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  db_subnet_group_name = aws_db_subnet_group.db_subnet_group.name
  tags = {
    Name = "${var.tag_name}-rds-mysql"
  }

}


# Create a DB subnet group
resource "aws_db_subnet_group" "db_subnet_group" {
  name = "main-subnet-group"
  subnet_ids = [
    aws_subnet.private_1.id,
    aws_subnet.private_2.id
  ]

  tags = {
    Name = "${var.tag_name}-subnet-group"
  }

}

# Splitting the endpoint to exclude the port
locals {
  endpoint_without_port = split(":", aws_db_instance.mysql.endpoint)[0]
}

# Define SSM Parameters
resource "aws_ssm_parameter" "db_endpoint" {
  name  = "/wordpress/db_endpoint"
  type  = "String"
  value = local.endpoint_without_port

  tags = {
    Name = "WordPress DB Endpoint"
  }
}

resource "aws_ssm_parameter" "db_username" {
  name  = "/wordpress/db_username"
  type  = "String"
  value = "admin"

  tags = {
    Name = "Wordpress DB Username"
  }
}

resource "aws_ssm_parameter" "db_password" {
  name  = "/wordpress/db_password"
  type  = "String"
  value = "mypassword" # Got to use another method to get password later

  tags = {
    Name = "Wordpress DB Password"
  }
}

