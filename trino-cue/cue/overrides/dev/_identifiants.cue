// cue/overrides/dev/_identifiants.cue
package dev

// ========== IDENTIFIANTS ==========
identifiants: {
  postgres: {
    user:     "trino"
    password: "CHANGE_ME_POSTGRES_PASSWORD" // À remplacer par un secret réel
  }

  s3: {
    accessKey: "CHANGE_ME_S3_ACCESS_KEY"
    secretKey: "CHANGE_ME_S3_SECRET_KEY"
  }

  // Authentification Trino (pour l'UI ou les clients)
  trino: {
    adminUser:     "admin"
    adminPassword: "CHANGE_ME_ADMIN_PASSWORD"
  }
}
