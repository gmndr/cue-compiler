// cue/base/trino.cue
package base

// ========== GLOBAL ==========
nameOverride: *""
fullnameOverride: *""
coordinatorNameOverride: *""
workerNameOverride: *""

// ========== IMAGE ==========
image: {
  registry:        *""
  repository:      *"trinodb/trino"
  tag:             *""
  digest:          *""
  useRepositoryAsSoleImageReference: false
  pullPolicy:      *"IfNotPresent"
}

imagePullSecrets: [] & [for _, v in _ { v: name: string }]

// ========== SERVER ==========
server: {
  workers: 2

  node: {
    environment: *"production"
    dataDir:     *"/data/trino"
    pluginDir:   *"/usr/lib/trino/plugin"
  }

  log: {
    trino: {
      level: *"INFO" | "DEBUG" | "WARN" | "ERROR" | "FATAL"
    }
  }

  config: {
    path: *""/etc/trino""
    https: {
      enabled: false
      port:   8443 & >= 1024 & <= 65535
      keystore: {
        path: *""
      }
    }
    authenticationType: *""
    query: {
      maxMemory: *"4GB"
    }
    exchangeManager: {}
    workerExtraConfig:   *""
    coordinatorExtraConfig: *""
  }

  autoscaling: {
    enabled: false
    maxReplicas: 5
    targetCPUUtilizationPercentage:    50 | int & >= 0 & <= 100
    targetMemoryUtilizationPercentage: 80 | int & >= 0 & <= 100
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
    triggers: []
    annotations: {}
  }
}

// ========== SECURITY ==========
accessControl: {}
headerAuthenticator: {}
resourceGroups: {}
sessionProperties: {}
eventListenerProperties: []

// ========== CATALOGS ==========
catalogs: {
  tpch:  *"connector.name=tpch\ntpch.splits-per-node=4"
  tpcds: *"connector.name=tpcds\ntpcds.splits-per-node=4"
}

additionalCatalogs: {}

// ========== ENV & SECRETS ==========
env: [for _, v in _ { v: name: string, value: string }]
envFrom: [for _, v in _ { v: configMapRef?: {name: string}, secretRef?: {name: string} }]

// ========== CONTAINERS ==========
initContainers: {
  coordinator: []
  worker:      []
}

sidecarContainers: {
  coordinator: []
  worker:      []
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
  type: *"ClusterIP"
  port: 8080 & >= 1024 & <= 65535
  nodePort: *""
}

auth: {}

// ========== SERVICE ACCOUNT ==========
serviceAccount: {
  create: false
  name:   *""
  annotations: {}
}

// ========== CONFIG/SECRET MOUNTS ==========
configMounts: [for _, v in _ { v: name: string, configMap: string, path: string, subPath?: string }]
secretMounts: [for _, v in _ { v: name: string, secretName: string, path: string, subPath?: string }]

// ========== COORDINATOR ==========
coordinator: {
  deployment: {
    annotations: {}
    progressDeadlineSeconds: 600
    revisionHistoryLimit: 10
    strategy: {}
  }

  jvm: {
    maxHeapSize: *"8G"
    minHeapSize: *""
    maxHeapPercent: *""
    initialHeapPercent: *""
    gcMethod: {
      type: *"UseG1GC"
      g1: {
        heapRegionSize: *"32M"
      }
    }
  }

  config: {
    memory: {
      heapHeadroomPerNode: *""
    }
    nodeScheduler: {
      includeCoordinator: false
    }
    query: {
      maxMemoryPerNode: *"1GB"
    }
  }

  additionalJVMConfig: []
  additionalExposedPorts: {}
  resources: {}
  livenessProbe: {}
  readinessProbe: {}
  startupProbe: {}
  lifecycle: {}
  terminationGracePeriodSeconds: 30
  nodeSelector: {}
  tolerations: []
  affinity: {}
  priorityClassName: ~
  annotations: {}
  labels: {}
  configMounts: []
  secretMounts: []
  additionalConfigFiles: {}
  additionalVolumes: []
  additionalVolumeMounts: []
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
    maxHeapSize: *"8G"
    minHeapSize: *""
    maxHeapPercent: *""
    initialHeapPercent: *""
    gcMethod: {
      type: *"UseG1GC"
      g1: {
        heapRegionSize: *"32M"
      }
    }
  }

  config: {
    memory: {
      heapHeadroomPerNode: *""
    }
    query: {
      maxMemoryPerNode: *"1GB"
    }
  }

  additionalJVMConfig: []
  additionalExposedPorts: {}
  resources: {}
  livenessProbe: {}
  readinessProbe: {}
  startupProbe: {}
  lifecycle: {}
  gracefulShutdown: {
    enabled: false
    gracePeriodSeconds: 120
  }
  terminationGracePeriodSeconds: 30
  nodeSelector: {}
  tolerations: []
  affinity: {}
  topologySpreadConstraints: []
  priorityClassName: ~
  annotations: {}
  labels: {}
  configMounts: []
  secretMounts: []
  additionalConfigFiles: {}
  additionalVolumes: []
  additionalVolumeMounts: []

  // ========== ADDITIONAL PROPERTIES ==========
  additionalNodeProperties:    []
  additionalConfigProperties:  []
  additionalLogProperties:     []
  additionalExchangeManagerProperties: []
}
