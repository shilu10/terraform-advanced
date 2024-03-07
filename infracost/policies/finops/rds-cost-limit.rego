package infracost

import rego.v1

__rego_metadata__ := {
  "name": "Limit RDS monthly cost",
  "description": "Block or alert if the projected monthly cost of any RDS instance exceeds $100.\nHelps prevent runaway DB costs in non-production environments.",
  "severity": "HIGH",
  "resource_types": ["aws_db_instance"],
}

deny contains msg if {
  input.resource_type == "aws_db_instance"
  input.monthly_cost > 100
  msg := sprintf("Monthly cost (%.2f USD) for RDS instance exceeds $100", [input.monthly_cost])
}
