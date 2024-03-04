func TestSQSQueue(t *testing.T) {
  terraformOptions := &terraform.Options{
    TerraformDir: "../infrastructure/envs/dev/sqs",
  }

  defer terraform.Destroy(t, terraformOptions)
  terraform.InitAndApply(t, terraformOptions)

  queueURL := terraform.Output(t, terraformOptions, "sqs_queue_url")
  assert.Contains(t, queueURL, "amazonaws.com", "SQS URL should contain AWS domain")
}
