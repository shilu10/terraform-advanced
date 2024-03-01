variable "name" {
  description = "Name prefix for resources"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "List of public subnet CIDRs"
  type        = list(string)
  default     = []
}

variable "private_subnet_cidrs" {
  description = "List of private subnet CIDRs"
  type        = list(string)
  default     = []
}

variable "azs" {
  description = "List of Availability Zones"
  type        = list(string)
  default     = []
}

variable "enable_nat_gateway" {
  description = "Create NAT Gateway (only if private subnets exist)"
  type        = bool
  default     = false
}

variable "enable_dns_support" {
  description = "Enable DNS support in VPC"
  type        = bool
  default     = false
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames in VPC"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}


variable "security_groups" {
  description = "Map of security group configs"
  type = map(object({
    name        = string
    description = string
    ingress     = optional(list(object({
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_blocks = list(string)
      description = optional(string)
    })))
    egress = optional(list(object({
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_blocks = list(string)
      description = optional(string)
    })))
    tags = optional(map(string))
  }))
}
