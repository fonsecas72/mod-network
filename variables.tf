variable "aws_region" {
  default = "eu-west-1"
}

variable "vpc_cidr_network" {
  default = "10.250"
}

variable "tag_environment" {}

variable "tag_project" {}

variable "zones" {
  default = {
    zone0 = "a"
    zone1 = "b"
    zone2 = "c"
  }
}

variable "public_cidr_hosts" {
  default = {
    zone0 = "0.0/24"
    zone1 = "1.0/24"
    zone2 = "2.0/24"
  }
}
