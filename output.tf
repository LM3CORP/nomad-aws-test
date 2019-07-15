
output "nomad_server_ip" {
  value = ["${aws_instance.nomad_server.*.public_ip}"]
}

output "nomad_public_dns" {
  value = ["${aws_instance.nomad_server.*.public_dns}"]
}



