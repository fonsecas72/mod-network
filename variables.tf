variable "aws_region" {
  default = "us-east-1"
}

variable "vpc_cidr_network" {
  default = "172.31"
}

variable "tag_environment" {}

variable "tag_project" {}

variable "zones" {
  type = "map"
  default = {
    zone0 = "a"
    zone1 = "b"
    zone2 = "c"
  }
}

variable "public_cidr_hosts" {
  type = "map"
  default = {
    zone0 = "0.0/24"
    zone1 = "1.0/24"
    zone2 = "2.0/24"
  }

}variable "private_cidr_hosts" {
  type = "map"
  default = {
    zone0 = "3.0/24"
    zone1 = "4.0/24"
    zone2 = "5.0/24"
  }
}
