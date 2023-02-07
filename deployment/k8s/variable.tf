variable "instance_type" {
  type        = string
  default     = "t3.large"
}


variable "tcpport" {
  default ="22"
}

variable "ami_image_id" {
   default =""
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
