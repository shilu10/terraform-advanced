package test 

import (
	"testing"
	"time"
	"io/ioutil"
	"net/http"
	"fmt"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/credentials"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/iam"
	"github.com/aws/aws-sdk-go/service/lambda"
	"github.com/aws/aws-sdk-go/service/s3"
	"github.com/aws/aws-sdk-go/service/ec2"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"	
	"github.com/stretchr/testify/require"
	"github.com/aws/aws-sdk-go/service/rds"
)


const (
	localstackRegion = "us-east-1"
	localstackURL    = "http://localhost:4566"
)

func TestE2ETerragrunt_Localstack(t *testing.T) {
	t.Parallel()
	
	// s3 Terraform options
	s3TerraformOptions := getTerrafomrOptions("../infrastructure/localstack/dev/s3")
	
	// vpc terraform options
	vpcTerraformOptions := getTerrafomrOptions("../infrastructure/localstack/dev/vpc")

	// rds terraform options
	rdsTerraformOptions := getTerrafomrOptions("../infrastructure/localstack/dev/rds")

	// sqs terraform options
	sqsTerraformOptions := getTerrafomrOptions("../infrastructure/localstack/dev/sqs")

	// image-uploader-lambda terraform options
	imageUploaderLambdaOptions := getTerrafomrOptions("../infrastructure/localstack/dev/image-uploader-lambda")	

	// image-processer-lambda terraform options
	imageProcesserLambdaOptions := getTerrafomrOptions("../infrastructure/localstack/dev/image-processor-lambda")

	// image-uploader-lambda-iam-role terraform options
	imageUploaderLambdaIAMRoleOptions := getTerrafomrOptions("../infrastructure/localstack/dev/image-uploader-lambda-iam-role")

	// image-processer-lambda-iam-role terraform options
	imageProcesserLambdaIAMRoleOptions := getTerrafomrOptions("../infrastructure/localstack/dev/image-processor-lambda-iam-role")

	// appply all resources in the correct order
	terraform.InitAndApply(t, vpcTerraformOptions)
	terraform.InitAndApply(t, s3TerraformOptions)
	terraform.InitAndApply(t, rdsTerraformOptions)
	terraform.InitAndApply(t, sqsTerraformOptions)
	terraform.InitAndApply(t, imageUploaderLambdaIAMRoleOptions)
	terraform.InitAndApply(t, imageProcesserLambdaIAMRoleOptions)
	terraform.InitAndApply(t, imageUploaderLambdaOptions)
	terraform.InitAndApply(t, imageProcesserLambdaOptions)

	// Cleanup: destroy all resources in reverse order
	defer func() {
		terraform.Destroy(t, imageProcesserLambdaOptions)
		terraform.Destroy(t, imageUploaderLambdaOptions)
		terraform.Destroy(t, imageProcesserLambdaIAMRoleOptions)
		terraform.Destroy(t, imageUploaderLambdaIAMRoleOptions)
		terraform.Destroy(t, sqsTerraformOptions)	
		terraform.Destroy(t, rdsTerraformOptions)
		terraform.Destroy(t, s3TerraformOptions)
		terraform.Destroy(t, vpcTerraformOptions)
	}()
	
	// vpc outputs 
	vpcID := terraform.Output(t, vpcTerraformOptions, "vpc_id")
	publicSubnets := terraform.OutputList(t, vpcTerraformOptions, "public_subnet_ids")
	privateSubnets := terraform.OutputList(t, vpcTerraformOptions, "private_subnet_ids")
	sgIDs := terraform.OutputMap(t, vpcTerraformOptions, "security_group_ids")

	// s3 output
	bucketID := terraform.Output(t, s3TerraformOptions, "bucket_id")

	// sqs output
	queueURL := terraform.Output(t, sqsTerraformOptions, "queue_url")
	queueName := terraform.Output(t, sqsTerraformOptions, "queue_name")

	// rds output
	dbInstanceID := terraform.Output(t, rdsTerraformOptions, "rds_identifier")

	// lambdas output 
	imageProcessFunctionName := terraform.Output(t, imageProcesserLambdaOptions, "lambda_function_name")
	imageUploadFunctionName := terraform.Output(t, imageUploaderLambdaOptions, "lambda_function_name")
	
	// function url 
	imageUploaderLambdaFunctionURL := terraform.Output(t, imageUploaderLambdaOptions, "lambda_function_url")


	t.Logf("VPC ID: %s", vpcID)
	t.Logf("Public Subnets: %v", publicSubnets)
	t.Logf("Private Subnets: %v", privateSubnets)
	t.Logf("S3 Bucket Name: %s", s3BucketName)
	t.Logf("Lambda Function Name: %s", lambdaFunctionName)
	t.Logf("RDS Instance ID: %s", rdsInstanceID)
	t.Logf("SQS Queue URL: %s", queueURL)
	t.Logf("SQS Queue Name: %s", queueName)
	t.Logf("Image Process Lambda Function Name: %s", imageProcessFunctionName)
	t.Logf("Image Upload Lambda Function Name: %s", imageUploadFunctionName)
	t.Logf("Image Uploader Lambda Function URL: %s", imageUploaderLambdaFunctionURL)

	// assertions 
	assert.NotEmpty(t, bucketID)
	assert.NotEmpty(t, dbInstanceID)
	assert.NotEmpty(t, queueURL)
	assert.NotEmpty(t, queueName)
	assert.NotEmpty(t, vpcID)
	assert.NotEmpty(t, publicSubnets)
	assert.NotEmpty(t, privateSubnets)
	assert.NotEmpty(t, sgIDs)
	assert.NotEmpty(t, imageProcessFunctionName)
	assert.NotEmpty(t, imageUploadFunctionName)
	assert.NotEmpty(t, imageUploaderLambdaFunctionURL)

	// upload image and metadata to lambda function url 
	url := imageUploaderLambdaFunctionURL

	// the payload
	payload := map[string]interface{}{
		"image_base64": "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR4nGNgYAAAAAMAASsJTYQAAAAASUVORK5CYII=",
		"metadata": map[string]string{
			"user": "shilash",
		},
	}

	// marshal payload to JSON
	jsonData, err := json.Marshal(payload)
	if err != nil {
		panic(err)
	}

	// build request
	req, err := http.NewRequest("POST", url, bytes.NewBuffer(jsonData))
	if err != nil {
		panic(err)
	}

	// set header
	req.Header.Set("Content-Type", "application/json")

	// execute request
	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		panic(err)
	}
	defer resp.Body.Close()

	// read response
	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		panic(err)
	}

	fmt.Println("Response Status:", resp.Status)
	fmt.Println("Response Body:", string(body))

	// check s3 bucket not empty 
	s3Session, err := session.NewSession(&aws.Config{
		Region:           aws.String(localstackRegion),
		Endpoint:         aws.String(localstackURL),
		Credentials:      credentials.NewStaticCredentials("test", "test", ""),
	})
	require.NoError(t, err, "Failed to create AWS session for S3")
	s3Client := s3.New(s3Session)

	// List objects in the bucket
	listObjectsInput := &s3.ListObjectsV2Input{
		Bucket: aws.String(bucketID),
	}
	listObjectsOutput, err := s3Client.ListObjectsV2(listObjectsInput)
	require.NoError(t, err, "Failed to list objects in S3 bucket")
	if len(listObjectsOutput.Contents) == 0 {
		t.Fatalf("S3 bucket %s is empty", bucketID)
		require.FailNow(t, "S3 bucket is empty")
	} else {
		t.Logf("S3 bucket %s contains %d objects", bucketID, len(listObjectsOutput.Contents))
	}

	// check rds instance is available
	rdsSession, err := session.NewSession(&aws.Config{
		Region:      aws.String(localstackRegion),
		Endpoint:    aws.String(localstackURL),
		Credentials: credentials.NewStaticCredentials("test", "test", ""),
	})
	require.NoError(t, err, "Failed to create AWS session for RDS")
	
	rdsClient := rds.New(rdsSession)
	describeDBInstancesInput := &rds.DescribeDBInstancesInput{
		DBInstanceIdentifier: aws.String(dbInstanceID),
	}
	describeDBInstancesOutput, err := rdsClient.DescribeDBInstances(describeDBInstancesInput)
	require.NoError(t, err, "Failed to describe RDS instances")

	if len(describeDBInstancesOutput.DBInstances) == 0 {
		t.Fatalf("RDS instance %s not found", dbInstanceID)
		require.FailNow(t, "RDS instance not found")
	} else {
		t.Logf("RDS instance %s is available", dbInstanceID)
	}

}


func getTerrafomrOptions(dir string) *terraform.Options {
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