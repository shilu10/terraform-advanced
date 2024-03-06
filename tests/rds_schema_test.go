func TestRDSMetadataTableExists(t *testing.T) {
	db := connectToRDS(...)
	rows, err := db.Query("DESCRIBE processed_metadata")
	require.NoError(t, err)

	var foundUserID, foundLabel bool
	for rows.Next() {
		var field, datatype, nullable, key, def, extra string
		rows.Scan(&field, &datatype, &nullable, &key, &def, &extra)
		if field == "user_id" {
			foundUserID = true
		}
		if field == "label" {
			foundLabel = true
		}
	}
	assert.True(t, foundUserID && foundLabel, "Table should contain user_id and label columns")
}
