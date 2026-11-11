// cue/base/trino.cue
package base

trino: {
	fullnameOverride: *"trino" | string

	image: {
		repository: *"trinodb/trino" | string
		tag:        *"422" | string
		pullPolicy: *"IfNotPresent" | string
	}

	server: {
		workers: *2 | int
		node: environment: *"production" | string
		config: {
			path:               *"/etc/trino" | string
			authenticationType: *"PASSWORD" | string
			query: maxMemory:   *"4GB" | string
		}
	}

	catalogs: {
		tpch:  null
		tpcds: null
		...
	}

	auth: passwordAuth: "\(identifiants.trino.adminUser):\(identifiants.trino.adminPassword)"

	coordinator: {
		jvm: maxHeapSize: *"4G" | string
		config: query: maxMemoryPerNode: *"2GB" | string
	}

	worker: {
		jvm: maxHeapSize: *"4G" | string
		config: query: maxMemoryPerNode: *"2GB" | string
	}

	service: {
		type: *"ClusterIP" | string
		port: *8080 | int
	}
}
