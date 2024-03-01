variable "name" {
  description = "RDS instance name"
  type        = string
}

variable "engine" {
  description = "Database engine (e.g. mysql, postgres)"
  type        = string
}

variable "engine_version" {
  description = "Engine version"
  type        = string
}

variable "instance_class" {
  description = "Instance class"
  type        = string
}

variable "allocated_storage" {
  description = "Minimum allocated storage (GB)"
  type        = number
}

variable "max_allocated_storage" {
  description = "Maximum storage autoscaling (GB)"
  type        = number
  default     = 100
}

variable "db_name" {
  description = "Database name"
  type        = string
}

variable "username" {
  description = "Master username"
  type        = string
}

variable "password" {
  description = "Master password"
  type        = string
  sensitive   = true
}

variable "port" {
  description = "DB port"
  type        = number
  default     = 5432
}

variable "subnet_ids" {
  description = "Subnet IDs for DB subnet group"
  type        = list(string)
}

variable "vpc_security_group_ids" {
  description = "List of VPC security group IDs"
  type        = list(string)
}

variable "multi_az" {
  description = "Enable multi-AZ"
  type        = bool
  default     = false
}

variable "storage_type" {
  description = "Type of storage (gp2, gp3, io1)"
  type        = string
  default     = "gp3"
}

variable "backup_retention_period" {
  description = "Days to retain backups"
  type        = number
  default     = 7
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot on deletion"
  type        = bool
  default     = true
}

variable "publicly_accessible" {
  description = "Whether instance is publicly accessible"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
