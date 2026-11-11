// cue/overrides/rec/trino.cue
package rec

import (
	"trino.cue/base"
)

// ========== CONNEXIONS REC ==========
connexions: {
	postgres: {
		host:     "postgres-rec.postgres.svc.cluster.local"
		port:     5432
		database: "trino_metadata"
		user:     "trino"
		password: ""
		ssl:      false
	}

	s3: {
		endpoint:        "https://s3-rec.internal"
		region:          "eu-west-1"
		accessKey:       ""
		secretKey:       ""
		bucket:          "trino-data-rec"
		pathStyleAccess: true
	}
}

// ========== IDENTIFIANTS REC ==========
identifiants: {
	postgres: {
		user:     "trino"
		password: "CHANGE_ME_POSTGRES_PASSWORD"
	}

	s3: {
		accessKey: "CHANGE_ME_S3_ACCESS_KEY"
		secretKey: "CHANGE_ME_S3_SECRET_KEY"
	}

	trino: {
		adminUser:     "admin"
		adminPassword: "CHANGE_ME_ADMIN_PASSWORD"
	}
}

// ========== FUSION DES VALEURS ==========
trino: base.trino & {
	// ========== GLOBAL ==========
	fullnameOverride: "trino-rec"

	// ========== IMAGE ==========
	image: {
		repository: "trinodb/trino"
		tag:        "422"
		pullPolicy: "IfNotPresent"
	}

	// ========== SERVER ==========
	server: {
		workers: 2
		node: {
			environment: "recette"
		}
		config: {
			https: {
				enabled: false
			}
			authenticationType: "PASSWORD"
		}
	}

	// ========== CATALOGS ==========
	catalogs: {
		postgresql: """
			connector.name=postgresql
			connection-url=jdbc:postgresql://\(connexions.postgres.host):\(connexions.postgres.port)/\(connexions.postgres.database)
			connection-user=\(identifiants.postgres.user)
			connection-password=\(identifiants.postgres.password)
			"""

		hive: """
			connector.name=hive
			hive.metastore.uri=thrift://hive-metastore-rec.hive.svc.cluster.local:9083
			hive.s3.endpoint=\(connexions.s3.endpoint)
			hive.s3.path-style-access=\(connexions.s3.pathStyleAccess)
			hive.s3.aws-access-key=\(identifiants.s3.accessKey)
			hive.s3.aws-secret-key=\(identifiants.s3.secretKey)
			"""

		tpch:  null
		tpcds: null
	}

	// ========== AUTHENTIFICATION ==========
	auth: {
		passwordAuth:       "\(identifiants.trino.adminUser):\(identifiants.trino.adminPassword)"
		passwordAuthSecret: ""
	}

	// ========== COORDINATOR ==========
	coordinator: {
		deployment: {
			annotations: {
				"prometheus.io/scrape": "true"
				"prometheus.io/port":   "8080"
			}
		}

		jvm: {
			maxHeapSize: "4G"
			gcMethod: {
				type: "UseG1GC"
				g1: {
					heapRegionSize: "16M"
				}
			}
		}

		resources: {
			requests: {
				cpu:    "500m"
				memory: "4Gi"
			}
			limits: {
				cpu:    "1"
				memory: "4Gi"
			}
		}

		config: {
			query: {
				maxMemoryPerNode: "2GB"
			}
		}

		secretMounts: [
			{
				name:       "postgres-credentials"
				secretName: "trino-postgres-credentials"
				path:       "/etc/trino/secrets/postgres"
			},
			{
				name:       "s3-credentials"
				secretName: "trino-s3-credentials"
				path:       "/etc/trino/secrets/s3"
			},
		]
	}

	// ========== WORKER ==========
	worker: {
		deployment: {
			annotations: {
				"prometheus.io/scrape": "true"
				"prometheus.io/port":   "8080"
			}
		}

		jvm: {
			maxHeapSize: "4G"
			gcMethod: {
				type: "UseG1GC"
				g1: {
					heapRegionSize: "16M"
				}
			}
		}

		resources: {
			requests: {
				cpu:    "1"
				memory: "4Gi"
			}
			limits: {
				cpu:    "2"
				memory: "4Gi"
			}
		}

		config: {
			query: {
				maxMemoryPerNode: "2GB"
			}
		}

		gracefulShutdown: {
			enabled:            true
			gracePeriodSeconds: 120
		}

		tolerations: [
			{
				key:      "dedicated"
				operator: "Equal"
				value:    "trino"
				effect:   "NoSchedule"
			},
		]

		affinity: {
			podAntiAffinity: {
				preferredDuringSchedulingIgnoredDuringExecution: [
					{
						weight: 100
						podAffinityTerm: {
							labelSelector: {
								matchExpressions: [
									{
										key:      "app.kubernetes.io/component"
										operator: "In"
										values:   ["trino-worker"]
									},
								]
							}
							topologyKey: "kubernetes.io/hostname"
						}
					},
				]
			}
		}

		secretMounts: [
			{
				name:       "postgres-credentials"
				secretName: "trino-postgres-credentials"
				path:       "/etc/trino/secrets/postgres"
			},
			{
				name:       "s3-credentials"
				secretName: "trino-s3-credentials"
				path:       "/etc/trino/secrets/s3"
			},
		]
	}

	// ========== SERVICE ==========
	service: {
		type: "ClusterIP"
		port: 8080
		annotations: {
			"service.beta.kubernetes.io/aws-load-balancer-type": "nlb"
		}
	}

	// ========== ENV ==========
	env: [
		{name: "TRINO_ENV", value: "recette"},
		{name: "JAVA_TOOL_OPTIONS", value: "-Djavax.net.ssl.trustStore=/etc/trino/secrets/truststore.jks"},
	]

	// ========== ADDITIONAL PROPERTIES ==========
	additionalConfigProperties: [
		"query.client.timeout=5m",
		"query.max-run-time=1h",
		"query.max-queued-time=30m",
	]

	additionalExchangeManagerProperties: [
		"exchange.s3.region=\(connexions.s3.region)",
		"exchange.s3.endpoint=\(connexions.s3.endpoint)",
		"exchange.s3.aws-access-key=\(identifiants.s3.accessKey)",
		"exchange.s3.aws-secret-key=\(identifiants.s3.secretKey)",
	]
}
