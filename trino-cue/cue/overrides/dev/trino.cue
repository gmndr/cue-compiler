// cue/overrides/dev/trino.cue
package dev

import (
  "base"
  "_connexions"
  "_identifiants"
)

// ========== FUSION DES VALEURS ==========
trino: base.trino & {
  // ========== GLOBAL ==========
  fullnameOverride: "trino-dev"

  // ========== IMAGE ==========
  image: {
    repository: "trinodb/trino"
    tag:        "422" // Version de Trino
    pullPolicy: "IfNotPresent"
  }

  // ========== SERVER ==========
  server: {
    workers: 2
    node: {
      environment: "development"
    }
    config: {
      https: {
        enabled: false
      }
      authenticationType: "PASSWORD" // ou "CERTIFICATE", "OAUTH2", etc.
    }
  }

  // ========== CATALOGS ==========
  // Remplace les catalogues par défaut par ceux de ton environnement
  catalogs: {
    // Catalogue PostgreSQL (pour les métadonnées)
    postgresql: |
      connector.name=postgresql
      connection-url=jdbc:postgresql://\(_connexions.postgres.host):\(_connexions.postgres.port)/\(_connexions.postgres.database)
      connection-user=\(_identifiants.postgres.user)
      connection-password=\(_identifiants.postgres.password)

    // Catalogue Hive (avec stockage S3)
    hive: |
      connector.name=hive
      hive.metastore.uri=thrift://hive-metastore-dev.hive.svc.cluster.local:9083
      hive.s3.endpoint=\(_connexions.s3.endpoint)
      hive.s3.path-style-access=\(_connexions.s3.pathStyleAccess)
      hive.s3.aws-access-key=\(_identifiants.s3.accessKey)
      hive.s3.aws-secret-key=\(_identifiants.s3.secretKey)

    // Supprime les catalogues par défaut (tpch, tpcds)
    tpch: null
    tpcds: null
  }

  // ========== AUTHENTIFICATION ==========
  auth: {
    passwordAuth: "\(_identifiants.trino.adminUser):\(_identifiants.trino.adminPassword)"
    passwordAuthSecret: "" // Optionnel : nom d'un Secret Kubernetes
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

    // Montage des secrets pour les connexions
    secretMounts: [
      {
        name:      "postgres-credentials"
        secretName: "trino-postgres-credentials"
        path:      "/etc/trino/secrets/postgres"
      },
      {
        name:      "s3-credentials"
        secretName: "trino-s3-credentials"
        path:      "/etc/trino/secrets/s3"
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

    // Activation du graceful shutdown
    gracefulShutdown: {
      enabled: true
      gracePeriodSeconds: 120
    }

    // Tolérances pour les workers (exemple)
    tolerations: [
      {
        key:      "dedicated"
        operator: "Equal"
        value:    "trino"
        effect:   "NoSchedule"
      },
    ]

    // Affinité pour répartir les workers
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

    // Montage des secrets
    secretMounts: [
      {
        name:      "postgres-credentials"
        secretName: "trino-postgres-credentials"
        path:      "/etc/trino/secrets/postgres"
      },
      {
        name:      "s3-credentials"
        secretName: "trino-s3-credentials"
        path:      "/etc/trino/secrets/s3"
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
    {name: "TRINO_ENV", value: "development"},
    {name: "JAVA_TOOL_OPTIONS", value: "-Djavax.net.ssl.trustStore=/etc/trino/secrets/truststore.jks"},
  ]

  // ========== ADDITIONAL PROPERTIES ==========
  additionalConfigProperties: [
    "query.client.timeout=5m",
    "query.max-run-time=1h",
    "query.max-queued-time=30m",
  ]

  additionalExchangeManagerProperties: [
    "exchange.s3.region=\(_connexions.s3.region)",
    "exchange.s3.endpoint=\(_connexions.s3.endpoint)",
    "exchange.s3.aws-access-key=\(_identifiants.s3.accessKey)",
    "exchange.s3.aws-secret-key=\(_identifiants.s3.secretKey)",
  ]
}
