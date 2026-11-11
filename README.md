# Trino CUE Compiler

Ce dépôt gère la configuration déclarative de Trino à l'aide du langage [CUE](https://cuelang.org/). Il factorise les valeurs communes dans une base minimale et applique de légères surcharges par environnement pour générer les valeurs Helm (`values.yaml`).

## Arborescence du projet

```text
trino-cue/
├── generated/
│   └── trino-values.yaml        # Fichier YAML généré à partir de CUE pour Helm
└── cue/
    ├── cue.mod/
    │   └── module.cue           # Déclaration du module CUE ("trino.cue")
    ├── base/
    │   ├── trino.cue            # Schéma et configuration Trino par défaut
    │   ├── connexions.cue       # Paramètres des connexions externes (Postgres, S3)
    │   └── identifiants.cue     # Placeholders des identifiants et secrets
    ├── overrides/
    │   ├── dev/
    │   │   └── trino.cue        # Surcharges minimales pour le développement
    │   └── prod/
    │       └── trino.cue        # Surcharges minimales pour la production
    └── main.cue                 # Point d'entrée CUE : importe l'environnement ciblé et expose `output`
```

## Rôle des fichiers

- **`cue/cue.mod/module.cue`** : Définit le module CUE (`trino.cue`) pour permettre les imports internes.
- **`cue/base/trino.cue`** : Contient la configuration Trino de référence (image, serveur, catalogues Postgres/Hive, auth, JVM, service).
- **`cue/base/connexions.cue`** : Définit les adresses et options des services externes.
- **`cue/base/identifiants.cue`** : Centralise les identifiants et secrets.
- **`cue/overrides/dev/trino.cue`** : Delta pour le dev (nom d'hôte dev, bucket dev, environnement `development`).
- **`cue/overrides/prod/trino.cue`** : Delta pour la prod (nom d'hôte prod, 4 workers, 8G JVM).
- **`cue/main.cue`** : Expose `output: dev.trino` pour l'exportation Helm.

## Commandes utiles

Depuis le dossier `trino-cue/cue/` :

```bash
# Valider les configurations CUE
cue vet .

# Évaluer l'export complet pour l'environnement sélectionné
cue eval . -e output

# Générer le fichier de valeurs YAML pour Helm
cue export . -e output --out yaml > ../generated/trino-values.yaml
```
