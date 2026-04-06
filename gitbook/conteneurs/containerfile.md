---
description: >-
  Construire une image personnalisée avec un Containerfile /
  Build a custom image with a Containerfile
---

# Lab 05 — Containerfile & Construction d'images / Image Build

{% tabs %}
{% tab title="Français" %}

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

{% endtab %}
{% tab title="English" %}

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

{% endtab %}
{% endtabs %}
