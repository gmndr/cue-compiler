# cue-compiler

Alternative à [okdp-compiler](https://github.com/OKDP/okdp-compiler) : à partir d'un
chart upstream, définir des fichiers `values` surchargés et personnalisés à un
contexte particulier (dev, prod, ...), incluant les informations de connexion
et les identifiants des produits existants.

## Structure

Le dépôt est un module CUE (`cue.mod/module.cue`, module
`github.com/gmndr/cue-compiler`).

```
charts/trino/                       # chart upstream OFFICIEL (trino 1.42.2, appVersion 480)
├── Chart.yaml                      #   version: 1.42.2
├── values.yaml                     #   values officielles par défaut (source de vérité)
└── templates/                      #   templates Helm du chart
tools/values2cue.py                 # convertit values.yaml -> base CUE (valeurs par défaut)
trino-cue/cue/
├── main.cue                        # point d'entrée : output: dev.trino
├── base/trino.cue                  # GÉNÉRÉ depuis charts/trino/values.yaml (défauts du chart)
└── overrides/
    ├── dev/trino.cue               # surcharges du contexte "dev" (fusion avec base)
    ├── connexions/                 # connexions externes (postgres, s3, ...)
    └── identifiants/               # identifiants / secrets (à surcharger par env)
trino-cue/generated/trino-values.yaml   # values surchargées générées (official + dev)
```

Pour ajouter un contexte (ex. `prod`), créer `overrides/prod/trino.cue`
(paquet `prod`) et pointer `main.cue` dessus.

## Chart upstream (Trino 1.42.2)

Le chart officiel est téléchargé dans `charts/trino/` (version épinglée :
**1.42.2**, release `trino-1.42.2` du dépôt
[trinodb/charts](https://github.com/trinodb/charts)).

Pour le télécharger / mettre à jour (depuis la racine du dépôt) :

```sh
# Méthode 1 : via helm (chart packagé officiel)
helm repo add trino https://trinodb.github.io/charts/
helm repo update
helm pull trino/trino --version 1.42.2 --untar --untardir charts

# Méthode 2 : via la release GitHub (sans helm)
gh release download trino-1.42.2 --repo trinodb/charts --dir /tmp
tar xzf /tmp/trino-1.42.2.tgz -C charts

# Méthode 3 : source du chart au tag correspondant
git clone --depth 1 --branch trino-1.42.2 https://github.com/trinodb/charts /tmp/trinodb-charts
cp -r /tmp/trinodb-charts/charts/trino charts/trino
```

Après un changement de version du chart, régénérer la base CUE à partir du
`values.yaml` officiel :

```sh
python3 tools/values2cue.py charts/trino/values.yaml trino-cue/cue/base/trino.cue base
cue fmt trino-cue/cue/base/trino.cue
```

Chaque valeur du `values.yaml` officiel devient une valeur par défaut CUE
(`*valeur | _`), ce qui permet aux overrides de contexte de la surcharger par
unification — le fichier de values généré est donc basé sur le values officiel
par défaut du chart.

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
