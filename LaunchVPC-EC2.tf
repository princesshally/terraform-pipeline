provider "aws" {
  region     = "us-east-1"
}

# Create a VPC
resource "aws_vpc" "trident-vpc" {
  cidr_block = "10.0.0.0/16"
  
    tags = {
    Name = "trident-vpc"
  }
}
resource "aws_subnet" "trident-public-1a" {
  vpc_id     = "${aws_vpc.trident-vpc.id}"
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "trident-public-1a"
  }
}
resource "aws_subnet" "trident-private-1a" {
  vpc_id     = "${aws_vpc.trident-vpc.id}"
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = false

  tags = {
    Name = "trident-private-1a"
  }
}
resource "aws_subnet" "trident-public-1b" {
  vpc_id     = "${aws_vpc.trident-vpc.id}"
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "trident-public-1a"
  }
}
resource "aws_subnet" "trident-private-1b" {
  vpc_id     = "${aws_vpc.trident-vpc.id}"
  cidr_block = "10.0.4.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = false

  tags = {
    Name = "trident-private-1a"
  }
}
resource "aws_internet_gateway" "trident-IGW" {
  vpc_id = "${aws_vpc.trident-vpc.id}"

  tags = {
    Name = "trident-IGW"
  }
}
resource "aws_route_table" "trident-Public-RT" {
  vpc_id = aws_vpc.default.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.trident-IGW.id}"
  }
}

  tags = {
    Name = "trident-Public-RT"
  }
}
resource "aws_route_table" "trident-Private-RT" {
  vpc_id = "${aws_vpc.trident-vpc.id}"

  tags = {
    Name = "trident-Private-RT"
  }
}
resource "aws_route_table_association" "trident-Public-RT" {
  subnet_id      = "${aws_subnet.trident-public-1a.id}"
  subnet_id      = "${aws_subnet.trident-public-1b.id}"
  route_table_id = "${aws_route_table.trident-Public-RT.id}"
}

resource "aws_route_table_association" "trident-Private-RT" {
  subnet_id      = "${aws_subnet.trident-private-1a.id}"
  subnet_id      = "${aws_subnet.trident-private-1b.id}"
  route_table_id = "${aws_route_table.trident-Private-RT.id}"
}

resource "aws_security_group" "trident-SG" {
  name        = "trident-SG"
  description = "Allow TLS inbound traffic"
  vpc_id      = "${aws_vpc.trident-vpc.id}"

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
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  tags = {
    Name = "trident-SG"
  }
}

#create Rhel 8 Ec2-instance
resource "aws_instance" "web" {
  ami           = "ami-0c322300a1dd5dc79"
  instance_type = "t2.micro"
  subnet_id      = "${aws_subnet.trident-public-1a.id}"
  security_group = "${aws_security_group.trident-SG.id}"
  key_name   = "classkey"
  user_data = <<-EOF
	  #! /bin/bash
    sudo yum update -y
	  sudo yum install httpd -y
	  sudo systemctl start httpd
    EOF

  tags = {
    Name = "Trident-R8"
  }
}
