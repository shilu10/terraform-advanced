package test

import (
	"testing"
	"time"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/credentials"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/lambda"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

const (
	localstackRegion = "us-east-1"
	localstackURL    = "http://localhost:4566"
)

func TestImageUploaderLambdaWithTerragrunt_Localstack(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir:    "../infrastructure/envs/dev/image-uploader-lambda",
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

		ExtraArgs: terraform.ExtraArgs{
			Init:    []string{"--terragrunt-include-dir", "../infrastructure/envs/dev/image-uploader-lambda"},
			Apply:   []string{"--terragrunt-include-dir", "../infrastructure/envs/dev/image-uploader-lambda", "-auto-approve"},
			Destroy: []string{"--terragrunt-include-dir", "../infrastructure/envs/dev/image-uploader-lambda", "-auto-approve"},
		},
	}

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	functionName := terraform.Output(t, terraformOptions, "lambda_function_name")
	assert.NotEmpty(t, functionName, "Lambda function name should not be empty")

	functionURL := terraform.Output(t, terraformOptions, "lambda_function_url")
	assert.NotEmpty(t, functionURL, "Lambda function URL should not be empty")

	assert.Equal(t, "image-upload-function", functionName, "Function name should match the expected value")

	sess, err := session.NewSession(&aws.Config{
		Region:      aws.String(localstackRegion),
		Endpoint:    aws.String(localstackURL),
		Credentials: credentials.NewStaticCredentials("test", "test", ""),
	})
	require.NoError(t, err, "Failed to create AWS session")

	lambdaClient := lambda.New(sess)

	config, err := lambdaClient.GetFunction(&lambda.GetFunctionInput{
		FunctionName: aws.String(functionName),
	})
	require.NoError(t, err, "Failed to get Lambda function configuration")

	assert.NotNil(t, config.Configuration, "Lambda function configuration should not be nil")
	assert.Equal(t, functionName, aws.StringValue(config.Configuration.FunctionName), "Function name mismatch")

	// ❌ This was invalid: config.configuration.vpcConfig.Enabled
	// ✅ Corrected — VPC config might be nil
	if config.Configuration.VpcConfig != nil {
		// LocalStack may not return Enabled flag; skip this or check for empty strings
		assert.NotEmpty(t, config.Configuration.VpcConfig.SubnetIds, "VPC Subnet IDs should not be empty")
	}

	envVars := config.Configuration.Environment.Variables
	require.NotNil(t, envVars, "Environment variables should not be nil")

	assert.Equal(t, "us-east-1", aws.StringValue(envVars["SQS_REGION"]), "Incorrect SQS_REGION")
	assert.Equal(t, "demo-bucket", aws.StringValue(envVars["BUCKET_NAME"]), "Incorrect BUCKET_NAME")
	assert.Equal(t, "my-app-queue", aws.StringValue(envVars["QUEUE_NAME"]), "Incorrect QUEUE_NAME")
}
