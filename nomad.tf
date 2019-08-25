provider "aws" {
  region = "${var.region}"
}

module "vpc_basic" {
  source        = "github.com/turnbullpress/tf_vpc_basic.git?ref=v0.0.1"
  name          = "nomad"
  cidr          = "10.0.0.0/16"
  public_subnet = "10.0.1.0/24"
}

resource "aws_security_group" "nomad_client_incoming_sg" {
  name        = "nomad_client_inbound"
  description = "Allow Incoming from Nomad Server"
  vpc_id      = "${module.vpc_basic.vpc_id}"

  ingress {
    from_port   = "5650"
    to_port     = "5660"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = "3389"
    to_port     = "3389"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = "5986"
    to_port     = "5986"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "nomad_server_incoming_sg" {
  name        = "nomad_server_inbound"
  description = "Allow Incoming from Nomad Clients"
  vpc_id      = "${module.vpc_basic.vpc_id}"

  ingress {
    from_port   = "4646"
    to_port     = "4648"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
