variable "region" {
  description = "Region for AWS resources"
  type        = string
  default     = "eu-central-1"
}

variable "ec2_ssh_key_name" {
  description = "The SSH Key Name"
  type        = string
  default     = "proto-hackers"
}

variable "ec2_ssh_public_key" {
  description = "The SSH Public Key"
  type        = string
  sensitive   = true
}

variable "access_key" {
  description = "AWS Access Key"
  type        = string
  sensitive   = true
}

variable "secret_key" {
  description = "AWS Secret Key"
  type        = string
  sensitive   = true
}
