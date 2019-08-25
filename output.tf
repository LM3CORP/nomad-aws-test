
output "nomad_server_ip" {
  value = "${aws_instance.nomad_server.public_ip}"
}

output "nomad_server_public_dns" {
  value = "${aws_instance.nomad_server.public_dns}"
}

output "nomad_client_ips"{
  value = ["${aws_instance.nomad_client.*.public_ip}"]
}

output "nomad_client_public_dns"{
  value = ["${aws_instance.nomad_client.*.public_dns}"]
}