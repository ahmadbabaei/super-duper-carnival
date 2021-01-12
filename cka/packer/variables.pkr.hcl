variable "cpu" {
  type =  number
  default = 2
}

variable "memory" {
  type =  number
  default = 2048
}

variable "ssh_username" {
  type =  string
  default = "anisa"
}

variable "ssh_password" {
  type =  string
  default = "qazwsx"
  sensitive = true
}

variable "kube_version" {
  type =  string
  default = "1.18.12"
}

variable "os_basename" {
  type =  string
  default = "focal"
}