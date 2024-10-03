resource "aws_db_instance" "tf_rds_instance" {
  allocated_storage    = 10
  db_name              = "mydb"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  username             = "praveen"
  password             = "praveen123"
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true
  publicly_accessible = true
  vpc_security_group_ids = [aws_security_group.tf_rds_sg.id]
}

resource "aws_security_group" "tf_rds_sg" {
  name        = "allow mysql"
  description = "Allow MYSQL traffic"
  vpc_id      = "vpc-09425fc9278df7592" # default VPC

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["112.134.198.39/32"] # allow from all IPs
	security_groups = [aws_security_group.tf_ec2_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

locals {
  rds_endpoint = element(split(":",aws_db_instance.tf_rds_instance.endpoint),0)
}

output "rds_endpoint" {
	value = local.rds_endpoint
}
output "rds_db_name" {
	value = aws_db_instance.tf_rds_instance.db_name
}
output "rds_user_name" {
	value = aws_db_instance.tf_rds_instance.username
}