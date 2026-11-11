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

	image: tag: "422"

	server: {
		node: environment: "development"
		config: authenticationType: "PASSWORD"
	}

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
		tpch:  null
		tpcds: null
	}

	auth: passwordAuth: "\(base.identifiants.trino.adminUser):\(base.identifiants.trino.adminPassword)"

	coordinator: {
		deployment: annotations: {
			"prometheus.io/scrape": "true"
			"prometheus.io/port":   "8080"
		}
		jvm: {
			maxHeapSize: "4G"
			gcMethod: g1: heapRegionSize: "16M"
		}
		resources: {
			requests: {cpu: "500m", memory: "4Gi"}
			limits: {cpu: "1", memory: "4Gi"}
		}
		config: query: maxMemoryPerNode: "2GB"
		secretMounts: [
			{name: "postgres-credentials", secretName: "trino-postgres-credentials", path: "/etc/trino/secrets/postgres"},
			{name: "s3-credentials", secretName: "trino-s3-credentials", path: "/etc/trino/secrets/s3"},
		]
	}

	worker: {
		deployment: annotations: {
			"prometheus.io/scrape": "true"
			"prometheus.io/port":   "8080"
		}
		jvm: {
			maxHeapSize: "4G"
			gcMethod: g1: heapRegionSize: "16M"
		}
		resources: {
			requests: {cpu: "1", memory: "4Gi"}
			limits: {cpu: "2", memory: "4Gi"}
		}
		config: query: maxMemoryPerNode: "2GB"
		gracefulShutdown: enabled: true
		tolerations: [{key: "dedicated", operator: "Equal", value: "trino", effect: "NoSchedule"}]
		affinity: podAntiAffinity: preferredDuringSchedulingIgnoredDuringExecution: [{
			weight: 100
			podAffinityTerm: {
				labelSelector: matchExpressions: [{key: "app.kubernetes.io/component", operator: "In", values: ["trino-worker"]}]
				topologyKey: "kubernetes.io/hostname"
			}
		}]
		secretMounts: [
			{name: "postgres-credentials", secretName: "trino-postgres-credentials", path: "/etc/trino/secrets/postgres"},
			{name: "s3-credentials", secretName: "trino-s3-credentials", path: "/etc/trino/secrets/s3"},
		]
	}

	service: annotations: "service.beta.kubernetes.io/aws-load-balancer-type": "nlb"

	env: [
		{name: "TRINO_ENV", value: "development"},
		{name: "JAVA_TOOL_OPTIONS", value: "-Djavax.net.ssl.trustStore=/etc/trino/secrets/truststore.jks"},
	]

	additionalConfigProperties: [
		"query.client.timeout=5m",
		"query.max-run-time=1h",
		"query.max-queued-time=30m",
	]

	additionalExchangeManagerProperties: [
		"exchange.s3.region=\(connexions.s3.region)",
		"exchange.s3.endpoint=\(connexions.s3.endpoint)",
		"exchange.s3.aws-access-key=\(base.identifiants.s3.accessKey)",
		"exchange.s3.aws-secret-key=\(base.identifiants.s3.secretKey)",
	]
}
