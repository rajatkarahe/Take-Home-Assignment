# VPC
resource "aws_vpc" "nginx_vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "nginx-vpc"
  }
}

# Subnet
resource "aws_subnet" "nginx_subnet" {
  vpc_id            = aws_vpc.nginx_vpc.id
  cidr_block        = var.public_subnet_cidr
  availability_zone = "us-west-2a"
  map_public_ip_on_launch = true
  tags = {
    Name = "nginx-subnet"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "nginx_igw" {
  vpc_id = aws_vpc.nginx_vpc.id
  tags = {
    Name = "nginx-igw"
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
    Name = "nginx-route-table"
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
  name        = "nginx-sg"
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
    Name = "nginx-sg"
  }
}

# EC2 Instance
resource "aws_instance" "nginx_instance" {
  ami                    = "ami-0cf2b4e024cdb6960"  # Ubuntu 20.04 AMI in us-west-2
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.nginx_subnet.id
  vpc_security_group_ids = [aws_security_group.nginx_sg.id]
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y nginx
              systemctl start nginx
              systemctl enable nginx
              EOF

  tags = {
    Name = "nginx-server"
  }
}
