resource "aws_subnet" "private" {
  lifecycle { create_before_destroy = true }

  vpc_id = "${aws_vpc.main.id}"
  cidr_block = "${var.vpc_cidr_network}.${lookup(var.private_cidr_hosts, format("%s%d", "zone", count.index))}"
  availability_zone = "${var.aws_region}${lookup(var.zones, format("%s%d", "zone", count.index))}"
  map_public_ip_on_launch = false
  count = 3
  depends_on = ["aws_instance.nat"]

  tags {
    Name = "private_${lookup(var.zones, format("%s%d", "zone", count.index))}.${var.tag_environment}"
    Environment = "${var.tag_environment}"
    Project = "${var.tag_project}"
  }
}

resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    instance_id = "${aws_instance.nat.id}"
  }

  tags {
    Name = "private.${var.tag_environment}"
    Environment = "${var.tag_environment}"
    Project = "${var.tag_project}"
  }
}

resource "aws_route_table_association" "private" {
  subnet_id = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${aws_route_table.private.id}"
  count = 3
}

output "private_subnet_ids" {
  value = "${join(",", aws_subnet.private.*.id)}"
}
