// cue/base/trino.cue
package base

// ========== GLOBAL ==========
nameOverride: *"" | string
fullnameOverride: *"" | string
coordinatorNameOverride: *"" | string
workerNameOverride: *"" | string

// ========== IMAGE ==========
image: {
  registry:        *"" | string
  repository:      *"trinodb/trino" | string
  tag:             *"" | string
  digest:          *"" | string
  useRepositoryAsSoleImageReference: false
  pullPolicy:      *"IfNotPresent" | string
}

imagePullSecrets: [...{name: string}]

// ========== SERVER ==========
server: {
  workers: 2

  node: {
    environment: *"production" | string
    dataDir:     *"/data/trino" | string
    pluginDir:   *"/usr/lib/trino/plugin" | string
  }

  log: {
    trino: {
      level: *"INFO" | "DEBUG" | "WARN" | "ERROR" | "FATAL"
    }
  }

  config: {
    path: *"/etc/trino" | string
    https: {
      enabled: false
      port:   8443 & >= 1024 & <= 65535
      keystore: {
        path: *"" | string
      }
    }
    authenticationType: *"" | string
    query: {
      maxMemory: *"4GB" | string
    }
    exchangeManager: {}
    workerExtraConfig:   *"" | string
    coordinatorExtraConfig: *"" | string
  }

  autoscaling: {
    enabled: false
    maxReplicas: 5
    targetCPUUtilizationPercentage:    *50 | int & >= 0 & <= 100
    targetMemoryUtilizationPercentage: *80 | int & >= 0 & <= 100
    behavior: {}
  }

  keda: {
    enabled: false
    pollingInterval: 30
    cooldownPeriod: 300
    initialCooldownPeriod: 0
    minReplicaCount: 0
    maxReplicaCount: 5
    fallback: {}
    advanced: {}
    triggers: [...]
    annotations: {}
  }
}

// ========== SECURITY ==========
accessControl: {}
headerAuthenticator: {}
resourceGroups: {}
sessionProperties: {}
eventListenerProperties: [...]

// ========== CATALOGS ==========
catalogs: {
  tpch:  *"connector.name=tpch\ntpch.splits-per-node=4" | null
  tpcds: *"connector.name=tpcds\ntpcds.splits-per-node=4" | null
}

additionalCatalogs: {}

// ========== ENV & SECRETS ==========
env: [...{name: string, value: string}]
envFrom: [...{configMapRef?: {name: string}, secretRef?: {name: string}}]

// ========== CONTAINERS ==========
initContainers: {
  coordinator: [...]
  worker:      [...]
}

sidecarContainers: {
  coordinator: [...]
  worker:      [...]
}

securityContext: {
  runAsUser:  1000
  runAsGroup: 1000
}

containerSecurityContext: {
  allowPrivilegeEscalation: false
  capabilities: {
    drop: ["ALL"]
  }
}

shareProcessNamespace: {
  coordinator: false
  worker:      false
}

// ========== SERVICE ==========
service: {
  annotations: {}
  type: *"ClusterIP" | string
  port: 8080 & >= 1024 & <= 65535
  nodePort: *"" | string
}

auth: {}

// ========== SERVICE ACCOUNT ==========
serviceAccount: {
  create: false
  name:   *"" | string
  annotations: {}
}

// ========== CONFIG/SECRET MOUNTS ==========
configMounts: [...{name: string, configMap: string, path: string, subPath?: string}]
secretMounts: [...{name: string, secretName: string, path: string, subPath?: string}]

// ========== COORDINATOR ==========
coordinator: {
  deployment: {
    annotations: {}
    progressDeadlineSeconds: 600
    revisionHistoryLimit: 10
    strategy: {}
  }

  jvm: {
    maxHeapSize: *"8G" | string
    minHeapSize: *"" | string
    maxHeapPercent: *"" | string
    initialHeapPercent: *"" | string
    gcMethod: {
      type: *"UseG1GC" | string
      g1: {
        heapRegionSize: *"32M" | string
      }
    }
  }

  config: {
    memory: {
      heapHeadroomPerNode: *"" | string
    }
    nodeScheduler: {
      includeCoordinator: false
    }
    query: {
      maxMemoryPerNode: *"1GB" | string
    }
  }

  additionalJVMConfig: [...]
  additionalExposedPorts: {}
  resources: {}
  livenessProbe: {}
  readinessProbe: {}
  startupProbe: {}
  lifecycle: {}
  terminationGracePeriodSeconds: 30
  nodeSelector: {}
  tolerations: [...]
  affinity: {}
  priorityClassName: *"" | string
  annotations: {}
  labels: {}
  configMounts: [...]
  secretMounts: [...]
  additionalConfigFiles: {}
  additionalVolumes: [...]
  additionalVolumeMounts: [...]
}

// ========== WORKER ==========
worker: {
  deployment: {
    annotations: {}
    progressDeadlineSeconds: 600
    revisionHistoryLimit: 10
    strategy: {}
  }

  jvm: {
    maxHeapSize: *"8G" | string
    minHeapSize: *"" | string
    maxHeapPercent: *"" | string
    initialHeapPercent: *"" | string
    gcMethod: {
      type: *"UseG1GC" | string
      g1: {
        heapRegionSize: *"32M" | string
      }
    }
  }

  config: {
    memory: {
      heapHeadroomPerNode: *"" | string
    }
    query: {
      maxMemoryPerNode: *"1GB" | string
    }
  }

  additionalJVMConfig: [...]
  additionalExposedPorts: {}
  resources: {}
  livenessProbe: {}
  readinessProbe: {}
  startupProbe: {}
  lifecycle: {}
  gracefulShutdown: {
    enabled: *false | bool
    gracePeriodSeconds: 120
  }
  terminationGracePeriodSeconds: 30
  nodeSelector: {}
  tolerations: [...]
  affinity: {}
  topologySpreadConstraints: [...]
  priorityClassName: *"" | string
  annotations: {}
  labels: {}
  configMounts: [...]
  secretMounts: [...]
  additionalConfigFiles: {}
  additionalVolumes: [...]
  additionalVolumeMounts: [...]

  // ========== ADDITIONAL PROPERTIES ==========
  additionalNodeProperties:    [...]
  additionalConfigProperties:  [...]
  additionalLogProperties:     [...]
  additionalExchangeManagerProperties: [...]
}
