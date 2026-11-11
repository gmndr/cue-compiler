// cue/overrides/dev/trino.cue
package dev

import (
	"trino.cue/base"
)

connexions: base.connexions & {
	postgres: host: "postgres-dev.postgres.svc.cluster.local"
	s3: {
		endpoint: "https://s3-dev.internal"
		bucket:   "trino-data-dev"
	}
}

trino: base.trino & {
	fullnameOverride: "trino-dev"
	server: node: environment: "development"

	catalogs: {
		postgresql: """
			connector.name=postgresql
			connection-url=jdbc:postgresql://\(connexions.postgres.host):\(connexions.postgres.port)/\(connexions.postgres.database)
			connection-user=\(base.identifiants.postgres.user)
			connection-password=\(base.identifiants.postgres.password)
			"""
		hive: """
			connector.name=hive
			hive.metastore.uri=thrift://hive-metastore-dev.hive.svc.cluster.local:9083
			hive.s3.endpoint=\(connexions.s3.endpoint)
			hive.s3.path-style-access=\(connexions.s3.pathStyleAccess)
			hive.s3.aws-access-key=\(base.identifiants.s3.accessKey)
			hive.s3.aws-secret-key=\(base.identifiants.s3.secretKey)
			"""
	}
}
