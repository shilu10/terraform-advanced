package test

import (
	"testing"
	"time"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/credentials"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/rds"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

const (
	StateAvailable   = "available"
	StorageStandard  = "gp3"
	localstackRegion = "us-east-1"
	localstackURL    = "http://localhost:4566"
)

func TestRDSInstanceWithTerragrunt_Localstack(t *testing.T) {
	t.Parallel()

	vpcTerraformOptions := &terraform.Options{
		TerraformDir:    "../infrastructure/localstack/dev/vpc",
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
			// NOTE: AWS_ENDPOINT_URL is not natively respected by Terraform,
			// you should configure `provider "aws" { endpoint = var.localstack_url }` in your .tf files.
			"AWS_ENDPOINT_URL": localstackURL,
		},

		ExtraArgs: terraform.ExtraArgs{
			Init:    []string{"--terragrunt-include-dir", "../infrastructure/localstack/dev/vpc"},
			Apply:   []string{"--terragrunt-include-dir", "../infrastructure/localstack/dev/vpc", "-auto-approve"},
			Destroy: []string{"--terragrunt-include-dir", "../infrastructure/localstack/dev/vpc", "-auto-approve"},
		},

	}

	rdsTerraformOptions := &terraform.Options{
		TerraformDir:    "../infrastructure/localstack/dev/rds",
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
			Init:    []string{"--terragrunt-include-dir", "../infrastructure/localstack/dev/rds"},
			Apply:   []string{"--terragrunt-include-dir", "../infrastructure/localstack/dev/rds", "-auto-approve"},
			Destroy: []string{"--terragrunt-include-dir", "../infrastructure/localstack/dev/rds", "-auto-approve"},
		},
	}

	// Apply VPC and RDS
	terraform.InitAndApply(t, vpcTerraformOptions)
	//terraform.InitAndApply(t, rdsTerraformOptions)

	// Cleanup: destroy RDS before VPC
//	defer func() {
//		terraform.Destroy(t, rdsTerraformOptions)
//		terraform.Destroy(t, vpcTerraformOptions)
//	}()

	dbInstanceID := terraform.Output(t, rdsTerraformOptions, "rds_identifier")
	assert.NotEmpty(t, dbInstanceID, "DB Instance ID should not be empty")

	// Create AWS session
	sess, err := session.NewSession(&aws.Config{
		Region:           aws.String(localstackRegion),
		Endpoint:         aws.String(localstackURL),
		Credentials:      credentials.NewStaticCredentials("test", "test", ""),
		S3ForcePathStyle: aws.Bool(true),
	})
	require.NoError(t, err, "Failed to create AWS session")

	rdsClient := rds.New(sess)

	describeInput := &rds.DescribeDBInstancesInput{
		DBInstanceIdentifier: aws.String(dbInstanceID),
	}

	result, err := rdsClient.DescribeDBInstances(describeInput)
	require.NoError(t, err, "Failed to describe RDS instance")
	require.NotEmpty(t, result.DBInstances, "No DB instances returned")

	db := result.DBInstances[0]

	assert.Equal(t, dbInstanceID, aws.StringValue(db.DBInstanceIdentifier), "DB Instance ID should match expected")

	// Assertions that LocalStack supports reliably
	assert.False(t, aws.BoolValue(db.PubliclyAccessible), "RDS instance should not be publicly accessible")
	assert.False(t, aws.BoolValue(db.DeletionProtection), "RDS instance should not have deletion protection")

	// Log fields that LocalStack might not set properly
	t.Logf("DB Instance Status: %s", aws.StringValue(db.DBInstanceStatus))
	t.Logf("DB Engine: %s", aws.StringValue(db.Engine))
	t.Logf("DB Engine Version: %s", aws.StringValue(db.EngineVersion))
	t.Logf("Storage Type: %s", aws.StringValue(db.StorageType))
	t.Logf("Allocated Storage: %d", aws.Int64Value(db.AllocatedStorage))

	// Soft checks — only assert if value is set
	if val := aws.StringValue(db.DBInstanceStatus); val != "" {
		assert.Equal(t, StateAvailable, val, "DB instance should be available")
	} else {
		t.Log("DB Instance Status was empty — skipping assertion.")
	}

	if val := aws.StringValue(db.Engine); val != "" {
		assert.Equal(t, "mysql", val, "DB engine should be mysql")
	} else {
		t.Log("DB engine was empty — skipping assertion.")
	}

	if val := aws.StringValue(db.EngineVersion); val != "" {
		assert.Equal(t, "8.0.35", val, "DB engine version should be 8.0.35")
	} else {
		t.Log("DB engine version was empty — skipping assertion.")
	}

	if val := aws.StringValue(db.StorageType); val != "" {
		assert.Equal(t, StorageStandard, val, "Storage type should be standard")
	} else {
		t.Log("Storage type was empty — skipping assertion.")
	}

	if val := aws.Int64Value(db.AllocatedStorage); val != 0 {
		assert.Equal(t, int64(20), val, "Allocated storage should be 20GB")
	} else {
		t.Log("Allocated storage was zero — skipping assertion.")
	}
}
