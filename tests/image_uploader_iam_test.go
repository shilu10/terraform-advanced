func TestImageUploaderIAMRole(t *testing.T) {
  terraformOptions := &terraform.Options{
    TerraformDir: "../infrastructure/envs/dev/image-uploader-lambda-iam-role",
  }

  defer terraform.Destroy(t, terraformOptions)
  terraform.InitAndApply(t, terraformOptions)

  roleName := terraform.Output(t, terraformOptions, "lambda_role_name")
  assert.NotEmpty(t, roleName)
}
