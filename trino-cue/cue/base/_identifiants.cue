// cue/base/_identifiants.cue
package base

// ========== IDENTIFIANTS ==========
identifiants: {
	postgres: {
		user:     *"trino" | string
		password: *"" | string
	}

	s3: {
		accessKey: *"" | string
		secretKey: *"" | string
	}

	// Authentification Trino (pour l'UI ou les clients)
	trino: {
		adminUser:     *"admin" | string
		adminPassword: *"" | string
	}
}
