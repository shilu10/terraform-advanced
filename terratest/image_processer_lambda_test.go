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


func TestImageProcesserLambdaWithTerragrunt_Localstack(t *testing.T) {
	t.parallel()

	terraformOptions := &terraform.Options{
		TerraformDir:    "../infrastructure/envs/dev/image-processer-lambda",
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
        Init:    []string{"--terragrunt-include-dir", "../infrastructure/envs/dev/image-processer-lambda"},
        Apply:   []string{"--terragrunt-include-dir", "../infrastructure/envs/dev/image-processer-lambda", "-auto-approve"},
        Destroy: []string{"--terragrunt-include-dir", "../infrastructure/envs/dev/image-processer-lambda", "-auto-approve"},
    },
	}

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	functionName := terraform.Output(t, terraformOptions, "lambda_function_name")
	assert.NotEmpty(t, functionName, "Lambda function name should not be empty")

	functionURL := terraform.Output(t, terraformOptions, "lambda_function_url")
	assert.Empty(t, functionURL, "Lambda function URL should be empty for this test")

	assert.Equal(t, "image-process-function", functionName, "Function name should match the expected value")

	sess, err := session.NewSession(&aws.Config{
		Region:      aws.String(localstackRegion),
		Endpoint:    aws.String(localstackURL),
		Credentials: credentials.NewStaticCredentials("test", "test", ""),
	})
	require.NoError(t, err, "Failed to create AWS session")

	lambdaClient := lambda.New(sess)

	// Get the Lambda function configuration
	config, err := lambdaClient.GetFunction(&lambda.GetFunctionInput{
		FunctionName: aws.String(functionName),
	})
	require.NoError(t, err, "Failed to get Lambda function configuration")

	assert.NotNil(t, config.Configuration, "Lambda function configuration should not be nil")
	assert.Equal(t, functionName, *config.Configuration.FunctionName, "Function name should match the output from Terraform")
	assert.Equal(t, "true", *config.configuration.vpcConfig.Enabled, "VPC configuration should be enabled")
	assert.Equal(t, "us-east-1", *config.Configuration.Environment.Variables["SQS_REGION"], "Environment variable should be set correctly")	
	assert.Equal(t, "dev", *config.Configuration.Environment.Variables["ENV"], "Environment variable should be set correctly")
	assert.Equal(t, "demo-bucket", *config.Configuration.Environment.Variables["BUCKET_NAME"], "Environment variable should be set correctly")

	assert.Equal(t, "true", *config.Configuration.eventSourceMappings[0].Enabled, "Event source mapping should be enabled")
}