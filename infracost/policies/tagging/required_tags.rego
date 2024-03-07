name: "Ensure required tags are present"
description: "All resources must be tagged with Environment and Owner"
severity: MEDIUM

conditions:
  - resource_type: "*"
    attribute: "tags.Environment"
    operator: "exists"
    
  - resource_type: "*"
    attribute: "tags.Owner"
    operator: "exists"
