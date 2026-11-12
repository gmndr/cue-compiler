# cue-compiler

Alternative à [okdp-compiler](https://github.com/OKDP/okdp-compiler) : à partir d'un
chart upstream, définir des fichiers `values` surchargés et personnalisés à un
contexte particulier (dev, prod, ...), incluant les informations de connexion
et les identifiants des produits existants.

## Structure

Le dépôt est un module CUE (`cue.mod/module.cue`, module
`github.com/gmndr/cue-compiler`).

Chaque produit possède un paquet CUE, par exemple `trino-cue/cue` :

```
trino-cue/cue/
├── main.cue                  # point d'entrée : output: dev.trino
├── base/trino.cue            # schéma + valeurs par défaut (chart upstream)
└── overrides/
    ├── dev/trino.cue         # surcharges du contexte "dev" (fusion avec base)
    ├── connexions/           # connexions externes (postgres, s3, ...)
    └── identifiants/         # identifiants / secrets (à surcharger par env)
trino-cue/generated/trino-values.yaml   # values générées (export CUE)
```

Pour ajouter un contexte (ex. `prod`), créer `overrides/prod/trino.cue`
(paquet `prod`) et pointer `main.cue` dessus.

## Commandes

Depuis la racine du dépôt :

```sh
# Valider le paquet CUE (aucune sortie = OK)
cue vet ./trino-cue/cue
cue vet ./...                       # tous les paquets

# Générer les values Helm
cue export ./trino-cue/cue -e output --out yaml > trino-cue/generated/trino-values.yaml
```

> Note : avec cue >= v0.9, un argument répertoire relatif doit commencer par
> `./` (`cue vet ./trino-cue/cue`). La forme nue `cue vet trino-cue/cue` est
> interprétée comme un chemin d'import et rejetée par la CLI
> (« standard library import path ... cannot be imported as a CUE package »).
> La forme par chemin de paquet fonctionne aussi :
> `cue vet github.com/gmndr/cue-compiler/trino-cue/cue:main`.

Version de langage CUE épinglée : `v0.9.0` (compatible cue >= v0.9).
