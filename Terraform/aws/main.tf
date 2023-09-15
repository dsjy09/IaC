# The default provider configuration; resources that begin with `aws_` will use
# it as the default, and it can be referenced as `aws`.
provider "aws" {
  region = "us-east-1"
  access_key = var.access_key
  secret_key = var.secret_key
}

### Format of the resources ###
# resource "<provider>_<resource_type>" "name" {
#     #config option
#     #key
#     #key2
# }

### Sample Project ###
# 1.Create VPC
# 2.Create Internet Gateway
# 3.Create Custom Route Table
# 4.Create a subnet
# 5.Associate subnet with Route Table
# 6.Create Security group to allow port 22,80,443
# 7.Create a network interface with an ip in the subnet that was created in step 4
# 8.Assign an elastic IP to the network interface created in step 7
# 9.Create Ubuntu server and install enable apache2

###Launch VPC###
resource "aws_vpc" "firstvpc" {
    cidr_block = "10.0.0.0/16"
    tags = {
        Name="production"
    }
}

### Create internet gateway ###
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.firstvpc.id
}

### Create custom route table ###
resource "aws_route_table" "prod-route-table" {

  vpc_id = aws_vpc.firstvpc.id

  route {
    cidr_block="0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name="prod"
  }

}

###Launch subnet###
resource "aws_subnet" "subset-1" {
    vpc_id = aws_vpc.firstvpc.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-east-1a"

    tags = {
      Name="prod-subnet"
    }
}

# Associate subnet with route table

resource "aws_route_table_association" "a" {
  subnet_id = aws_subnet.subset-1.id
  route_table_id = aws_route_table.prod-route-table.id
}

### Create security group ###

resource "aws_security_group" "allow_web" {
  name        = "allow_web"
  description = "Allow web inbound traffic"
  vpc_id      = aws_vpc.firstvpc.id

  ingress {
    description      = "HTTPS"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_web"
  }
}

### Create network interface ###

resource "aws_network_interface" "web-server-nic" {
  subnet_id       = aws_subnet.subset-1.id
  private_ips     = ["10.0.1.51"]
  security_groups = [aws_security_group.allow_web.id]
}

### Create Elastic IP : this relies on aws internet getway deployed first ###

resource "aws_eip" "one" {
  domain                    = "vpc"
  network_interface         = aws_network_interface.web-server-nic.id
  associate_with_private_ip = "10.0.1.51"
  depends_on =[aws_internet_gateway.gw]
}

output "server_public_ip" {
  value=aws_eip.one.private_ipmain
}

### Create Ubuntu server and install enable apache2 ###

resource "aws_instance" "web-server" {
  ami           = "ami-053b0d53c279acc90"
  instance_type = "t2.micro"
  availability_zone = "us-east-1a"
  key_name="main-key"

  network_interface {
    device_index = 0
    network_interface_id = aws_network_interface.web-server-nic.id
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install apache2 -y
              sudo systemctl start apache2
              sudo bash -c 'echo your very first web server > /var/www/html/index.html'
              EOF
              
  tags = {
    Name = "helloworld"
  }
}