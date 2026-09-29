variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "100.0.0.0/16"
}
variable "project_name" {
  description = "The name of the project"
  type        = string
  default     = "module-project-name"
}
variable "environment" {
  description = "The environment name"
  type        = string
  default     = "module-environment"
}
variable "owner" {
  description = "The owner of the resources"
  type        = string
  default     = "module-owner"
}
variable "vpc_tags" {
  description = "The tags for the VPC"
  type        = map(string)
  default     = {}
}
variable "igw_vpc_tags" {
  description = "The tags for the Internet Gateway"
  type        = map(string)
  default     = {}
}
variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets; at least one is required for the NAT gateway"
  type        = list(string)

  validation {
    condition     = length(var.public_subnet_cidrs) > 0
    error_message = "At least one public subnet CIDR is required because the NAT gateway uses the first public subnet."
  }
}
variable "public_subnet_tags" {
  description = "The tags for the public subnets"
  type        = map(string)
  default     = {}
}
variable "private_subnet_cidrs" {
  description = "The CIDR blocks for the private subnets"
  type        = list(string)
  default     = []
}
variable "private_subnet_tags" {
  description = "The tags for the private subnets"
  type        = map(string)
  default     = {}
}
variable "database_subnet_cidrs" {
  description = "The CIDR blocks for the database subnets"
  type        = list(string)
  default     = []
}
variable "database_subnet_tags" {
  description = "The tags for the database subnets"
  type        = map(string)
  default     = {}
}
variable "public_route_table_tags" {
  description = "The tags for the public route table"
  type        = map(string)
  default     = {}
}
variable "private_route_table_tags" {
  description = "The tags for the private route table"
  type        = map(string)
  default     = {}
}
variable "database_route_table_tags" {
  description = "The tags for the database route table"
  type        = map(string)
  default     = {}
}
variable "eip_tags" {
  description = "The tags for the Elastic IPs"
  type        = map(string)
  default     = {}
}
variable "nat_gateway_tags" {
  description = "The tags for the NAT Gateway"
  type        = map(string)
  default     = {}
}