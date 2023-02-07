variable "vpc_cidr" {
  type = string 
  default = "10.0.0.0/16"
}

variable "vpc_subnet0" {
  type = string
  default = "10.0.1.0/24"
}

variable "instance_type" {
  type        = string
  default     = "t3.large"
}


variable "tcp_from_port" {
  default = "0"
}

variable "tcp_to_port" {
  default = "65535"
}

variable "hostname" {
  default = "subdomain"
}

variable "region" {
  default ="ap-southeast-1"
}


variable "cfosLicense" {
   type=string
   default = ""
}

variable "key_location" {
   type=string
   default = ""
}

variable "dockerinterbeing" {
    type=string
    default = ""
}
