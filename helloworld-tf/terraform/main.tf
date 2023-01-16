terraform {
  required_version = ">= 0.12.26"
}

variable "subject" {
   type = string
   default = "backend is in s3"
   description = "Subject to hello"
}

output "hello_world" {
  value = "hey hey ya, ${var.subject}!"
}
