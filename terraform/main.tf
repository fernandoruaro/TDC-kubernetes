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

  ingress {
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
  count = "1" # 0-N
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


######  RECURSOS DE SERVIÇOS  #####

resource "aws_security_group" "k8s_lb_inbound" {
  name = "k8s_inbound"
  description = "Allow inbound traffic for kubernetes load balancers"
  vpc_id = "${aws_vpc.kubernetes.id}"
  ingress {
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
      from_port = 443
      to_port = 443
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_elb" "service" {
  name = "service"
  listener {
    instance_port = 30000
    instance_protocol = "tcp"
    lb_port = 80
    lb_protocol = "tcp"
  }
  security_groups = ["${aws_security_group.k8s_lb_inbound.id}","${aws_security_group.kubernetes.id}"]
  subnets = ["${aws_subnet.kubernetes.id}"]
  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 5
    timeout = 5
    target = "TCP:30000"
    interval = 10
  }
  cross_zone_load_balancing = false
  idle_timeout = 400
  connection_draining = false
  instances = ["${aws_instance.minion.*.id}"]
}
