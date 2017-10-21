### VPC ###
resource "aws_vpc" "kubernetes" {
  cidr_block = "172.21.0.0/16"
  enable_dns_hostnames = true
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_subnet" "kubernetes" {
  vpc_id = "${aws_vpc.kubernetes.id}"
  cidr_block = "172.21.0.0/16"
  availability_zone = "us-east-1b"
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.kubernetes.id}"
}

resource "aws_route_table" "kubernetes" {
    vpc_id = "${aws_vpc.kubernetes.id}"
    route {
      cidr_block = "0.0.0.0/0"
      gateway_id = "${aws_internet_gateway.gw.id}"
    }

    lifecycle {
      ignore_changes = ["*"]
    }
}

resource "aws_route_table_association" "kubernetes" {
  subnet_id = "${aws_subnet.kubernetes.id}"
  route_table_id = "${aws_route_table.kubernetes.id}"
}


### SECURITY GROUP ###
resource "aws_security_group" "kubernetes" {
  vpc_id = "${aws_vpc.kubernetes.id}"
  name = "kubernetes"

  # Allow all outbound
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all internal
  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    self = true
  }

  # Allow all SSH
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

}


### EC2 INSTANCES ###

module "ami" {
  source = "github.com/terraform-community-modules/tf_aws_ubuntu_ami"
  region = "us-east-1"
  distribution = "xenial"
  virttype = "hvm"
  storagetype = "instance-store"
}

resource "aws_instance" "etcd" {
  count = "1" # 0/1
  ami = "${module.ami.ami_id}"
  instance_type = "m3.medium"
  subnet_id = "${aws_subnet.kubernetes.id}"
  associate_public_ip_address = true
  source_dest_check = false
  vpc_security_group_ids = ["${aws_security_group.kubernetes.id}"]
  key_name = "TDC"

  tags {
    Name = "etcd"
  }
}

resource "aws_instance" "master" {
  count = "1" # 0/1
  ami = "${module.ami.ami_id}"
  instance_type = "m3.medium"
  subnet_id = "${aws_subnet.kubernetes.id}"
  associate_public_ip_address = true
  source_dest_check = false
  vpc_security_group_ids = ["${aws_security_group.kubernetes.id}"]
  key_name = "TDC"

  tags {
    Name = "master"
  }
}

resource "aws_instance" "minion" {
  count = "0" # 0-N
  ami = "${module.ami.ami_id}"
  instance_type = "m3.medium"
  subnet_id = "${aws_subnet.kubernetes.id}"
  associate_public_ip_address = true
  source_dest_check = false
  vpc_security_group_ids = ["${aws_security_group.kubernetes.id}"]
  key_name = "TDC"

  tags {
    Name = "minion"
  }
}
