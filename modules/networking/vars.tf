variable "vpc_id" {
  type        = string
  description = "ID of the VPC you plan on using"
}

variable "priv_subnet_count" {
  type        = number
  description = "Number of Subnets to create inside the vpc."
  default     = 2

  validation {
    condition     = var.priv_subnet_count > 0
    error_message = "The priv_subnet_count value must be greater than 0."
  }
}