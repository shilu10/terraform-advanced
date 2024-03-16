package test

import (
	"testing"
	"time"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/credentials"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/s3"
	"github.com/stretchr/testify/require"
)

const (
	localstackURL = "http://localhost:4566"
	localstackRegion = "us-east-1"
)

func TestBackend(t *testing.T){
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir:  "../infrastructure/bootstrap-localstack/dev/backend",
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

	backendS3Output := terraform.Output(t, terraformOptions, "s3_bucket")
	backendDynamodbOutput := terraform.Output(t, terraformOptions, "dynamodb_table")
	t.Logf("backendS3Output : %s", backendS3Output)
	t.Logf("backendDynamodbOutput : %s", backendDynamodbOutput)
	assert.NotEmpty(t, backendS3Output, "Backend should not be empty")
	assert.NotEmpty(t, backendDynamodbOutput, "Backend should not be empty")

	bucketID := terraform.Output(t, terraformOptions, "bucket_id")
	t.Logf("bucketID: %s", bucketID)
	assert.NotEmpty(t, bucketID, "Bucket ID should not be empty")

	// Create AWS session
	sess, err := session.NewSession(&aws.Config{
		Region:           aws.String(localstackRegion),
		Endpoint:         aws.String(localstackURL),
		Credentials:      credentials.NewStaticCredentials("test", "test", ""),
		S3ForcePathStyle: aws.Bool(true),
	})
	require.NoError(t, err, "Failed to create AWS session")

	s3Client := s3.New(sess)

	// Check public access block configuration
	output, err := s3Client.GetPublicAccessBlock(&s3.GetPublicAccessBlockInput{
		Bucket: aws.String(bucketID),
	})

	require.NoError(t, err, "Failed to get public access block configuration")
	require.NotNil(t, output.PublicAccessBlockConfiguration)

	assert.True(t, aws.BoolValue(output.PublicAccessBlockConfiguration.BlockPublicAcls), "BlockPublicAcls should be true")
	assert.True(t, aws.BoolValue(output.PublicAccessBlockConfiguration.BlockPublicPolicy), "BlockPublicPolicy should be true")
	assert.True(t, aws.BoolValue(output.PublicAccessBlockConfiguration.IgnorePublicAcls), "IgnorePublicAcls should be true")
	assert.True(t, aws.BoolValue(output.PublicAccessBlockConfiguration.RestrictPublicBuckets), "RestrictPublicBuckets should be true")

	// Check bucket versioning
	versioningOutput, err := s3Client.GetBucketVersioning(&s3.GetBucketVersioningInput{
		Bucket: aws.String(bucketID),
	})

	require.NoError(t, err, "Failed to get bucket versioning configuration")
	t.Logf("Bucket versioning status: %s", aws.StringValue(versioningOutput.Status))
	assert.NotNil(t, versioningOutput.Status, "Bucket versioning status should not be nil")
	
	assert.Equal(t, "Enabled", aws.StringValue(versioningOutput.Status), "Bucket versioning should be enabled")
	// encryption configuration
	encryptionOutput, err := s3Client.GetBucketEncryption(&s3.GetBucketEncryptionInput{
		Bucket: aws.String(bucketID),
	})

	require.NoError(t, err, "Failed to get bucket encryption configuration")
	t.Logf("Bucket encryption configuration: %v", encryptionOutput.ServerSideEncryptionConfiguration)
	assert.NotNil(t, encryptionOutput.ServerSideEncryptionConfiguration, "Bucket encryption configuration should not be nil")
	assert.Len(t, encryptionOutput.ServerSideEncryptionConfiguration.Rules, 1, "There should be one encryption rule")
	//assert.Equal(t, s3.ServerSideEncryptionAes256, encryptionOutput.ServerSideEncryptionConfiguration.Rules[0].ApplyServerSideEncryptionByDefault.SSEAlgorithm, "SSE algorithm should be AES256")
	assert.Equal(t, "AES256", aws.StringValue(encryptionOutput.ServerSideEncryptionConfiguration.Rules[0].ApplyServerSideEncryptionByDefault.SSEAlgorithm), "SSE algorithm should be AES256")
}