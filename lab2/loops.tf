output "network" {
  value = {for k, v in var.network: k=>v if k == "private"}
}

variable "network" {
  type = map(map(any))
  default = {
      vpc_cidr    = {
        cidr = "10.0.0.0/16"
      }
      private = {
        cidr = "10.0.1.0/24"
      }
      public = {
        cidr = "10.0.2.0/24"
      }
  }
}
variable "cidr_list" {
  default = ["10.0.2.0/24","10.0.3.0/24" ]
}


resource "aws_vpc" "vpc" {
  for_each = {for k, v in var.network: k=>v if k == "vpc_cidr"}
  cidr_block = each.value["cidr"]
}

resource "aws_vpc" "vpc_count" {
  count = var.cidr_list
  cidr_block = var.cidr_list[count.index]
}
