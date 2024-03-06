func uploadTestImage(t *testing.T, url string, image []byte, metadata map[string]string) *http.Response {
	body := &bytes.Buffer{}
	writer := multipart.NewWriter(body)

	part, _ := writer.CreateFormFile("file", "test.jpg")
	part.Write(image)

	for k, v := range metadata {
		_ = writer.WriteField(k, v)
	}
	writer.Close()

	req, _ := http.NewRequest("POST", url, body)
	req.Header.Set("Content-Type", writer.FormDataContentType())

	client := &http.Client{}
	resp, err := client.Do(req)
	require.NoError(t, err)

	return resp
}
