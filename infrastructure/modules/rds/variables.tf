variable "name" {
  description = "RDS instance name"
  type        = string
  default     = "my-db-instance"
}

variable "engine" {
  description = "Database engine (e.g. mysql, postgres)"
  type        = string
  default     = "mysql"
}

variable "engine_version" {
  description = "Engine version"
  type        = string
  default     = "8.0"
}

variable "instance_class" {
  description = "Instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Minimum allocated storage (GB)"
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Maximum storage autoscaling (GB)"
  type        = number
  default     = 100
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "mydb"
}

variable "username" {
  description = "Master username"
  type        = string
  default     = "admin"
}

variable "password" {
  description = "Master password"
  type        = string
  sensitive   = true
  default     = "changeMe123!"
}

variable "port" {
  description = "DB port"
  type        = number
  default     = 3306
}

variable "subnet_ids" {
  description = "Subnet IDs for DB subnet group"
  type        = list(string)
  default     = ["subnet-abc123", "subnet-def456"]
}

variable "vpc_security_group_ids" {
  description = "List of VPC security group IDs"
  type        = list(string)
  default     = ["sg-0123456789abcdef0"]
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
  default     = {
    Environment = "dev"
    Project     = "rds-module"
  }
}
