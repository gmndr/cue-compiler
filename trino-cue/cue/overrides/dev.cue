// cue/overrides/dev.cue
package overrides

// Exporte la configuration fusionnée depuis dev/trino.cue
dev: import("dev/trino.cue").trino
