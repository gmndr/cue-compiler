// cue/base/connexions.cue
package base

connexions: {
	postgres: {
		host:     *"postgres.postgres.svc.cluster.local" | string
		port:     *5432 | int
		database: *"trino_metadata" | string
	}
	s3: {
		endpoint:        *"https://s3.internal" | string
		region:          *"eu-west-1" | string
		bucket:          *"trino-data" | string
		pathStyleAccess: *true | bool
	}
}
