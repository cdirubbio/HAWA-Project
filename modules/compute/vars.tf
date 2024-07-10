variable "user_data_path" {
  description = "File Path to User Data for EC2 Instance"
  type        = string
}

variable "instance_security_groups" {
  description = "List of security groups to apply to instance(s)"
  type        = list(string)
}

variable "lb_security_groups" {
  description = "List of security groups to apply to the Application Load balancer"
  type        = list(string)
}

variable "priv_subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs that Instances can be provisioned in."
}

variable "pub_subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs that Instances can be provisioned in."
}

variable "vpc_id" {
  default = "ID of VPC to be used in the module"
  type    = string
}

variable "priv_subnet_count" {
  type        = number
  description = "Number of private subnets"
}