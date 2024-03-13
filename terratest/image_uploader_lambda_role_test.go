package test

import (
	"encoding/json"
	"net/url"
	"testing"
	"time"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/credentials"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/iam"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

const (
	localstackRegion = "us-east-1"
	localstackURL    = "http://localhost:4566"
)

func TestImageUploaderLambdaIamRoleWithTerragrunt_Localstack(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir:    "../infrastructure/localstack/dev/image-uploader-lambda-iam-role",
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

	//defer terraform.Destroy(t, terraformOptions)

	//terraform.InitAndApply(t, terraformOptions)

	roleName := terraform.Output(t, terraformOptions, "role_name")
	t.Logf("IAM Role Name: %s", roleName)
	assert.NotEmpty(t, roleName, "IAM Role Name should not be empty")

	// Create AWS session
	sess, err := session.NewSession(&aws.Config{
		Region:      aws.String(localstackRegion),
		Endpoint:    aws.String(localstackURL),
		Credentials: credentials.NewStaticCredentials("test", "test", ""),
	})
	require.NoError(t, err, "Failed to create AWS session")

	iamClient := iam.New(sess)

	roleOutput, err := iamClient.GetRole(&iam.GetRoleInput{
		RoleName: aws.String(roleName),
	})
	require.NoError(t, err, "Failed to get IAM role")
	t.Logf("Successfully fetched IAM role: %s", roleName)

	// Decode and parse trust policy
	decodedDoc, err := url.QueryUnescape(aws.StringValue(roleOutput.Role.AssumeRolePolicyDocument))
	require.NoError(t, err, "Failed to decode AssumeRolePolicyDocument")

	var trustPolicy struct {
		Statement []struct {
			Principal struct {
				Service interface{} `json:"Service"`
			} `json:"Principal"`
		} `json:"Statement"`
	}

	err = json.Unmarshal([]byte(decodedDoc), &trustPolicy)
	require.NoError(t, err, "Failed to parse trust policy")

	foundLambdaPrincipal := false
	for _, stmt := range trustPolicy.Statement {
		switch p := stmt.Principal.Service.(type) {
		case string:
			if p == "lambda.amazonaws.com" {
				foundLambdaPrincipal = true
			}
		case []interface{}:
			for _, svc := range p {
				if svcStr, ok := svc.(string); ok && svcStr == "lambda.amazonaws.com" {
					foundLambdaPrincipal = true
				}
			}
		}
	}
	assert.True(t, foundLambdaPrincipal, "Trust policy should allow lambda.amazonaws.com")
	t.Logf("Trust policy allows lambda.amazonaws.com")

	// Check attached managed policies
	attached, err := iamClient.ListAttachedRolePolicies(&iam.ListAttachedRolePoliciesInput{
		RoleName: aws.String(roleName),
	})
	require.NoError(t, err, "Failed to list attached managed policies")

	foundManaged := false
	for _, policy := range attached.AttachedPolicies {
		if aws.StringValue(policy.PolicyArn) == "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole" {
			foundManaged = true
			break
		}
	}
	assert.True(t, foundManaged, "Managed policy AWSLambdaBasicExecutionRole should be attached")
	t.Logf("Managed policy AWSLambdaBasicExecutionRole is attached")

	// Check inline policies
	inline, err := iamClient.ListRolePolicies(&iam.ListRolePoliciesInput{
		RoleName: aws.String(roleName),
	})
	require.NoError(t, err, "Failed to list inline policies")

	expectedInline := []string{
		"inline-sqs-access",
		"inline-cloudwatch-logs",
		"inline-s3-access",
	}

	for _, expected := range expectedInline {
		found := false
		for _, policyName := range inline.PolicyNames {
			if aws.StringValue(policyName) == expected {
				found = true
				break
			}
		}
		assert.True(t, found, "Inline policy %s should be present", expected)
	}
	t.Logf("Inline policies are present: %v", expectedInline)
}
