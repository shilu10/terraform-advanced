func TestUploaderFunctionURLReachable(t *testing.T) {
	uploadURL := terraform.Output(t, terraformOptions, "image_uploader_url")

	resp, err := http.Get(uploadURL)
	require.NoError(t, err)
	assert.True(t, resp.StatusCode >= 400, "Expected 4xx on GET to uploader")
}
