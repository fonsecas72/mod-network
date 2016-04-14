resource "aws_subnet" "public" {
  vpc_id = "${aws_vpc.main.id}"
  cidr_block = "${var.vpc_cidr_network}.${lookup(var.public_cidr_hosts, concat("zone", count.index))}"
  availability_zone = "${var.aws_region}${lookup(var.zones, concat("zone", count.index))}"
  map_public_ip_on_launch = true
  count = 3

  tags {
    Name = "public_${lookup(var.zones, concat("zone", count.index))}.${var.tag_environment}"
    Environment = "${var.tag_environment}"
    Project = "${var.tag_project}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }

  tags {
    Name = "public.${var.tag_environment}"
    Environment = "${var.tag_environment}"
    Project = "${var.tag_project}"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${aws_route_table.public.id}"
  count = 3
}

output "public_subnet_ids" {
  value = "${join(",", aws_subnet.public.*.id)}"
}
