// cue/overrides/connexions/connexions.cue
package connexions

// ========== CONNEXIONS EXTERNES ==========
// Exemple : Connexion à PostgreSQL (pour le catalogue 'postgresql')
postgres: {
	host:     "postgres-dev.postgres.svc.cluster.local"
	port:     5432
	database: "trino_metadata"
	user:     "trino" // À surcharger via identifiants
	password: ""     // À surcharger via identifiants
	ssl:      false
}

// Connexion à S3 (pour le catalogue 'hive' ou 'iceberg')
s3: {
	endpoint:        "https://s3-dev.internal"
	region:          "eu-west-1"
	accessKey:       "" // À surcharger via identifiants
	secretKey:       "" // À surcharger via identifiants
	bucket:          "trino-data-dev"
	pathStyleAccess: true
}
