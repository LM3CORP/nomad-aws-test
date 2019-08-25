variable "region" {
  type        = "string"
  description = "The AWS region."
}

variable "key_name" {
  description = "The AWS Key pair to use for resources"
}

variable "region_list" {
  description = "AWS availability zones"
}

variable "instance_type" {
  description = "The instance type to launch"
}

variable "instance_client_ips" {
  description = "The IPs to use for our client resources"
}

variable "instance_server_ips" {
  description = "The IPs to use for our server resources"
}

variable "server_ami" {
  type = "map"

  default = {
    us-east-1 = "ami-0f9351b59be17920e"
  }

  description = "Linux Ubuntu Server AMI"
}

variable "client_ami" {
  type = "map"

  default = {
    us-east-1 = "ami-08225ee56674c40d5"
  }

  description = "Windows 2019 Core Client AMI"
}

variable "nomad_version" {
  type        = "string"
  description = "nomad version"
}
