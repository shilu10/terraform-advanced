package tagging

__rego_metadata__ := {
  "name": "Ensure required tags are present",
  "description": "All resources must be tagged with Environment and Owner",
  "severity": "MEDIUM",
  "resource_types": ["*"],
}

deny[message] if {
  not input.tags.Environment
  message := sprintf("Resource %v missing required tag: Environment", [input.resource_id])
}

deny[message] if {
  not input.tags.Owner
  message := sprintf("Resource %v missing required tag: Owner", [input.resource_id])
}
