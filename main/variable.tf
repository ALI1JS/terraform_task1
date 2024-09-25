variable "access_key" {
   type = string
}

variable "secret_access_key" {
   type = string
}

variable "region" {
   type = string
}

variable "subnet_private_cider" {
  type = string
}

variable "subnet_public_cider" {
   type = string
}

variable "internet_gateway_name" {
  type = string
}

variable "nat_gateway_name" {
   type = string
}

variable "subnet_private_name" {
   type = string
}

variable "subnet_public_name" {
   type = string
}

variable "route_public_name" {
   type = string
}

variable "route_public_cider" {
   type = string
}

variable "route_private_name" {
   type = string
}

variable "route_private_cider" {
   type = string
}

variable "ec2_ami_image" {
   type = string
}

variable "ec2_name" {
   type = string
}

variable "ec2_type" {
   type = string
}