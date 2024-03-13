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

func TestImageProcessorLambdaWithTerragrunt_Localstack(t *testing.T) {
	t.Parallel()

	// helper to DRY
	createTerraformOptions := func(dir string) *terraform.Options {
		return &terraform.Options{
			TerraformDir:    dir,
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
				Init:    []string{"--terragrunt-include-dir", dir},
				Apply:   []string{"--terragrunt-include-dir", dir, "-auto-approve"},
				Destroy: []string{"--terragrunt-include-dir", dir, "-auto-approve"},
			},
		}
	}

	vpcOptions := createTerraformOptions("../infrastructure/localstack/dev/vpc")
	sqsOptions := createTerraformOptions("../infrastructure/localstack/dev/sqs")
	lambdaOptions := createTerraformOptions("../infrastructure/localstack/dev/image-processor-lambda")

	// Ensure cleanup in correct order
	defer terraform.Destroy(t, lambdaOptions)
	defer terraform.Destroy(t, sqsOptions)
	defer terraform.Destroy(t, vpcOptions)

	// Apply resources
	terraform.InitAndApply(t, vpcOptions)
	terraform.InitAndApply(t, sqsOptions)
	terraform.InitAndApply(t, lambdaOptions)

	// Validate outputs
	functionName := terraform.Output(t, lambdaOptions, "lambda_function_name")
	assert.NotEmpty(t, functionName, "Lambda function name should not be empty")

	t.Logf("Lambda Function Name: %s", functionName)

	assert.Equal(t, "image-process-function", functionName, "Function name should match expected")

	// Create AWS session for LocalStack
	sess, err := session.NewSession(&aws.Config{
		Region:      aws.String(localstackRegion),
		Endpoint:    aws.String(localstackURL),
		Credentials: credentials.NewStaticCredentials("test", "test", ""),
	})
	require.NoError(t, err, "Failed to create AWS session")

	lambdaClient := lambda.New(sess)

	// Fetch Lambda configuration
	config, err := lambdaClient.GetFunction(&lambda.GetFunctionInput{
		FunctionName: aws.String(functionName),
	})
	require.NoError(t, err, "Failed to get Lambda function configuration")
	require.NotNil(t, config.Configuration, "Lambda function configuration should not be nil")

	assert.Equal(t, functionName, aws.StringValue(config.Configuration.FunctionName), "Lambda function name should match")

	// Check environment variables
	envVars := config.Configuration.Environment.Variables
	require.NotNil(t, envVars, "Environment variables should not be nil")
	t.Logf("Environment Variables: %v", envVars)

	// check iam role
	roleName := aws.StringValue(config.Configuration.Role)
	t.Logf("IAM Role Name: %s", roleName)
	require.NotEmpty(t, roleName, "IAM Role name should not be empty")

	// Check VPC configuration
	vpc := config.Configuration.VpcConfig
	require.NotNil(t, vpc, "VPC config should not be nil")
	require.NotEmpty(t, vpc.SubnetIds, "Should have at least one subnet ID")
	require.NotEmpty(t, vpc.SecurityGroupIds, "Should have at least one security group ID")
	t.Logf("VPC Subnets: %v", aws.StringValueSlice(vpc.SubnetIds))
	t.Logf("VPC Security Groups: %v", aws.StringValueSlice(vpc.SecurityGroupIds))
	

	// List event source mappings
	mappings, err := lambdaClient.ListEventSourceMappings(&lambda.ListEventSourceMappingsInput{
		FunctionName: aws.String(functionName),
	})
	require.NoError(t, err, "Failed to list event source mappings")
	require.NotEmpty(t, mappings.EventSourceMappings, "Expected at least one event source mapping")

	assert.Equal(t, "Enabled", aws.StringValue(mappings.EventSourceMappings[0].State), "Event source mapping should be enabled")
	t.Logf("Event Source Mapping: %s", aws.StringValue(mappings.EventSourceMappings[0].UUID))
	// Optional: log some details
	t.Logf("Lambda function %q validated successfully", functionName)
	t.Logf("VPC Subnets: %v", aws.StringValueSlice(vpc.SubnetIds))
	t.Logf("VPC Security Groups: %v", aws.StringValueSlice(vpc.SecurityGroupIds))
	t.Logf("Event Source Mappings: %d", len(mappings.EventSourceMappings))
}
