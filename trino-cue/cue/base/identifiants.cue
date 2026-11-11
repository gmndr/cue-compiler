// cue/base/identifiants.cue
package base

identifiants: {
	postgres: {
		user:     *"trino" | string
		password: *"CHANGE_ME_POSTGRES_PASSWORD" | string
	}
	s3: {
		accessKey: *"CHANGE_ME_S3_ACCESS_KEY" | string
		secretKey: *"CHANGE_ME_S3_SECRET_KEY" | string
	}
	trino: {
		adminUser:     *"admin" | string
		adminPassword: *"CHANGE_ME_ADMIN_PASSWORD" | string
	}
}
