provider "aws" {
  region     = "us-west-2"
  access_key = "***************"
  secret_key = "************"
}

# create a custom vpc

resource "aws_vpc" "practice_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames = false

  tags = {
    Name = "demo_vpc"
  }
}

#create subnet

resource "aws_subnet" "practice_subnet" {
  vpc_id     = aws_vpc.practice_vpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "demo_subnet"
  }
}

# create internet gateway

resource "aws_internet_gateway" "practice_igw" {
  vpc_id = aws_vpc.practice_vpc.id

  tags = {
    Name = "demo_igw"
  }
}

# create route table

resource "aws_route_table" "practice_routetable" {
  vpc_id = aws_vpc.practice_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.practice_igw.id
  }

  
  tags = {
    Name = "demo_routetable"
  }
}

# route table association

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.practice_subnet.id
  route_table_id = aws_route_table.practice_routetable.id
}

# create security group

resource "aws_security_group" "allow_tls" {
  name        = "allow_https"
  description = "Allow https inbound traffic"
  vpc_id      = aws_vpc.practice_vpc.id

  ingress {
    description      = "https web traffic from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }

 ingress {
    description      = "ssh from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }

   ingress {
    description      = "http web traffic from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }

  tags = {
    Name = "web server security grp"
  }
}

resource "aws_instance" "first_server" {
  ami           = "ami-0c65adc9a5c1b5d7c"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.practice_subnet.id
  vpc_security_group_ids = [aws_security_group.allow_tls.id]
  availability_zone = "us-west-2a"
  key_name = "devopskeypair"
}