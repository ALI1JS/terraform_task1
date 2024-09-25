provider "aws" {
   region = var.region
   access_key = var.access_key
   secret_key = var.secret_access_key
}

data "aws_vpc" "prod_vpc" {
  tags = {Name = "vpc1"}
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  owners = ["099720109477"]  # Canonical (official Ubuntu) account ID
}


resource "aws_internet_gateway" "prod_gateway" {
  vpc_id = data.aws_vpc.prod_vpc.id
  tags = {
    Name =  var.internet_gateway_name
  }
}

resource "aws_subnet" "prod_public_subnet" {
    vpc_id = data.aws_vpc.prod_vpc.id
    cidr_block = var.subnet_public_cider
    map_public_ip_on_launch = true
    tags = {
      Name = var.subnet_public_name
    }
}

resource "aws_subnet" "prod_private_subnet" {
    vpc_id = data.aws_vpc.prod_vpc.id
    cidr_block = var.subnet_private_cider
    map_public_ip_on_launch = false 
    tags = {
      Name = var.subnet_private_name
    }
}


resource "aws_eip" "nat_eip" {}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.prod_public_subnet.id

  tags = {
    Name = var.nat_gateway_name
  }
}

resource "aws_route_table" "public_route_table" {
   vpc_id = data.aws_vpc.prod_vpc.id
   
   route {
    cidr_block = var.route_public_cider
    gateway_id = aws_internet_gateway.prod_gateway.id
  }

  tags = {
    Name = var.route_public_name
  }

}

resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.prod_public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table" "private_route_table" {
  vpc_id = data.aws_vpc.prod_vpc.id

  route {
    cidr_block = var.route_private_cider
    nat_gateway_id = aws_nat_gateway.nat_gw.id  # To the NAT Gateway
  }

  tags = {
    Name = var.route_private_name
  }
}

resource "aws_route_table_association" "private_subnet_assoc" {
  subnet_id      = aws_subnet.prod_private_subnet.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_instance" "backend" {
  ami           = data.aws_ami.ubuntu.id 
  instance_type = var.ec2_type          
  subnet_id     = aws_subnet.prod_private_subnet.id

  tags = {
    Name = var.ec2_name
  }
}

output "EC2_status" {
  value = aws_instance.backend.instance_state
  description = "State Backend Instance:"
}


output "EC2_Private_check" {
  value = aws_subnet.prod_private_subnet.map_public_ip_on_launch ? "NO" : "YES"
}

output "EC2_Private_IP" {
   value = aws_instance.backend.private_ip
}
