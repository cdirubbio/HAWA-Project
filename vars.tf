variable "vpc_id" {
  type = string
  description = "ID of VPC to utilize"
}

variable "HCP_org" {
  type = string
  description = "Hashicorp Cloud Organization for terraform init"
}

variable "user_data_path" {
  type = string
  description = "File Path to user data script of file extension .tftpl"
}

variable "priv_subnet_count" {
  type = number
  description = "Number of private subnets to create"
}