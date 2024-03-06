func TestInvalidMetadataUpload(t *testing.T) {
	badMetadata := map[string]string{"user_id": "", "label": ""}
	resp := uploadTestImage(t, uploadURL, validImage, badMetadata)
	assert.Equal(t, 400, resp.StatusCode, "Should return 400 on invalid metadata")
}
