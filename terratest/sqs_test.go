package test

import (
	"testing"
	"time"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/credentials"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/sqs"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

const (
	localstackRegion = "us-east-1"
	localstackURL    = "http://localhost:4566"
)

func TestSQSWithTerragrunt_Localstack(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
	TerraformDir:    "../infrastructure/envs/dev/sqs",
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
        Init:    []string{"--terragrunt-include-dir", "../infrastructure/envs/dev/sqs"},
        Apply:   []string{"--terragrunt-include-dir", "../infrastructure/envs/dev/sqs", "-auto-approve"},
        Destroy: []string{"--terragrunt-include-dir", "../infrastructure/envs/dev/sqs", "-auto-approve"},
    },
}

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	queueURL := terraform.Output(t, terraformOptions, "queue_url")
	queueName := terraform.Output(t, terraformOptions, "queue_name")

	assert.NotEmpty(t, queueURL)
	assert.NotEmpty(t, queueName)

	t.Logf("Queue URL: %s", queueURL)
	t.Logf("Queue Name: %s", queueName)

	assert.Contains(t, queueName, ".fifo", "Queue name should end with .fifo")

	sess, err := session.NewSession(&aws.Config{
		Region:      aws.String(localstackRegion),
		Endpoint:    aws.String(localstackURL),
		Credentials: credentials.NewStaticCredentials("test", "test", ""),
	})
	require.NoError(t, err)

	sqsClient := sqs.New(sess)

	// Validate queue exists
	_, err = sqsClient.GetQueueAttributes(&sqs.GetQueueAttributesInput{
		QueueUrl:       aws.String(queueURL),
		AttributeNames: aws.StringSlice([]string{"All"}),
	})
	require.NoError(t, err)

	// Validate queue attributes
	attributes, err := sqsClient.GetQueueAttributes(&sqs.GetQueueAttributesInput{
		QueueUrl: aws.String(queueURL),
		AttributeNames: aws.StringSlice([]string{
			"VisibilityTimeout",
			"MessageRetentionPeriod",
			"DelaySeconds",
			"ApproximateNumberOfMessages",
			"MaximumMessageSize",
			"ReceiveMessageWaitTimeSeconds",
			"KmsMasterKeyId",
			"FifoQueue",
			"ContentBasedDeduplication",
		}),
	})
	t.Log("Queue attributes fetched: ", attributes.Attributes)
	require.NoError(t, err)

	assert.Equal(t, "45", *attributes.Attributes["VisibilityTimeout"], "VisibilityTimeout should be 45 seconds")
	assert.Equal(t, "0", *attributes.Attributes["ApproximateNumberOfMessages"], "Queue should be empty initially")
	assert.Equal(t, "131072", *attributes.Attributes["MaximumMessageSize"], "MaximumMessageSize should be 256 KB")
	assert.Equal(t, "0", *attributes.Attributes["DelaySeconds"], "DelaySeconds should be 0")
	assert.Equal(t, "10", *attributes.Attributes["ReceiveMessageWaitTimeSeconds"], "ReceiveMessageWaitTimeSeconds should be 10 seconds")
	assert.Equal(t, "alias/aws/sqs", *attributes.Attributes["KmsMasterKeyId"], "KmsMasterKeyId should be 'alias/aws/sqs'")
	assert.Equal(t, "86400", *attributes.Attributes["MessageRetentionPeriod"], "MessageRetentionPeriod should be 4 days")
	assert.Equal(t, "true", *attributes.Attributes["FifoQueue"], "FifoQueue should be true")
	assert.Equal(t, "true", *attributes.Attributes["ContentBasedDeduplication"], "ContentBasedDeduplication should be true")
}
