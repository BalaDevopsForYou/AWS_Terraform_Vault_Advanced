#"myproject_vpc"

variable "bucket_name" {
  type = string
}

variable "bucket_key" {
  type = string
}

variable "projectname" {
  type = string
}


variable "region" {
  type = string
}

variable "myvpc_cidr" {
  type = string
}

variable "mysubnet1_cidr" {
  type = string
}

variable "mysubnet2_cidr" {
  type = string
}

