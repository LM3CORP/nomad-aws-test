
variable "region" {
  type        = "string"
  description = "The AWS region."
  default     = "us-east-1"
}

variable "key_name" {
  description = "The AWS Key pair to use for resources"
  default = "lm3corp"
}

variable "region_list" {
  description = "AWS availability zones"
  default     = ["us-east-1a","us-east-1b"]
}

variable "instance_type" {
  description = "The instance type to launch"
  default = "t2.medium"
}

variable "instance_client_ips" {
  description = "The IPs to use for our client resources"
  default = ["10.0.1.20", "10.0.1.21"]
}

variable "instance_server_ips" {
  description = "The IPs to use for our server resources"
  default = ["10.0.1.50"]
}

variable "server_ami"{
  type = "map"
  default = {
    us-east-1 = "ami-0f9351b59be17920e"
  }
}

variable "client_ami"{
  type = "map"
  default = {
    us-east-1 = "ami-09f9b6f145f221569"
  }
  description = "The AMIs to use for Nomad Clients"
}
