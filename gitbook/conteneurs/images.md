---
description: >-
  Chercher, télécharger et inspecter des images / 
  Search, pull and inspect images
---

# Lab 04 — Images & Registres / Images & Registries

{% tabs %}
{% tab title="Français" %}

## Objectif

Apprendre à chercher des images dans les registres, les télécharger et inspecter leur structure.

## Registres supportés par Podman

Podman supporte plusieurs registres de conteneurs:

| Registre | URL | Contenu |
|---------|-----|---------|
| Docker Hub | `docker.io` | Images officielles et communautaires |
| Quay.io | `quay.io` | Images Red Hat / communautaires |
| GitHub Container Registry | `ghcr.io` | Images GitHub |

> ℹ️ Le préfixe de registre est **requis** avec Podman (ex: `docker.io/nginx`).
> Avec Docker, `nginx` tout seul suffisait.

## Étapes

### 1. Chercher une image

```bash
podman search nginx --limit 5
```

### 2. Télécharger une image

```bash
podman pull docker.io/alpine:latest
```

### 3. Lister les images locales

```bash
podman images
```

### 4. Inspecter une image

```bash
# Métadonnées complètes
podman image inspect docker.io/alpine:latest

# Format spécifique
podman image inspect docker.io/alpine:latest --format '{{.Os}}/{{.Architecture}}'
```

### 5. Voir les couches (layers) d'une image

```bash
podman image history docker.io/alpine:latest
```

### 6. Comparer les tailles

```bash
podman pull docker.io/nginx:latest
podman pull docker.io/nginx:alpine

# Comparer les tailles
podman images nginx
```

### 7. Supprimer une image

```bash
podman rmi docker.io/nginx:alpine
```

## Test automatisé

```bash
./run-labs.sh --learn --lab 04
```

{% endtab %}
{% tab title="English" %}

## Objective

Learn to search for images in registries, pull them, and inspect their structure.

## Registries supported by Podman

Podman supports multiple container registries:

| Registry | URL | Content |
|----------|-----|---------|
| Docker Hub | `docker.io` | Official and community images |
| Quay.io | `quay.io` | Red Hat / community images |
| GitHub Container Registry | `ghcr.io` | GitHub images |

> ℹ️ The registry prefix is **required** with Podman (e.g., `docker.io/nginx`).
> With Docker, `nginx` alone was enough.

## Steps

### 1. Search for an image

```bash
podman search nginx --limit 5
```

### 2. Pull an image

```bash
podman pull docker.io/alpine:latest
```

### 3. List local images

```bash
podman images
```

### 4. Inspect an image

```bash
# Full metadata
podman image inspect docker.io/alpine:latest

# Specific format
podman image inspect docker.io/alpine:latest --format '{{.Os}}/{{.Architecture}}'
```

### 5. View image layers

```bash
podman image history docker.io/alpine:latest
```

### 6. Compare sizes

```bash
podman pull docker.io/nginx:latest
podman pull docker.io/nginx:alpine

# Compare sizes
podman images nginx
```

### 7. Remove an image

```bash
podman rmi docker.io/nginx:alpine
```

## Automated test

```bash
./run-labs.sh --learn --lab 04
```

{% endtab %}
{% endtabs %}
