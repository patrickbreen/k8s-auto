variable "hostnames" {
  description = "my hostnames"
  type        = map(string)
  default     = {
    "control1": "192.168.0.31",
    "control2": "192.168.0.32",
    "control3": "192.168.0.33",
    "worker1": "192.168.0.34",
    "worker2": "192.168.0.35",
    "worker3": "192.168.0.36"
  }
}

