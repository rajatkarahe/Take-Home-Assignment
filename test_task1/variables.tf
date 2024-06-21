variable "region" {
  description = "AWS Deployment region"
  type        = string
  default     = "us-west-2"
}

variable "availability_zone" {
  description = "Availability Zone"
  type        = string
  default     = "us-west-2a"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "ami_id" {
  description = "Amazon Machine Image (AMI) ID for the instance"
  type        = string
  default     = "ami-0cf2b4e024cdb6960"
}

variable "instance_type" {
  description = "Instance type for the EC2 instance"
  type        = string
  default     = "t2.micro"
}
