package infracost

import rego.v1

__rego_metadata__ := {
  "name": "Limit Lambda monthly cost",
  "description": "Avoid expensive Lambda configurations",
  "severity": "HIGH",
  "resource_types": ["aws_lambda_function"],
}

deny contains msg if {
  input.resource_type == "aws_lambda_function"
  input.monthly_cost > 50
  msg := sprintf("Monthly cost (%.2f USD) for Lambda exceeds $50", [input.monthly_cost])
}
