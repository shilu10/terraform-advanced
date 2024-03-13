package test

import (
	"testing"
	"time"
	"io/ioutil"
	"net/http"
	"fmt"
	"encoding/json"
	"bytes"
	"database/sql"

	_ "github.com/go-sql-driver/mysql"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/credentials"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/s3"
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

	s3TerraformOptions := getTerrafomrOptions("../infrastructure/localstack/dev/s3")
	vpcTerraformOptions := getTerrafomrOptions("../infrastructure/localstack/dev/vpc")
	rdsTerraformOptions := getTerrafomrOptions("../infrastructure/localstack/dev/rds")
	sqsTerraformOptions := getTerrafomrOptions("../infrastructure/localstack/dev/sqs")
	imageUploaderLambdaOptions := getTerrafomrOptions("../infrastructure/localstack/dev/image-uploader-lambda")
	imageProcesserLambdaOptions := getTerrafomrOptions("../infrastructure/localstack/dev/image-processor-lambda")
	imageUploaderLambdaIAMRoleOptions := getTerrafomrOptions("../infrastructure/localstack/dev/image-uploader-lambda-iam-role")
	imageProcesserLambdaIAMRoleOptions := getTerrafomrOptions("../infrastructure/localstack/dev/image-processor-lambda-iam-role")

	fmt.Println(imageProcesserLambdaOptions, imageUploaderLambdaOptions, imageProcesserLambdaIAMRoleOptions)
	fmt.Println(imageUploaderLambdaIAMRoleOptions, sqsTerraformOptions, rdsTerraformOptions, s3TerraformOptions)
	fmt.Println(vpcTerraformOptions)

	vpcID := terraform.Output(t, vpcTerraformOptions, "vpc_id")
	publicSubnets := terraform.OutputList(t, vpcTerraformOptions, "public_subnet_ids")
	privateSubnets := terraform.OutputList(t, vpcTerraformOptions, "private_subnet_ids")
	sgIDs := terraform.OutputMap(t, vpcTerraformOptions, "security_group_ids")

	bucketID := terraform.Output(t, s3TerraformOptions, "bucket_id")

	queueURL := terraform.Output(t, sqsTerraformOptions, "queue_url")
	queueName := terraform.Output(t, sqsTerraformOptions, "queue_name")

	dbInstanceID := terraform.Output(t, rdsTerraformOptions, "rds_identifier")

	imageProcessFunctionName := terraform.Output(t, imageProcesserLambdaOptions, "lambda_function_name")
	imageUploadFunctionName := terraform.Output(t, imageUploaderLambdaOptions, "lambda_function_name")

	imageUploaderLambdaFunctionURL := terraform.Output(t, imageUploaderLambdaOptions, "lambda_function_url")

	t.Logf("VPC ID: %s", vpcID)
	t.Logf("Public Subnets: %v", publicSubnets)
	t.Logf("Private Subnets: %v", privateSubnets)
	t.Logf("S3 Bucket Name: %s", bucketID)
	t.Logf("RDS Instance ID: %s", dbInstanceID)
	t.Logf("SQS Queue URL: %s", queueURL)
	t.Logf("SQS Queue Name: %s", queueName)
	t.Logf("Image Process Lambda Function Name: %s", imageProcessFunctionName)
	t.Logf("Image Upload Lambda Function Name: %s", imageUploadFunctionName)
	t.Logf("Image Uploader Lambda Function URL: %s", imageUploaderLambdaFunctionURL)

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

	url := imageUploaderLambdaFunctionURL

	payload := map[string]interface{}{
		"image_base64": "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR4nGNgYAAAAAMAASsJTYQAAAAASUVORK5CYII=",
		"metadata": map[string]string{
			"user": "shilash",
		},
	}

	jsonData, err := json.Marshal(payload)
	if err != nil {
		panic(err)
	}

	req, err := http.NewRequest("POST", url, bytes.NewBuffer(jsonData))
	if err != nil {
		panic(err)
	}

	req.Header.Set("Content-Type", "application/json")

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		panic(err)
	}
	defer resp.Body.Close()

	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		panic(err)
	}

	fmt.Println("Response Status:", resp.Status)
	fmt.Println("Response Body:", string(body))

	s3Session, err := session.NewSession(&aws.Config{
		Region:      aws.String(localstackRegion),
		Endpoint:    aws.String(localstackURL),
		Credentials: credentials.NewStaticCredentials("test", "test", ""),
	})
	require.NoError(t, err, "Failed to create AWS session for S3")

	s3Client := s3.New(s3Session, &aws.Config{
		S3ForcePathStyle: aws.Bool(true),
	})

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

	// 🔍 Verify uploaded record exists in RDS `uploads` table based on meta.user = 'shilash'
	dbUser := "admin"                 // adjust if needed
	dbPassword := "S3cur3Pa$$w0rd"   // adjust if needed
	dbName := "myappdb"              // adjust if needed

	dbHost := *describeDBInstancesOutput.DBInstances[0].Endpoint.Address
	dbPort := *describeDBInstancesOutput.DBInstances[0].Endpoint.Port

	dsn := fmt.Sprintf("%s:%s@tcp(%s:%d)/%s",
		dbUser, dbPassword, dbHost, dbPort, dbName)

	db, err := sql.Open("mysql", dsn)
	require.NoError(t, err, "Failed to connect to RDS MySQL")
	defer db.Close()

	var count int
	err = db.QueryRow(`SELECT COUNT(*) FROM uploads WHERE JSON_EXTRACT(meta, '$.user') = 'shilash'`).Scan(&count)
	require.NoError(t, err, "Failed to query uploads table")

	assert.Greater(t, count, 0, "No record found in uploads table for meta.user = 'shilash'")
	t.Logf("Found %d record(s) in uploads table for meta.user = 'shilash'", count)
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
