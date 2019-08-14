data "aws_ami" "openvpn" {
  most_recent = true
  owners = ["self"]

  filter {
    name = "tag:Name"
    values = ["ovpn-server"]
  }

}
