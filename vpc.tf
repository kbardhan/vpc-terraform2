provider "aws" {
  region  = "ap-south-1"
  profile= "KBworld"
}

resource "aws_vpc" "myvpc" {
  cidr_block       = "192.168.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "Kbvpc-007"
  }
}

resource "aws_internet_gateway" "kbigw" {
  vpc_id = "${aws_vpc.myvpc.id}"

  tags = {
    Name = "kb7-igw"
  }
}

resource "aws_subnet" "public" {
  vpc_id     = "${aws_vpc.myvpc.id}"
  cidr_block = "192.168.0.0/24"
  availability_zone = "ap-south-1a"

  tags = {
    Name = "kb-subnet-1a"
  }
}

resource "aws_subnet" "private" {
  vpc_id     = "${aws_vpc.myvpc.id}"
  cidr_block = "192.168.1.0/24"
  availability_zone = "ap-south-1b"

  tags = {
    Name = "kb-subnet-1b"
  }
}



resource "aws_route_table" "route_tab" {
  vpc_id = "${aws_vpc.myvpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.kbigw.id}"
  }

  tags = {
    Name = "kb-route"
  }
}

resource "aws_route_table_association" "rtassociate" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.route_tab.id
}

resource "aws_key_pair" "deployer" {
  key_name   = "test1"
  public_key ="ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAggE0IQl7GHITchLihcvch5e9OQ+0BlUtslDiweElQ2G70dypJyjOoznjx25dvlKp2qb62ugZYBnsv9VC1vZyiCrZjN23aMi+RvY5NbShXiTGeNbOHtjxSZct+StrFi1PXhgSKJJMmO/NLgsXhXhyjVjQzL0gYS4KTZhnLdjjlAvYvJaYKQOamWXnGK+SoJPgg/x8AhINeUZ5Vu3gaFpSnyCwA4m98iA1Juwcwo1BEISb4YZo+HbcvC3yBh97BmNmyyogXbM84LPNo2IjWvVW93sJ/W+P3tExNCHHu3yrw+295lpTvR2aIhoQqhwi/vqMA/kbz2nyV4hZ7Pk4KSYypw== rsa-key-20200713"

}

resource "aws_security_group" "kbsg1" {
  name        = "wp-sg"
  description = "Allow HTTP,ICMP,SSh"
  vpc_id      = "${aws_vpc.myvpc.id}"

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
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
    Name = "kb-webserver"
  }
}


resource "aws_security_group" "kbsg2" {
  name        = "mysql-sg"
  description = "Allow MYSQL"
  vpc_id      = "${aws_vpc.myvpc.id}"
 
  ingress {
    description = "MYSQL"
    from_port   = 3306
    to_port     = 3306
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
    Name = "kb-Mysql"
  }
}

resource "aws_instance" "wordpress" {
  ami                  = "ami-7e257211"
  instance_type  = "t2.micro"
  associate_public_ip_address = true
  key_name        = "test1"
  vpc_security_group_ids =   [ aws_security_group.kbsg1.id ]
  subnet_id =  "${aws_subnet.public.id}"
  
  tags = {
    Name = "kb-wpos"
  }
}

resource "aws_instance" "MYSQL" {
  ami                  = "ami-08706cb5f68222d09"
  instance_type  = "t2.micro"
  key_name        = "test1"
  vpc_security_group_ids =   [ aws_security_group.kbsg2.id ]
  subnet_id =  "${aws_subnet.private.id}"
  
  tags = {
    Name = "kb-mysql"
  }
}






