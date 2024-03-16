package test

import (
	"testing"
	"time"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

const (
	localstackURL = "http://localhost:4566"
	localstackRegion = "us-east-1"
)


func TestEcrRepo(t *testing.T){
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir:    "../infrastructure/bootstrap-localstack/dev/ecr-repo",
		TerraformBinary: "terragrunt",

		RetryableTerraformErrors: map[string]string{
			".*unable to verify checksum.*": "Checksum error – retrying",
		},
		MaxRetries:         3,
		TimeBetweenRetries: 5 * time.Second,

		EnvVars: map[string]string{
			"AWS_ACCESS_KEY_ID":     "test",
			"AWS_SECRET_ACCESS_KEY": "test",
			"AWS_DEFAULT_REGION":    localstackRegion,
			"AWS_ENDPOINT_URL":      localstackURL,
		},
	}

	terraform.InitAndApply(t, terraformOptions)

	defer terraform.Destroy(t, terraformOptions)

	ecrRepoUrlsOutput := terraform.OutputMap(t, terraformOptions, "ecr_private_repository_urls")

	t.Logf("Length of ecrRepoUrlsOutput : %d", len(ecrRepoUrlsOutput))
	assert.Equal(t, 2, len(ecrRepoUrlsOutput), "ECR Repos length should be two.")

	// Check key existence
	_, ok1 := ecrRepoUrlsOutput["image_processor_lambda_repo"]
	_, ok2 := ecrRepoUrlsOutput["image_uploader_lambda_repo"]

	assert.True(t, ok1, "image_processor_lambda_repo should exist")
	assert.True(t, ok2, "image_uploader_lambda_repo should exist")
}