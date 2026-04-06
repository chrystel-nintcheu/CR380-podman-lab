---
description: >-
  Orchestrer plusieurs conteneurs avec Podman Compose /
  Orchestrate multiple containers with Podman Compose
---

# Lab 08 — Podman Compose

{% tabs %}
{% tab title="Français" %}

## Objectif

Apprendre à utiliser `podman-compose` pour gérer des applications multi-conteneurs.

{% hint style="info" %}
**Podman Compose vs Docker Compose**

`podman-compose` utilise exactement le **même format de fichier YAML** que Docker Compose (Compose Spec). Les fichiers sont interchangeables ! Seule la commande change: `docker compose` → `podman-compose`.
{% endhint %}

## Installation

```bash
# Option 1: via APT
sudo apt-get install -y podman-compose

# Option 2: via pip3
pip3 install podman-compose

# Vérification
podman-compose --version
```

## Fichier Compose de base

```yaml
# compose-files/nginx-basic.yaml
name: nginx-basic

services:
  web:
    image: docker.io/nginx:alpine
    container_name: cr380-podman-nginx
    ports:
      - "8081:80"
    restart: unless-stopped
```

## Cycle de vie

```bash
# 1. Démarrer en arrière-plan
podman-compose -f compose-files/nginx-basic.yaml up -d

# 2. Voir l'état des services
podman-compose -f compose-files/nginx-basic.yaml ps

# 3. Voir les logs
podman-compose -f compose-files/nginx-basic.yaml logs

# 4. Tester
curl http://localhost:8081

# 5. Arrêter et supprimer
podman-compose -f compose-files/nginx-basic.yaml down
```

## Structure d'un fichier Compose

```yaml
name: mon-projet           # Nom du projet (évite les conflits)

services:
  nom-service:             # Nom du service
    image: ...             # Image à utiliser
    container_name: ...    # Nom du conteneur
    ports:
      - "hôte:conteneur"   # Mapping de ports
    volumes:
      - vol:/chemin        # Volumes
    environment:
      - CLE=valeur         # Variables d'environnement
    depends_on:
      - autre-service      # Dépendances entre services
    restart: unless-stopped

volumes:
  vol:                     # Volume nommé
```

## Différences clés avec Docker Compose

| Aspect | Docker Compose | Podman Compose |
|--------|----------------|----------------|
| Commande | `docker compose` | `podman-compose` |
| Format YAML | Compose Spec | Compose Spec (identique) |
| Installation | Inclus avec Docker | Séparé (`pip3 install`) |
| Réseau | Bridge auto | Bridge auto |
| Daemon | Requis | Non requis |

## Test automatisé

```bash
./run-labs.sh --learn --lab 08
```

{% endtab %}
{% tab title="English" %}

## Objective

Learn to use `podman-compose` to manage multi-container applications.

{% hint style="info" %}
**Podman Compose vs Docker Compose**

`podman-compose` uses exactly the **same YAML file format** as Docker Compose (Compose Spec). The files are interchangeable! Only the command changes: `docker compose` → `podman-compose`.
{% endhint %}

## Installation

```bash
# Option 1: via APT
sudo apt-get install -y podman-compose

# Option 2: via pip3
pip3 install podman-compose

# Verify
podman-compose --version
```

## Basic Compose file

```yaml
# compose-files/nginx-basic.yaml
name: nginx-basic

services:
  web:
    image: docker.io/nginx:alpine
    container_name: cr380-podman-nginx
    ports:
      - "8081:80"
    restart: unless-stopped
```

## Lifecycle

```bash
# 1. Start in background
podman-compose -f compose-files/nginx-basic.yaml up -d

# 2. View service status
podman-compose -f compose-files/nginx-basic.yaml ps

# 3. View logs
podman-compose -f compose-files/nginx-basic.yaml logs

# 4. Test
curl http://localhost:8081

# 5. Stop and remove
podman-compose -f compose-files/nginx-basic.yaml down
```

## Compose file structure

```yaml
name: my-project           # Project name (avoids conflicts)

services:
  service-name:            # Service name
    image: ...             # Image to use
    container_name: ...    # Container name
    ports:
      - "host:container"   # Port mapping
    volumes:
      - vol:/path          # Volumes
    environment:
      - KEY=value          # Environment variables
    depends_on:
      - other-service      # Service dependencies
    restart: unless-stopped

volumes:
  vol:                     # Named volume
```

## Key differences from Docker Compose

| Aspect | Docker Compose | Podman Compose |
|--------|----------------|----------------|
| Command | `docker compose` | `podman-compose` |
| YAML format | Compose Spec | Compose Spec (identical) |
| Installation | Included with Docker | Separate (`pip3 install`) |
| Network | Auto bridge | Auto bridge |
| Daemon | Required | Not required |

## Automated test

```bash
./run-labs.sh --learn --lab 08
```

{% endtab %}
{% endtabs %}
