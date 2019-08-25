data "template_file" "client_config" {
  count = "${length(var.instance_client_ips)}"
  template = "${file("files/client_config.hcl.tpl")}"

  vars = {
    hostname = "nomad-client-${format("%03d", count.index + 1)}"
  }
}

resource "aws_instance" "nomad_client" {
  ami                         = "${lookup(var.client_ami, var.region)}"
  instance_type               = "${var.instance_type}"
  key_name                    = "${var.key_name}"
  subnet_id                   = "${module.vpc_basic.public_subnet_id}"
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
    host     = self.public_ip
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
      "powershell.exe -File C:\\Windows\\Temp\\nomad-setup.ps1 ${var.nomad_version}",
    ]
  }

  provisioner "remote-exec"{
    inline = [
       "C:\\ProgramData\\Chocolatey\\bin\\nssm.exe install Nomad \"c:\\nomad\\nomad.exe\" \"agent -config c:\\nomad\\windows.hcl\"",
       "powershell.exe start-service nomad"
    ]
  }

  tags = {
    Name = "nomad-client-${format("%03d", count.index + 1)}"
  }

  count = "${length(var.instance_client_ips)}"
}

resource "aws_instance" "nomad_server" {
  ami                         = "${lookup(var.server_ami, var.region)}"      //need to do a lookup later
  instance_type               = "t2.micro"
  key_name                    = "${var.key_name}"
  subnet_id                   = "${module.vpc_basic.public_subnet_id}"
  private_ip                  = "${var.instance_server_ips}"
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
    host        = self.public_ip
  }

  provisioner "file" {
    source      = "files/nomad-setup.sh"
    destination = "/tmp/nomad-setup.sh"
  }

  #download and install nomad server as a service
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/nomad-setup.sh",
      "/tmp/nomad-setup.sh ${var.nomad_version}",
    ]
  }

  #copy some examples to the target nomad server
  provisioner "file" {
    source      = "files/samples"
    destination = "/home/ubuntu/nomad-jobs/samples"
  }

  provisioner "file" {
    source      = "files/samples/powershell-cmd-batch.hcl"
    destination = "/home/ubuntu/nomad-jobs/powershell-cmd-batch.hcl"
  }

  tags = {
    Name = "nomad-server-1"
  }
}


