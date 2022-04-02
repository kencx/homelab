variable "target_node" {
  type        = string
  description = ""
  default     = "pve"
}

variable "sshkey" {
  type        = string
  description = "Public SSH key"
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDIc7rqDR7KB1TWIOWbaL7yG8//ujgkGCq7L7lt1CsIJia50+gcB4yTFUcJuJPJYu7pLJarKaMMQlzSPl6Mn+doA93JN7dDQ/L5bDfhDny0j7L2+56i3AXINV4sibeyHwXD38Nn5cr/2q7d/5xWjuHGxHhJU5urcEn4I4o3AQyMKsmTY/C6BzUbkxe3jQECFiKyRxUh6Byi/rMSq7w4Gy0kXfcgD8/C5BKBdyMzCP+Ln2L/ywCdXGo2wWU0JpVsfZpY0aZ7B4oqLKqgw+XgUQBaLLpzBwXKV+rrZB9ikBjbUyD7u11kwxkFOb5fLPWjwyJ5sSm/WQjHs87dvH2AinMN root@pve"
}

variable "vm_template_name" {
  type        = string
  description = "VM Template Name"
  default     = "debian-cloudinit"
}
