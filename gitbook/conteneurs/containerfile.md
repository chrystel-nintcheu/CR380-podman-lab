---
description: >-
  Construire une image personnalisée avec un Containerfile /
  Build a custom image with a Containerfile
---

# Lab 05 — Containerfile & Construction d'images / Image Build

{% tabs %}
{% tab title="Français" %}

## Avant de commencer

**Prérequis** : Lab 04 doit être validé (gestion des images et registres).

**Glossaire**
| Terme | Définition |
|-------|------------|
| Containerfile | Fichier d'instructions pour construire une image (= Dockerfile) |
| Contexte de build | Dossier envoyé au moteur de construction |
| .containerignore | Fichier listant ce qu'il faut exclure du contexte |
| Multi-stage build | Technique utilisant plusieurs FROM pour réduire la taille finale |
| ENTRYPOINT vs CMD | ENTRYPOINT = commande fixe ; CMD = arguments par défaut |

📖 **Documentation officielle** :
- [podman-build(1)](https://docs.podman.io/en/latest/markdown/podman-build.1.html)
- [Containerfile reference](https://docs.podman.io/en/latest/markdown/podman-build.1.html#containerfile)

## Objectif

Créer une image Podman personnalisée à partir d'un **Containerfile** (équivalent du Dockerfile).

{% hint style="info" %}
**Containerfile vs Dockerfile**

Podman accepte les deux noms: `Containerfile` est le nom officiel de l'OCI (Open Container Initiative), mais `Dockerfile` est aussi supporté. Le format et la syntaxe sont identiques.
{% endhint %}

## Structure d'un Containerfile

```dockerfile
# Image de base
FROM docker.io/nginx:alpine

# Métadonnées
LABEL maintainer="CR380 Podman Lab"

# Variables d'environnement
ENV APP_ENV=production

# Copier des fichiers
COPY containerfiles/index.html /usr/share/nginx/html/index.html

# Exposer le port
EXPOSE 80

# Commande de démarrage
CMD ["nginx", "-g", "daemon off;"]
```

## Étapes

### 1. Examiner le Containerfile

```bash
cat containerfiles/containerfile-base
```

### 2. Construire l'image

```bash
podman build -t monimage:base -f containerfiles/containerfile-base .
```

| Option | Signification |
|--------|---------------|
| `-t monimage:base` | Tag de l'image (nom:version) |
| `-f containerfiles/containerfile-base` | Chemin vers le Containerfile |
| `.` | Contexte de construction (dossier courant) |

### 3. Vérifier l'image

```bash
podman images monimage
```

### 4. Lancer l'image

```bash
podman run -d --name appCT -p 8090:80 monimage:base
curl http://localhost:8090
```

### 5. Inspecter les couches

```bash
podman image history monimage:base
```

## Instructions Containerfile essentielles

| Instruction | Rôle |
|-------------|------|
| `FROM` | Image de base |
| `RUN` | Exécuter une commande (crée une couche) |
| `COPY` | Copier des fichiers depuis l'hôte |
| `ADD` | Comme COPY mais supporte les URLs et .tar |
| `ENV` | Variable d'environnement |
| `EXPOSE` | Documenter le port exposé |
| `CMD` | Commande par défaut |
| `ENTRYPOINT` | Point d'entrée (non remplaçable facilement) |
| `LABEL` | Métadonnées |
| `WORKDIR` | Dossier de travail |
| `USER` | Utilisateur d'exécution |

## Test automatisé

```bash
./run-labs.sh --learn --lab 05
```

## Dépannage

| Symptôme | Cause | Solution |
|----------|-------|----------|
| `Error: COPY failed: file not found` | Chemin relatif incorrect dans COPY | Vérifiez le chemin par rapport au contexte de build |
| Build très lent | Contexte de build trop gros | Ajoutez un `.containerignore` (exclure .git, logs, etc.) |
| `Error: image not known` après build | Tag mal spécifié | Vérifiez `-t monimage:base` (pas d'espace dans le tag) |
| `Error: address already in use` | Port 8090 déjà pris | `ss -tlnp \| grep 8090` puis libérer le port |
| L'image ne contient pas les changements | Cache de build utilisé | Ajoutez `--no-cache` à `podman build` |

{% endtab %}
{% tab title="English" %}

## Before You Start

**Prerequisites**: Lab 04 must pass (image and registry management).

**Glossary**
| Term | Definition |
|------|------------|
| Containerfile | Instruction file to build an image (= Dockerfile) |
| Build context | Folder sent to the build engine |
| .containerignore | File listing what to exclude from context |
| Multi-stage build | Technique using multiple FROM to reduce final size |
| ENTRYPOINT vs CMD | ENTRYPOINT = fixed command; CMD = default arguments |

📖 **Official docs**:
- [podman-build(1)](https://docs.podman.io/en/latest/markdown/podman-build.1.html)
- [Containerfile reference](https://docs.podman.io/en/latest/markdown/podman-build.1.html#containerfile)

## Objective

Create a custom Podman image from a **Containerfile** (equivalent of Dockerfile).

{% hint style="info" %}
**Containerfile vs Dockerfile**

Podman accepts both names: `Containerfile` is the official OCI (Open Container Initiative) name, but `Dockerfile` is also supported. The format and syntax are identical.
{% endhint %}

## Containerfile structure

```dockerfile
# Base image
FROM docker.io/nginx:alpine

# Metadata
LABEL maintainer="CR380 Podman Lab"

# Environment variables
ENV APP_ENV=production

# Copy files
COPY containerfiles/index.html /usr/share/nginx/html/index.html

# Expose port
EXPOSE 80

# Start command
CMD ["nginx", "-g", "daemon off;"]
```

## Steps

### 1. Examine the Containerfile

```bash
cat containerfiles/containerfile-base
```

### 2. Build the image

```bash
podman build -t monimage:base -f containerfiles/containerfile-base .
```

| Option | Meaning |
|--------|---------|
| `-t monimage:base` | Image tag (name:version) |
| `-f containerfiles/containerfile-base` | Path to the Containerfile |
| `.` | Build context (current directory) |

### 3. Verify the image

```bash
podman images monimage
```

### 4. Run the image

```bash
podman run -d --name appCT -p 8090:80 monimage:base
curl http://localhost:8090
```

### 5. Inspect the layers

```bash
podman image history monimage:base
```

## Essential Containerfile instructions

| Instruction | Role |
|-------------|------|
| `FROM` | Base image |
| `RUN` | Execute a command (creates a layer) |
| `COPY` | Copy files from host |
| `ADD` | Like COPY but supports URLs and .tar |
| `ENV` | Environment variable |
| `EXPOSE` | Document exposed port |
| `CMD` | Default command |
| `ENTRYPOINT` | Entry point (not easily replaceable) |
| `LABEL` | Metadata |
| `WORKDIR` | Working directory |
| `USER` | Execution user |

## Automated test

```bash
./run-labs.sh --learn --lab 05
```

## Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| `Error: COPY failed: file not found` | Incorrect relative path in COPY | Check the path relative to build context |
| Very slow build | Build context too large | Add a `.containerignore` (exclude .git, logs, etc.) |
| `Error: image not known` after build | Tag misspelled | Check `-t monimage:base` (no spaces in the tag) |
| `Error: address already in use` | Port 8090 already taken | `ss -tlnp \| grep 8090` then free the port |
| Image doesn't contain changes | Build cache used | Add `--no-cache` to `podman build` |

{% endtab %}
{% endtabs %}
