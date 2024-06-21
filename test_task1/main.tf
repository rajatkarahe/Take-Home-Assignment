locals {
  vpc_name              = "nginx-vpc"
  subnet_name           = "nginx-subnet"
  internet_gateway_name = "nginx-igw"
  route_table_name      = "nginx-route-table"
  security_group_name   = "nginx-sg"
  instance_name         = "nginx-server"
}

# VPC
resource "aws_vpc" "nginx_vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = local.vpc_name
  }
}

# Subnet
resource "aws_subnet" "nginx_subnet" {
  vpc_id                  = aws_vpc.nginx_vpc.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true
  tags = {
    Name = local.subnet_name
  }
}

# Internet Gateway
resource "aws_internet_gateway" "nginx_igw" {
  vpc_id = aws_vpc.nginx_vpc.id
  tags = {
    Name = local.internet_gateway_name
  }
}

# Route Table
resource "aws_route_table" "nginx_route_table" {
  vpc_id = aws_vpc.nginx_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.nginx_igw.id
  }
  tags = {
    Name = local.route_table_name
  }
}

# Route Table Association
resource "aws_route_table_association" "nginx_route_table_association" {
  subnet_id      = aws_subnet.nginx_subnet.id
  route_table_id = aws_route_table.nginx_route_table.id
}

# Security Group
resource "aws_security_group" "nginx_sg" {
  vpc_id      = aws_vpc.nginx_vpc.id
  name        = local.security_group_name
  description = "Allow HTTP traffic"

  ingress {
    from_port   = 80
    to_port     = 80
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
    Name = local.security_group_name
  }
}

# EC2 Instance
resource "aws_instance" "nginx_instance" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.nginx_subnet.id
  vpc_security_group_ids      = [aws_security_group.nginx_sg.id]
  associate_public_ip_address = true

  user_data = templatefile("${path.module}/user_data.tpl", {})


  tags = {
    Name = local.instance_name
  }
}
