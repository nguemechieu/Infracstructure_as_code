# Configure the AWS provider
provider "aws" {
  region = "us-east-1" # Set your desired region
}

# Create a VPC
resource "aws_vpc" "tradeadviser_vpc" {
  cidr_block = "10.0.0.0/16"
}

# Create a public subnet within the VPC
resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.tradeadviser_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a" # Set your desired AZ
  map_public_ip_on_launch = true
}

# Create a security group allowing inbound SSH and HTTP traffic
resource "aws_security_group" "app_sg" {
  name        = "tradeadviser-app-sg"
  description = "Security group for TradeAdviser app"
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Launch an EC2 instance in the public subnet
resource "aws_instance" "app_instance" {
  ami           = "ami-xxxxxxxxxxxxxx" # Specify your desired AMI ID
  instance_type = "t2.micro"           # Choose the instance type that suits your needs
  subnet_id     = aws_subnet.public_subnet.id
  key_name      = "your-key-pair"      # Specify your key pair name

  security_groups = [aws_security_group.app_sg.name]

  tags = {
    Name = "tradeadviser-app-instance"
  }
}

# Output the public IP address of the EC2 instance
output "public_ip" {
  value = aws_instance.app_instance.public_ip
}