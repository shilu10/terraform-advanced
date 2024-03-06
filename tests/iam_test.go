func TestUploaderIAMPolicy(t *testing.T) {
	roleName := terraform.Output(t, terraformOptions, "image_uploader_iam_role_name")

	iamClient := iam.New(session.Must(session.NewSession()))
	policyResp, err := iamClient.GetRolePolicy(&iam.GetRolePolicyInput{
		RoleName:   aws.String(roleName),
		PolicyName: aws.String("UploaderPolicy"),
	})
	require.NoError(t, err)
	assert.Contains(t, *policyResp.PolicyDocument, "s3:PutObject")
	assert.Contains(t, *policyResp.PolicyDocument, "sqs:SendMessage")
}
