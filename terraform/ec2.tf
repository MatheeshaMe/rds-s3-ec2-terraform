/*
 1.EC2 Instance Resource
 2. new Seceurity group

*/


resource "aws_instance" "tf_ec2_instance" {
  ami                         = "ami-0866a3c8686eaeeba"
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.tf_ec2_sg.id]
  key_name                    = "nodejs-mysql"
  user_data                   = <<-EOF
                                #!/bin/bash

                                # Git clone 
                                git clone https://github.com/verma-kunal/nodejs-mysql.git /home/ubuntu/nodejs-mysql
                                cd /home/ubuntu/nodejs-mysql

                                # install nodejs
                                sudo apt update -y
                                sudo apt install -y nodejs npm

                                # edit env vars
                                echo "DB_HOST=${local.rds_endpoint}" | sudo tee .env
                                echo "DB_USER=${aws_db_instance.tf_rds_instance.username}" | sudo tee -a .env
                                sudo echo "DB_PASS=${aws_db_instance.tf_rds_instance.password}" | sudo tee -a .env
                                echo "DB_NAME=${aws_db_instance.tf_rds_instance.db_name}" | sudo tee -a .env
                                echo "TABLE_NAME=users" | sudo tee -a .env
                                echo "PORT=3000" | sudo tee -a .env

                                # start server
                                npm install
                                EOF
  depends_on                  = [aws_s3_object.tf_s3_object]
  user_data_replace_on_change = true
  tags = {
    Name = "node-js-server"
  }
}
# Security group for EC2 instance
resource "aws_security_group" "tf_ec2_sg" {
  name        = "node-js-server-sg"
  description = "Allow SSH and HTTP traffic"
  vpc_id      = "vpc-09425fc9278df7592" # default VPC

  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # allow from all IPs
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "TCP"
    from_port   = 3000 # for nodejs app
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "ec2_public_ip" {
  value = "ssh -i nodejs-mysql.pem ubuntu@ec2-${aws_instance.tf_ec2_instance.public_ip}.compute-1.amazonaws.com"
}
