// cue/base/_connexions.cue
package base

// ========== CONNEXIONS EXTERNES ==========
// Exemple : Connexion à PostgreSQL (pour le catalogue 'postgresql')
connexions: {
	postgres: {
		host:     *"postgres.postgres.svc.cluster.local" | string
		port:     *5432 | int
		database: *"trino_metadata" | string
		user:     *"trino" | string
		password: *"" | string
		ssl:      *false | bool
	}

	// Connexion à S3 (pour le catalogue 'hive' ou 'iceberg')
	s3: {
		endpoint:        *"" | string
		region:          *"" | string
		accessKey:       *"" | string
		secretKey:       *"" | string
		bucket:          *"" | string
		pathStyleAccess: *true | bool
	}
}
