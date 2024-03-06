func assertProcessedImageExists(t *testing.T, bucket string, key string) {
	sess := session.Must(session.NewSession())
	s3Client := s3.New(sess)

	_, err := s3Client.HeadObject(&s3.HeadObjectInput{
		Bucket: aws.String(bucket),
		Key:    aws.String(key),
	})

	require.NoError(t, err, "Processed image should exist in S3")
}
