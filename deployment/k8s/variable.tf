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

variable "fgt_byol_license" {
  type=string
  default = ""
}

variable "key_name" {
   type=string
   default ="aw-key-fortigate"
}

variable "cfosLicense" {
   type=string
   default = "/home/i/202301/deployment/k8s/fos_license.yaml"
}

variable "key_location" {
   type=string
   default = "~/.ssh/id_rsa"
}

variable "dockerinterbeing" {
    type=string
    default = "/home/i/202301/deployment/private/dockerinterbeing.yaml"
}
