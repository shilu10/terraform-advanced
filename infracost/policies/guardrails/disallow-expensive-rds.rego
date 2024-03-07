package infracost

import rego.v1

__rego_metadata__ := {
  "name": "Disallow high-cost RDS instance types",
  "description": "Block provisioning of large RDS classes",
  "severity": "HIGH",
  "resource_types": ["aws_db_instance"]
}

deny contains msg if {
  input.resource_type == "aws_db_instance"
  input.attributes.instance_type in ["db.r5.4xlarge", "db.m5.8xlarge"]
  msg := sprintf("RDS instance type '%s' is not allowed due to high cost", [input.attributes.instance_type])
}
