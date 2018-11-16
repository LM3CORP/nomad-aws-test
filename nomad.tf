provider "aws" {
  region = "${var.region}"
}

module "vpc" {
  source        = "github.com/turnbullpress/tf_vpc.git?ref=v0.0.1"
  name          = "docker"
  cidr          = "10.0.0.0/16"
  public_subnet = "10.0.1.0/24"
}

data "template_file" "client_config" {
  count = "${length(var.instance_client_ips)}"
  template = "${file("files/client_config.hcl.tpl")}"

  vars {
    hostname = "nomad-client-${format("%03d", count.index + 1)}"
  }
}

resource "aws_instance" "nomad_client" {
  ami                         = "${lookup(var.client_ami, var.region)}"
  instance_type               = "${var.instance_type}"
  key_name                    = "${var.key_name}"
  subnet_id                   = "${module.vpc.public_subnet_id}"
  private_ip                  = "${var.instance_client_ips[count.index]}"
  associate_public_ip_address = true
  user_data                   = "${file("files/nomad_client_bootstrap.ps1")}"
  get_password_data           = "true"

  vpc_security_group_ids = [
    "${aws_security_group.nomad_client_incoming_sg.id}",
  ]

  connection {
    type     = "winrm"
    agent    = false
    port     = "5986"
    user     = "Administrator"
    password = "${rsadecrypt(self.password_data,file("~/.ssh/lm3corp.pem"))}"
    insecure = true
    use_ntlm = false
    https    = true
    timeout  = "10m"
  }

  provisioner "file" {
    source      = "files/nomad-setup.ps1"
    destination = "C:\\Windows\\Temp\\nomad-setup.ps1"
  }

  provisioner "file" {
    content      = "${element(data.template_file.client_config.*.rendered, count.index)}"
    destination = "C:\\nomad\\windows.hcl"
  }

  provisioner "remote-exec" {
    inline = [
      "powershell.exe -File C:\\Windows\\Temp\\nomad-setup.ps1",
    ]
  }

  provisioner "remote-exec"{
    inline = [
       "C:\\ProgramData\\Chocolatey\\bin\\nssm.exe install Nomad \"c:\\nomad\\nomad.exe\" \"agent -config c:\\nomad\\windows.hcl\"",
       "powershell.exe start-service nomad"
    ]
  }

  tags {
    Name = "nomad-client-${format("%03d", count.index + 1)}"
  }

  count = "${length(var.instance_client_ips)}"
}

resource "aws_instance" "nomad_server" {
  ami                         = "${lookup(var.server_ami, var.region)}"      //need to do a lookup later
  instance_type               = "t2.micro"
  key_name                    = "${var.key_name}"
  subnet_id                   = "${module.vpc.public_subnet_id}"
  private_ip                  = "${var.instance_server_ips[0]}"
  associate_public_ip_address = true
  user_data                   = "${file("files/nomad_server_bootstrap.sh")}"

  vpc_security_group_ids = [
    "${aws_security_group.nomad_server_incoming_sg.id}",
  ]

  connection {
    type        = "ssh"
    agent       = false
    user        = "ubuntu"
    private_key = "${file("~/.ssh/lm3corp.pem")}"
  }


  #copy some examples to the target nomad server
  provisioner "file" {
    source      = "files/samples/docker-batch.hcl"
    destination = "/home/ubuntu/nomad-jobs/docker-batch.hcl"
  }

  provisioner "file" {
    source      = "files/samples/powershell-cmd-batch.hcl"
    destination = "/home/ubuntu/nomad-jobs/powershell-cmd-batch.hcl"
  }

  provisioner "file" {
    source      = "files/nomad-setup.sh"
    destination = "/tmp/nomad-setup.sh"
  }

  #download and install nomad server as a service
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/nomad-setup.sh",
      "/tmp/nomad-setup.sh",
    ]
  }

  tags {
    Name = "nomad-server-1"
  }

  count = 1
}

resource "aws_security_group" "nomad_client_incoming_sg" {
  name        = "nomad_client_inbound"
  description = "Allow Incoming from Nomad Server"
  vpc_id      = "${module.vpc.vpc_id}"

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
  vpc_id      = "${module.vpc.vpc_id}"

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
