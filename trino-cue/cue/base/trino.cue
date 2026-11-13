// Généré depuis charts/trino/values.yaml par tools/values2cue.py — ne pas éditer à la main.
package base

nameOverride:            *null | _
fullnameOverride:        *null | _
coordinatorNameOverride: *null | _
workerNameOverride:      *null | _
image: {
	registry:                          *"" | _
	repository:                        *"trinodb/trino" | _
	tag:                               *"" | _
	digest:                            *"" | _
	useRepositoryAsSoleImageReference: *false | _
	pullPolicy:                        *"IfNotPresent" | _
}
imagePullSecrets: *[] | _
server: {
	workers: *2 | _
	node: {
		environment: *"production" | _
		dataDir:     *"/data/trino" | _
		pluginDir:   *"/usr/lib/trino/plugin" | _
	}
	log: {
		trino: {
			level: *"INFO" | _
		}
	}
	config: {
		path: *"/etc/trino" | _
		https: {
			enabled: *false | _
			port:    *8443 | _
			keystore: {
				path: *"" | _
			}
		}
		authenticationType: *"" | _
		query: {
			maxMemory: *"4GB" | _
		}
	}
	exchangeManager: {}
	workerExtraConfig:      *"" | _
	coordinatorExtraConfig: *"" | _
	autoscaling: {
		enabled:                           *false | _
		maxReplicas:                       *5 | _
		targetCPUUtilizationPercentage:    *50 | _
		targetMemoryUtilizationPercentage: *80 | _
		behavior: {}
	}
	keda: {
		enabled:               *false | _
		pollingInterval:       *30 | _
		cooldownPeriod:        *300 | _
		initialCooldownPeriod: *0 | _
		minReplicaCount:       *0 | _
		maxReplicaCount:       *5 | _
		fallback: {}
		advanced: {}
		triggers: *[] | _
		annotations: {}
	}
}
accessControl: {}
headerAuthenticator: {}
resourceGroups: {}
additionalNodeProperties: *[] | _
additionalConfigProperties: *[] | _
additionalLogProperties: *[] | _
additionalExchangeManagerProperties: *[] | _
sessionProperties: {}
eventListenerProperties: *[] | _
catalogs: {
	tpch:  *"connector.name=tpch\ntpch.splits-per-node=4\n" | _
	tpcds: *"connector.name=tpcds\ntpcds.splits-per-node=4\n" | _
}
additionalCatalogs: {}
env: *[] | _
envFrom: *[] | _
initContainers: {}
sidecarContainers: {}
securityContext: {
	runAsUser:  *1000 | _
	runAsGroup: *1000 | _
}
containerSecurityContext: {
	allowPrivilegeEscalation: *false | _
	capabilities: {
		drop: *["ALL"] | _
	}
}
shareProcessNamespace: {
	coordinator: *false | _
	worker:      *false | _
}
service: {
	annotations: {}
	type:     *"ClusterIP" | _
	port:     *8080 | _
	nodePort: *"" | _
}
auth: {}
serviceAccount: {
	create: *false | _
	name:   *"" | _
	annotations: {}
}
configMounts: *[] | _
secretMounts: *[] | _
coordinator: {
	deployment: {
		annotations: {}
		progressDeadlineSeconds: *600 | _
		revisionHistoryLimit:    *10 | _
		strategy: {}
	}
	jvm: {
		maxHeapSize:        *"8G" | _
		minHeapSize:        *null | _
		maxHeapPercent:     *null | _
		initialHeapPercent: *null | _
		gcMethod: {
			type: *"UseG1GC" | _
			g1: {
				heapRegionSize: *"32M" | _
			}
		}
	}
	config: {
		memory: {
			heapHeadroomPerNode: *"" | _
		}
		nodeScheduler: {
			includeCoordinator: *false | _
		}
		query: {
			maxMemoryPerNode: *"1GB" | _
		}
	}
	additionalJVMConfig: *[] | _
	additionalExposedPorts: {}
	resources: {}
	livenessProbe: {}
	readinessProbe: {}
	startupProbe: {}
	lifecycle: {}
	terminationGracePeriodSeconds: *30 | _
	nodeSelector: {}
	tolerations: *[] | _
	affinity: {}
	additionalConfigFiles: {}
	additionalVolumes: *[] | _
	additionalVolumeMounts: *[] | _
	priorityClassName: *null | _
	annotations: {}
	labels: {}
	configMounts: *[] | _
	secretMounts: *[] | _
}
worker: {
	deployment: {
		annotations: {}
		progressDeadlineSeconds: *600 | _
		revisionHistoryLimit:    *10 | _
		strategy: {}
	}
	jvm: {
		maxHeapSize:        *"8G" | _
		minHeapSize:        *null | _
		maxHeapPercent:     *null | _
		initialHeapPercent: *null | _
		gcMethod: {
			type: *"UseG1GC" | _
			g1: {
				heapRegionSize: *"32M" | _
			}
		}
	}
	config: {
		memory: {
			heapHeadroomPerNode: *"" | _
		}
		query: {
			maxMemoryPerNode: *"1GB" | _
		}
	}
	additionalJVMConfig: *[] | _
	additionalExposedPorts: {}
	resources: {}
	livenessProbe: {}
	readinessProbe: {}
	startupProbe: {}
	lifecycle: {}
	gracefulShutdown: {
		enabled:            *false | _
		gracePeriodSeconds: *120 | _
	}
	terminationGracePeriodSeconds: *30 | _
	nodeSelector: {}
	tolerations: *[] | _
	affinity: {}
	topologySpreadConstraints: *[] | _
	additionalConfigFiles: {}
	additionalVolumes: *[] | _
	additionalVolumeMounts: *[] | _
	priorityClassName: *null | _
	annotations: {}
	labels: {}
	configMounts: *[] | _
	secretMounts: *[] | _
}
kafka: {
	mountPath: *"/etc/trino/schemas" | _
	tableDescriptions: {}
}
jmx: {
	enabled:      *false | _
	registryPort: *9080 | _
	serverPort:   *9081 | _
	exporter: {
		enabled:          *false | _
		image:            *"bitnamilegacy/jmx-exporter:1.4.0" | _
		pullPolicy:       *"Always" | _
		port:             *5556 | _
		configProperties: *"" | _
		securityContext: {}
		resources: {}
	}
	coordinator: {}
	worker: {}
}
serviceMonitor: {
	enabled:    *false | _
	apiVersion: *"monitoring.coreos.com/v1" | _
	labels: {
		prometheus: *"kube-prometheus" | _
	}
	interval:      *"30s" | _
	scrapeTimeout: *"" | _
	coordinator: {}
	worker: {}
}
commonLabels: {}
ingress: {
	enabled:   *false | _
	className: *"" | _
	annotations: {}
	hosts: *[] | _
	tls: *[] | _
}
gateway: {
	enabled: *false | _
	annotations: {}
	parentRefs: *[] | _
	hostnames: *[] | _
	rules: *[] | _
}
networkPolicy: {
	enabled: *false | _
	ingress: *[] | _
	egress: *[] | _
}
