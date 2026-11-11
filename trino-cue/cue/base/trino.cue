// cue/base/trino.cue
package base

// ========== DEFINITION DE BASE TRINO ==========
trino: {
	// ========== GLOBAL ==========
	nameOverride:            *"" | string
	fullnameOverride:        *"" | string
	coordinatorNameOverride: *"" | string
	workerNameOverride:      *"" | string

	// ========== IMAGE ==========
	image: {
		registry:                          *"" | string
		repository:                        *"trinodb/trino" | string
		tag:                               *"" | string
		digest:                            *"" | string
		useRepositoryAsSoleImageReference: *false | bool
		pullPolicy:                        *"IfNotPresent" | string
	}

	imagePullSecrets: *[] | [...]

	// ========== SERVER ==========
	server: {
		workers: *2 | int

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
				enabled: *false | bool
				port:    *8443 | (int & >=1024 & <=65535)
				keystore: {
					path: *"" | string
				}
			}
			authenticationType: *"" | string
			query: {
				maxMemory: *"4GB" | string
			}
			exchangeManager: {...}
			workerExtraConfig:      *"" | string
			coordinatorExtraConfig: *"" | string
		}

		autoscaling: {
			enabled:                           *false | bool
			maxReplicas:                       *5 | int
			targetCPUUtilizationPercentage:    *50 | (int & >=0 & <=100)
			targetMemoryUtilizationPercentage: *80 | (int & >=0 & <=100)
			behavior: {...}
		}

		keda: {
			enabled:               *false | bool
			pollingInterval:       *30 | int
			cooldownPeriod:        *300 | int
			initialCooldownPeriod: *0 | int
			minReplicaCount:       *0 | int
			maxReplicaCount:       *5 | int
			fallback: {...}
			advanced: {...}
			triggers:    *[] | [...]
			annotations: {...}
		}
	}

	// ========== SECURITY ==========
	accessControl: {...}
	headerAuthenticator: {...}
	resourceGroups: {...}
	sessionProperties: {...}
	eventListenerProperties: *[] | [...]

	// ========== CATALOGS ==========
	catalogs: {
		tpch:  *"connector.name=tpch\ntpch.splits-per-node=4" | null | string
		tpcds: *"connector.name=tpcds\ntpcds.splits-per-node=4" | null | string
		...
	}

	additionalCatalogs: {...}

	// ========== ENV & SECRETS ==========
	env: *[] | [...]
	envFrom: *[] | [...]

	// ========== CONTAINERS ==========
	initContainers: {
		coordinator: *[] | [...]
		worker:      *[] | [...]
	}

	sidecarContainers: {
		coordinator: *[] | [...]
		worker:      *[] | [...]
	}

	securityContext: {
		runAsUser:  *1000 | int
		runAsGroup: *1000 | int
	}

	containerSecurityContext: {
		allowPrivilegeEscalation: *false | bool
		capabilities: {
			drop: *["ALL"] | [...string]
		}
	}

	shareProcessNamespace: {
		coordinator: *false | bool
		worker:      *false | bool
	}

	// ========== SERVICE ==========
	service: {
		annotations: {...}
		type:     *"ClusterIP" | string
		port:     *8080 | (int & >=1024 & <=65535)
		nodePort: *"" | string
	}

	auth: {...}

	// ========== SERVICE ACCOUNT ==========
	serviceAccount: {
		create: *false | bool
		name:   *"" | string
		annotations: {...}
	}

	// ========== CONFIG/SECRET MOUNTS ==========
	configMounts: *[] | [...]
	secretMounts: *[] | [...]

	// ========== COORDINATOR ==========
	coordinator: {
		deployment: {
			annotations: {...}
			progressDeadlineSeconds: *600 | int
			revisionHistoryLimit:    *10 | int
			strategy: {...}
		}

		jvm: {
			maxHeapSize:        *"8G" | string
			minHeapSize:        *"" | string
			maxHeapPercent:     *"" | string
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
				includeCoordinator: *false | bool
			}
			query: {
				maxMemoryPerNode: *"1GB" | string
			}
		}

		additionalJVMConfig:    *[] | [...]
		additionalExposedPorts: {...}
		resources: {...}
		livenessProbe: {...}
		readinessProbe: {...}
		startupProbe: {...}
		lifecycle: {...}
		terminationGracePeriodSeconds: *30 | int
		nodeSelector: {...}
		tolerations: *[] | [...]
		affinity: {...}
		priorityClassName: *null | string
		annotations: {...}
		labels: {...}
		configMounts: *[] | [...]
		secretMounts: *[] | [...]
		additionalConfigFiles: {...}
		additionalVolumes:      *[] | [...]
		additionalVolumeMounts: *[] | [...]
	}

	// ========== WORKER ==========
	worker: {
		deployment: {
			annotations: {...}
			progressDeadlineSeconds: *600 | int
			revisionHistoryLimit:    *10 | int
			strategy: {...}
		}

		jvm: {
			maxHeapSize:        *"8G" | string
			minHeapSize:        *"" | string
			maxHeapPercent:     *"" | string
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

		additionalJVMConfig:    *[] | [...]
		additionalExposedPorts: {...}
		resources: {...}
		livenessProbe: {...}
		readinessProbe: {...}
		startupProbe: {...}
		lifecycle: {...}
		gracefulShutdown: {
			enabled:            *false | bool
			gracePeriodSeconds: *120 | int
		}
		terminationGracePeriodSeconds: *30 | int
		nodeSelector: {...}
		tolerations: *[] | [...]
		affinity: {...}
		topologySpreadConstraints: *[] | [...]
		priorityClassName:         *null | string
		annotations: {...}
		labels: {...}
		configMounts: *[] | [...]
		secretMounts: *[] | [...]
		additionalConfigFiles: {...}
		additionalVolumes:      *[] | [...]
		additionalVolumeMounts: *[] | [...]

		// ========== ADDITIONAL PROPERTIES ==========
		additionalNodeProperties:            *[] | [...]
		additionalConfigProperties:          *[] | [...]
		additionalLogProperties:             *[] | [...]
		additionalExchangeManagerProperties: *[] | [...]
	}
}
