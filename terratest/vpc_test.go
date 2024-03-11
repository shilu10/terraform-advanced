package test

import (
	"testing"
	"time"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/credentials"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/ec2"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)


func TestVpcWithTerragrunt_Localstack(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir:    "../infrastructure/envs/dev/vpc",
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
			"AWS_REGION":            localstackRegion,
			"AWS_ENDPOINT_URL":      localstackURL,
		},

		ExtraArgs: terraform.ExtraArgs{
        Init:    []string{"--terragrunt-include-dir", "../infrastructure/envs/dev/vpc"},
        Apply:   []string{"--terragrunt-include-dir", "../infrastructure/envs/dev/vpc", "-auto-approve"},
        Destroy: []string{"--terragrunt-include-dir", "../infrastructure/envs/dev/vpc", "-auto-approve"},
    },
	}

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	vpcID := terraform.Output(t, terraformOptions, "vpc_id")
	publicSubnets := terraform.OutputList(t, terraformOptions, "public_subnet_ids")
	privateSubnets := terraform.OutputList(t, terraformOptions, "private_subnet_ids")
	sgIDs := terraform.OutputMap(t, terraformOptions, "security_group_ids")

	assert.NotEmpty(t, vpcID)
	assert.Equal(t, 2, len(publicSubnets))
	assert.Equal(t, 2, len(privateSubnets))

	rdsSgID := sgIDs["rds"]
	lambdaSgID := sgIDs["lambda"]

	rdsDesc := getLocalstackSecurityGroupDescription(t, rdsSgID)
	assert.Contains(t, rdsDesc, "Allow MySQL")

	lambdaDesc := getLocalstackSecurityGroupDescription(t, lambdaSgID)
	assert.Contains(t, lambdaDesc, "Allow All")
}

func getLocalstackSecurityGroupDescription(t *testing.T, sgID string) string {
	sess, err := session.NewSession(&aws.Config{
		Region:      aws.String(localstackRegion),
		Endpoint:    aws.String(localstackURL),
		Credentials: credentials.NewStaticCredentials("test", "test", ""),
	})
	require.NoError(t, err)

	ec2Svc := ec2.New(sess)
	input := &ec2.DescribeSecurityGroupsInput{
		GroupIds: []*string{aws.String(sgID)},
	}

	result, err := ec2Svc.DescribeSecurityGroups(input)
	require.NoError(t, err)
	require.NotEmpty(t, result.SecurityGroups)

	return *result.SecurityGroups[0].Description
}
