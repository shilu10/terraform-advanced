func assertMetadataStored(t *testing.T, endpoint, user, pass, userID, label string) {
	dsn := fmt.Sprintf("%s:%s@tcp(%s:3306)/mydb", user, pass, endpoint)
	db, err := sql.Open("mysql", dsn)
	require.NoError(t, err)
	defer db.Close()

	var count int
	err = db.QueryRow("SELECT COUNT(*) FROM processed_metadata WHERE user_id=? AND label=?", userID, label).Scan(&count)
	require.NoError(t, err)
	assert.True(t, count > 0, "Metadata should be stored in RDS")
}
