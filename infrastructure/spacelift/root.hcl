# root.hcl , global config that is shared between dev, stage, prod environments 

# Generate version.tf
generate "version" {
  path      = "version.tf"
  if_exists = "overwrite"
  contents  = <<EOF
terraform {
  required_version = ">= 1.12.0"

  required_providers {
    spacelift = {
      source  = "spacelift-io/spacelift"
      version = "1.26.0"
    }
}
}
EOF
}

# Generate provider.tf
generate "provider" {
    path = "provider.tf"
    if_exists = "overwrite"
    contents = <<EOF
provider "spacelift" {
  api_key_endpoint = "https://shilu-new.app.spacelift.io"
  api_key_id       = "01JZVSFCH3Y994RX73ZJNPSFB3"
  api_key_secret   = "baf84ed55408255142e002b20245a840e287751bfdb33099e085ac9add9cb889"
}
EOF

}