// cue/overrides/dev/_connexions.cue
package overrides.dev

// ========== CONNEXIONS EXTERNES ==========
// Exemple : Connexion à PostgreSQL (pour le catalogue 'postgresql')
connexions: {
  postgres: {
    host:     "postgres-dev.postgres.svc.cluster.local"
    port:     5432
    database: "trino_metadata"
    user:     "trino" // À surcharger via _identifiants.cue
    password: ""     // À surcharger via _identifiants.cue
    ssl:      false
  }

  // Connexion à S3 (pour le catalogue 'hive' ou 'iceberg')
  s3: {
    endpoint:        "https://s3-dev.internal"
    region:          "eu-west-1"
    accessKey:       "" // À surcharger via _identifiants.cue
    secretKey:       "" // À surcharger via _identifiants.cue
    bucket:          "trino-data-dev"
    pathStyleAccess: true
  }

  // Connexion à une API externe (pour l'authentification)
  externalAPI: {
    url:      "https://api-dev.internal"
    authType: "BEARER"
  }
}
