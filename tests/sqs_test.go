func TestSQSMessageSent(t *testing.T) {
  // Upload test image
  uploadTestImage(...)

  // Use AWS SDK to poll the SQS queue
  sess := session.Must(session.NewSession())
  sqsClient := sqs.New(sess)

  queueURL := terraform.Output(t, terraformOptions, "upload_metadata_queue_url")

  output, err := sqsClient.ReceiveMessage(&sqs.ReceiveMessageInput{
    QueueUrl:            aws.String(queueURL),
    MaxNumberOfMessages: aws.Int64(1),
    WaitTimeSeconds:     aws.Int64(10),
  })
  require.NoError(t, err)
  assert.Greater(t, len(output.Messages), 0, "Should receive a message in SQS")
}
