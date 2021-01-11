variable "vm_name" {
  type =  string
  default = "kubernetes-focal"
}

variable "disk_size" {
  type =  number
  default = 30720
}

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
