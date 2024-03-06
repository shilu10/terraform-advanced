func TestImageUploadPipeline(t *testing.T) {
	t.Parallel()

	// 1. Deploy infrastructure using Terragrunt
	terraformOptions := &terraform.Options{
		TerraformDir: "../infrastructure/envs/dev",
	}
	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// 2. Extract outputs (Function URL, S3 bucket name, DB endpoint)
	uploadURL := terraform.Output(t, terraformOptions, "image_uploader_url")
	outputBucket := terraform.Output(t, terraformOptions, "processed_images_bucket")
	rdsEndpoint := terraform.Output(t, terraformOptions, "rds_writer_endpoint")
	dbUser := terraform.Output(t, terraformOptions, "db_user")
	dbPass := terraform.Output(t, terraformOptions, "db_pass")

	// 3. Upload image and metadata via HTTP POST
	imageData := loadTestImage()
	metadata := map[string]string{"user_id": "123", "label": "cat"}

	resp := uploadTestImage(t, uploadURL, imageData, metadata)
	require.Equal(t, 200, resp.StatusCode)

	// 4. Wait for processing (e.g., 20–30 seconds)
	time.Sleep(30 * time.Second)

	// 5. Check S3: processed image is stored
	assertProcessedImageExists(t, outputBucket, "123_cat.jpg")

	// 6. Check RDS: metadata exists
	assertMetadataStored(t, rdsEndpoint, dbUser, dbPass, "123", "cat")
}
