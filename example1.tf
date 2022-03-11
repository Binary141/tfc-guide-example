terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 2.70"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

resource "aws_vpc" "vpc1" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "aws_vpc"
  }
}
resource "aws_subnet" "subnet1" {
  vpc_id     = aws_vpc.vpc1.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "Main"
  }
}


resource "aws_security_group" "allow_ports" {
  name        = "allow_ports"
  description = "Allow inbound traffic"
  vpc_id      = aws_vpc.vpc1.id

  ingress {
    description      = "Ports from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  ingress {
    description      = "Ports from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_ports"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc1.id

  tags = {
    Name = "internet gateway"
  }
}

resource "aws_route_table" "table1" {
  vpc_id = aws_vpc.vpc1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "route_table1"
  }
}

resource "aws_route_table_association" "association1" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.table1.id
}

resource "aws_key_pair" "tf_key" {
  key_name   = "deployer-key2"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDl5RT4W/UUy12zRnjRoaLTUzAt5LPBpYbs+KZ0WhokWbZCGCAYWy3nzhFKpX2px5ZvXV0Xm2n8UmugZGRMeKmISps+xPxEINK5No8pIewi8N97OrjU9ZwSBsY/bfb7scXc7yfGVk7FOU+ZbtaYjhSHZaxSr75HtMVaZyZ2Of6LZJRe0XENfFL2l/N1twCJ70cQuGsslB196vuxutm2s2906Kr9YBmPCAcR1uLGttf3lAIodFYREVvGHUfX1uPagsRD9Sls/M37WAzilj4yxHydhYdTsD+7VW3KmHS+NUBeyHXRmAoj3JQ6PnIdRnAd5jSsPVIc8RRTrE5aymC3cPROV8oIW8Sy+RpKTcJxzxZdjodltqVAA5U/ugiKYyAneMtdHFA8W9hgbn2JitjajrM6ceYWSjFQtd5Pj38W+LG4c9v+Jdst7MihVyyXAQJixQbkCJVJWD1iwwVAEKfIHoXAoo8pyNgRMUGGO95ujoHdod/yg6dLmpRT6ApjTwUQ/g8= bdavidson@scratch-2022"
}

resource "aws_instance" "dev" {
  ami                         = "ami-04505e74c0741db8d"
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.allow_ports.id]
  key_name                    = aws_key_pair.tf_key.id
  subnet_id                   = aws_subnet.subnet1.id
  user_data                   = <<-EOF
         #!/bin/bash
         wget http://cit.dixie.edu/it/3110/joe-notes-2021/terraform/install.sh -O /tmp/install.sh
         chmod +x /tmp/install.sh
         source /tmp/install.sh
         EOF
  tags = {
    Name = "dev"
  }
}

resource "aws_instance" "test" {
  ami                         = "ami-04505e74c0741db8d"
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.allow_ports.id]
  key_name                    = aws_key_pair.tf_key.id
  subnet_id                   = aws_subnet.subnet1.id
  user_data                   = <<-EOF
         #!/bin/bash
         wget http://cit.dixie.edu/it/3110/joe-notes-2021/terraform/install.sh -O /tmp/install.sh
         chmod +x /tmp/install.sh
         source /tmp/install.sh
         EOF
  tags = {
    Name = "test"
  }
}

resource "aws_instance" "prod" {
  ami                         = "ami-04505e74c0741db8d"
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.allow_ports.id]
  key_name                    = aws_key_pair.tf_key.id
  subnet_id                   = aws_subnet.subnet1.id
  user_data                   = <<-EOF
         #!/bin/bash
         wget http://cit.dixie.edu/it/3110/joe-notes-2021/terraform/install.sh -O /tmp/install.sh
         chmod +x /tmp/install.sh
         source /tmp/install.sh
         EOF
  tags = {
    Name = "prod"
  }
}

output "instance_ip_addr" {
  value = aws_instance.dev.public_ip
}
output "instance_ip_addr2" {
  value = aws_instance.test.public_ip
}
output "instance_ip_addr3" {
  value = aws_instance.prod.public_ip
}
