
resource "aws_eip" "nat" {
    instance = "${aws_instance.nat.id}"
    vpc = true
}

resource "aws_key_pair" "web-example-terraform" {
  key_name = "web-example"
  public_key = "${file("ssh/id_rsa.pub")}"
}

resource "aws_security_group" "nat" {
  name = "sg_nat"
  description = "Security group for nat instances that allows SSH and VPN traffic from internet"
  vpc_id = "${aws_vpc.main.id}"

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 1194
    to_port   = 1194
    protocol  = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "default" {
  name = "sg_default"
  description = "Default security group that allows inbound and outbound traffic from all instances in the VPC"
  vpc_id = "${aws_vpc.main.id}"

  ingress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    self        = true
  }

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    self        = true
  }
}

resource "aws_instance" "nat" {
  ami = "ami-2757f631"
  instance_type = "t2.micro"
  subnet_id = "${aws_subnet.public.0.id}"
  vpc_security_group_ids = ["${aws_security_group.default.id}", "${aws_security_group.nat.id}"]
  key_name = "${aws_key_pair.web-example-terraform.key_name}"
  source_dest_check = false
  tags = {
    Name = "nat"
  }
  connection {
    user = "ubuntu"
    private_key = "${file("./ssh/id_rsa")}"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo iptables -t nat -A POSTROUTING -j MASQUERADE",
      "echo '1' | sudo tee /proc/sys/net/ipv4/ip_forward",
      "curl -sSL https://get.docker.com/ | sudo sh",
      "sudo mkdir -p /etc/openvpn",
      "sudo docker run --name ovpn-data -v /etc/openvpn busybox",
      "sudo docker run --volumes-from ovpn-data --rm kylemanna/openvpn ovpn_genconfig -p ${var.vpc_cidr_network}.0.0/16 -u udp://${aws_instance.nat.public_ip}"
    ]
  }
}
