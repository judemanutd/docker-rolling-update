variable "environment" {
  default = "staging"
}

variable "domain" {
}

variable "region" {
  default = "ap-south-1"
}

variable "az" {
  default = "ap-south-1a"
}

variable "profile" {
}

variable "project_name" {
  default = "myProject"
}

variable "server_port" {
  default = 9200
}

# https://serverfault.com/a/978968/622408
# ssh-keygen -P "" -t rsa -b 4096 -m pem -f my-key-pair.pem
variable "instance_public_key" {
}
