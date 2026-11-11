# Trino CUE Compiler

Ce dépôt gère la configuration déclarative de Trino à l'aide du langage [CUE](https://cuelang.org/). Il permet de factoriser les valeurs par défaut et d'appliquer des surcharges spécifiques par environnement afin de générer les valeurs Helm (`values.yaml`).

## Arborescence du projet

```text
trino-cue/
├── generated/
│   └── trino-values.yaml        # Fichier YAML généré à partir de CUE pour Helm
└── cue/
    ├── cue.mod/
    │   └── module.cue           # Déclaration du module CUE ("trino.cue")
    ├── base/
    │   ├── trino.cue            # Schéma et valeurs par défaut Trino (structure commune)
    │   ├── connexions.cue       # Paramètres par défaut des connexions externes (Postgres, S3)
    │   └── identifiants.cue     # Placeholders des identifiants et secrets
    ├── overrides/
    │   ├── dev/
    │   │   └── trino.cue        # Surcharges spécifiques à l'environnement de développement
    │   └── prod/
    │       └── trino.cue        # Surcharges spécifiques à l'environnement de production
    └── main.cue                 # Point d'entrée CUE : importe l'environnement ciblé et expose `output`
```

## Rôle des fichiers

- **`cue/cue.mod/module.cue`** : Définit le module CUE et sa version linguistique, permettant l'importation propre de packages internes via `trino.cue/...`.
- **`cue/base/trino.cue`** : Contient l'objet de base `trino` avec l'ensemble des définitions Kubernetes/Helm par défaut (serveur, JVM, service, etc.).
- **`cue/base/connexions.cue`** : Fournit le modèle et les valeurs génériques pour les services externes (PostgreSQL, S3).
- **`cue/base/identifiants.cue`** : Centralise les placeholders de secrets (identifiants admin, clés S3, base de données).
- **`cue/overrides/dev/trino.cue`** : Surcharge uniquement les paramètres propres à l'environnement de développement (ressources allégées, hôtes dev, etc.).
- **`cue/overrides/prod/trino.cue`** : Surcharge les paramètres adaptés à la production (nombre de workers, dimensionnement mémoire/CPU).
- **`cue/main.cue`** : Expose le champ `output` qui combine la base avec les surcharges de l'environnement choisi (par défaut `dev`).

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
