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

## Générer les values (workflow)

Depuis la racine du dépôt, en 3 étapes :

```sh
# 1. Valider le paquet CUE (aucune sortie, code de retour 0 = OK)
cue vet ./trino-cue/cue
cue vet ./...                       # optionnel : valide tous les paquets du module

# 2. Générer le fichier values à partir du champ `output` de main.cue
cue export ./trino-cue/cue -e output --out yaml > trino-cue/generated/trino-values.yaml

# 3. Vérifier que le fichier commité est à jour (aucune différence = OK)
cue export ./trino-cue/cue -e output --out yaml | diff - trino-cue/generated/trino-values.yaml
```

Détail des options d'export :

- `-e output` (`--expression`) : exporte uniquement le champ `output` (le bloc
  `trino` fusionné base + override) — sans lui, le YAML contiendrait une clé
  enveloppe `output:` inutilisable directement comme values Helm ;
- `--out yaml` : force la sortie YAML pour le fichier `.yaml` ;
- `> trino-cue/generated/trino-values.yaml` : écrit le résultat dans le fichier
  généré du produit.

> Note : avec cue >= v0.9, un argument répertoire relatif doit commencer par
> `./` (`cue vet ./trino-cue/cue`). La forme nue `cue vet trino-cue/cue` est
> interprétée comme un chemin d'import et rejetée par la CLI
> (« standard library import path ... cannot be imported as a CUE package »).
> La forme par chemin de paquet fonctionne aussi :
> `cue vet github.com/gmndr/cue-compiler/trino-cue/cue:main`.

Version de langage CUE épinglée : `v0.9.0` (compatible cue >= v0.9).
