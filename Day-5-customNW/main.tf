# Creation of VPC
resource "aws_vpc" "dev_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "dev-vpc"
  }
}

# Creation of subnets
resource "aws_subnet" "dev_subnet1" {
  vpc_id     = aws_vpc.dev_vpc.id
  cidr_block = "10.0.0.0/24"
  tags = {
    Name = "dev-subnet-1"
  }
}

resource "aws_subnet" "dev_subnet2" {
  vpc_id     = aws_vpc.dev_vpc.id
  cidr_block = "10.0.1.0/24"
  tags = {
    Name = "dev-subnet-2"
  }
}

# Creation IG and attach to vpc
resource "aws_internet_gateway" "dev_igw" {
  vpc_id = aws_vpc.dev_vpc.id
  tags = {
    Name = "dev-igw"
  }
}


# Elastic IP for NAT Gateway
resource "aws_eip" "dev_nat_eip" {
  domain = "vpc"

  tags = {
    Name = "dev-nat-eip"
  }
}


# Creation NAt Gateway and attach to vpc
# NAT Gateway for private subnet
resource "aws_nat_gateway" "dev_natgw_private" {
  allocation_id = aws_eip.dev_nat_eip.id
  subnet_id     = aws_subnet.dev_subnet1.id

  tags = {
    Name = "dev-natgw-private"
  }

  depends_on = [aws_internet_gateway.dev_igw]
}

# Private Route Table
resource "aws_route_table" "dev_private_rt" {
  vpc_id = aws_vpc.dev_vpc.id

  tags = {
    Name = "dev-private-rt"
  }
}

# Route for private subnet via NAT Gateway
resource "aws_route" "private_nat_route" {
  route_table_id         = aws_route_table.dev_private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.dev_natgw_private.id
}

# Associate private subnet with private route table
resource "aws_route_table_association" "dev_private_assoc" {
  subnet_id      = aws_subnet.dev_subnet2.id
  route_table_id = aws_route_table.dev_private_rt.id
}


# Creation of route table and edit routes 
resource "aws_route_table" "dev_rt" {
  vpc_id = aws_vpc.dev_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dev_igw.id
  }
}

# Creation of subnet associations 
resource "aws_route_table_association" "dev_rt_assoc1" {
  subnet_id      = aws_subnet.dev_subnet1.id
  route_table_id = aws_route_table.dev_rt.id
}

resource "aws_route_table_association" "dev_rt_assoc2" {
  subnet_id      = aws_subnet.dev_subnet2.id
  route_table_id = aws_route_table.dev_rt.id
}

# Creation Security Group
resource "aws_security_group" "dev_sg" {
  name   = "allow_tls"
  vpc_id = aws_vpc.dev_vpc.id
  tags = {
    Name = "dev-sg"
  }
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Creation of server
resource "aws_instance" "dev_server" {
  ami                    = "ami-0c1fe732b5494dc14"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.dev_subnet1.id
  vpc_security_group_ids = [aws_security_group.dev_sg.id]
  tags = {
    Name = "dev-server"
  }
}
