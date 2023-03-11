variable "hostname" {
  description = "the hostname of the instace"
  type        = string
  default     = "ubuntu"
}

variable "static_ip" {
  description = "the static_ip of the instace"
  type        = string
  default     = "ubuntu"
}

variable "pool_name" {
  description = "name of the libvirt_pool"
  type        = string
  default     = "ubuntu"
}
