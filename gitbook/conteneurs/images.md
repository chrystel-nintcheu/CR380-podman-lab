---
description: >-
  Chercher, télécharger et inspecter des images / 
  Search, pull and inspect images
---

# Lab 04 — Images & Registres / Images & Registries

{% tabs %}
{% tab title="Français" %}

## Avant de commencer

**Prérequis** : Lab 03 doit être validé (gestion de base des conteneurs).

**Glossaire**
| Terme | Définition |
|-------|------------|
| Image | Modèle en lecture seule composé de couches (layers) |
| Registre | Serveur distant hébergeant des images (docker.io, quay.io) |
| Layer (couche) | Différence incrémentale dans le système de fichiers |
| Tag | Version d'une image (ex: nginx:alpine, nginx:latest) |
| Digest | Identifiant SHA256 unique et immutable d'une image |

📖 **Documentation officielle** :
- [podman-pull(1)](https://docs.podman.io/en/latest/markdown/podman-pull.1.html)
- [podman-images(1)](https://docs.podman.io/en/latest/markdown/podman-images.1.html)
- [podman-image-inspect(1)](https://docs.podman.io/en/latest/markdown/podman-image-inspect.1.html)
- [podman-rmi(1)](https://docs.podman.io/en/latest/markdown/podman-rmi.1.html)

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
podman search docker.io/nginx --limit 5
```

> ⚠️ Le préfixe de registre (`docker.io/`) est **obligatoire** pour `podman search`.

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

## Dépannage

| Symptôme | Cause | Solution |
|----------|-------|----------|
| `Error: short-name resolution enforced` | Préfixe de registre manquant | Utilisez `docker.io/nginx` au lieu de `nginx` |
| `podman search` ne retourne rien | Registre inaccessible ou filtré | Vérifiez `curl https://registry.hub.docker.com` |
| `podman rmi` échoue | Image utilisée par un conteneur | `podman rm -f <conteneur>` d'abord |
| `--format` retourne une erreur | Syntaxe Go template incorrecte | Vérifiez les accolades doubles `{{.Field}}` |
| Taille d'image inattendue | Cache local de couches partagées | `podman image inspect --format '{{.Size}}'` pour la taille réelle |

{% endtab %}
{% tab title="English" %}

## Before You Start

**Prerequisites**: Lab 03 must pass (basic container management).

**Glossary**
| Term | Definition |
|------|------------|
| Image | Read-only template made of layers |
| Registry | Remote server hosting images (docker.io, quay.io) |
| Layer | Incremental filesystem difference |
| Tag | Version of an image (e.g., nginx:alpine, nginx:latest) |
| Digest | Unique immutable SHA256 identifier of an image |

📖 **Official docs**:
- [podman-pull(1)](https://docs.podman.io/en/latest/markdown/podman-pull.1.html)
- [podman-images(1)](https://docs.podman.io/en/latest/markdown/podman-images.1.html)
- [podman-image-inspect(1)](https://docs.podman.io/en/latest/markdown/podman-image-inspect.1.html)
- [podman-rmi(1)](https://docs.podman.io/en/latest/markdown/podman-rmi.1.html)

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
podman search docker.io/nginx --limit 5
```

> ⚠️ The registry prefix (`docker.io/`) is **required** for `podman search`.

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

## Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| `Error: short-name resolution enforced` | Missing registry prefix | Use `docker.io/nginx` instead of `nginx` |
| `podman search` returns nothing | Registry unreachable or filtered | Check `curl https://registry.hub.docker.com` |
| `podman rmi` fails | Image used by a container | `podman rm -f <container>` first |
| `--format` returns error | Incorrect Go template syntax | Check double braces `{{.Field}}` |
| Unexpected image size | Shared layer cache | `podman image inspect --format '{{.Size}}'` for real size |

{% endtab %}
{% endtabs %}
