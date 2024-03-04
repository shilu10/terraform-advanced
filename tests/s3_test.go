package test

import (
	"testing"
	"strings"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestS3Bucket(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir: "../infrastructure/envs/dev",

		// If using Terragrunt, wrap Terragrunt around Terraform
		TerraformBinary: "terragrunt",
	}

	// Init and apply
	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Get bucket name output
	bucketName := terraform.Output(t, terraformOptions, "s3_bucket_name")

	// Check bucket exists
	awsRegion := "us-east-1"
	assert.True(t, aws.S3BucketExists(t, awsRegion, bucketName))

	// (Optional) Check naming convention
	assert.True(t, strings.HasPrefix(bucketName, "my-dev-"), "Bucket name must start with 'my-dev-'")
}
