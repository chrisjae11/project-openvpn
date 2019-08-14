resource "aws_instance" "openvpn-server" {
  ami = "${data.aws_ami.openvpn.id}"
  instance_type = "t2.small"
  key_name = "${aws_key_pair.mykeypair.key_name}"
  subnet_id = "${module.vpc.public_subnets[1]}"
  vpc_security_group_ids = ["${aws_security_group.openvpn.id}"]

  tags = {
    Name = "openvpn-server"
  }

  provisioner "local-exec" {
    command =<<EOD
cat <<EOF > aws_hosts
[vpn]
${aws_instance.openvpn-server.public_ip}
[vpn:vars]
domain=${aws_instance.openvpn-server.public_ip}
EOF
EOD
  }
}

resource "null_resource" "ansible-provisioner" {
  provisioner "local-exec" {
    command = "aws ec2 wait instance-status-ok --instance-ids ${aws_instance.openvpn-server.id} && ansible-playbook -i aws_hosts ../ansible/ovpn-config.yml"

  }
}
