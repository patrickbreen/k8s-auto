variable "hostnames" {
  description = "my hostnames"
  type        = list(string)
  default     = ["control1", "control2", "control3", "worker1", "worker2", "worker3"]
}

