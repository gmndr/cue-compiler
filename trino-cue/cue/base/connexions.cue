// cue/base/connexions.cue
package base

// Connexions externes de base (valeurs par défaut / génériques)
connexions: {
	postgres: {
		host:     *"postgres.postgres.svc.cluster.local" | string
		port:     *5432 | int
		database: *"trino_metadata" | string
	}
	s3: {
		endpoint:        *"" | string
		region:          *"eu-west-1" | string
		bucket:          *"" | string
		pathStyleAccess: *true | bool
	}
}
