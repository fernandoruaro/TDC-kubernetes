output "etcd_public_ip" {
  value = "${aws_instance.etcd.public_ip}"
}

output "master_public_ip" {
  value = "${aws_instance.master.public_ip}"
}

output "minion_public_ips" {
  value = "${join(",", aws_instance.minion.*.public_ip)}"
}
