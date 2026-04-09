---
description: >-
  Orchestrer plusieurs conteneurs avec Podman Compose /
  Orchestrate multiple containers with Podman Compose
---

# Lab 08 — Podman Compose

{% tabs %}
{% tab title="Français" %}

## Avant de commencer

**Prérequis** : Lab 07 doit être validé (pods).

**Glossaire**
| Terme | Définition |
|-------|------------|
| Compose Spec | Standard ouvert définissant le format YAML multi-conteneurs |
| Service | Un conteneur défini dans le fichier Compose |
| Projet (project) | Ensemble de services regroupés (clé `name:` dans le YAML) |
| depends_on | Déclaration d'ordre de démarrage entre services |
| restart policy | Politique de redémarrage automatique (unless-stopped, always) |

📖 **Documentation officielle** :
- [podman-compose](https://github.com/containers/podman-compose)
- [Compose Spec](https://compose-spec.io/)

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
export PATH="$HOME/.local/bin:$PATH"

# Vérification
podman-compose --version
```

{% hint style="warning" %}
**pip3** installe les binaires dans `~/.local/bin`. Si `podman-compose` n'est pas trouvé, ajoutez dans votre `~/.bashrc` :
```bash
export PATH="$HOME/.local/bin:$PATH"
```
{% endhint %}

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

## Dépannage

| Symptôme | Cause | Solution |
|----------|-------|----------|
| `podman-compose: command not found` | Non installé ou pas dans PATH | `pip3 install podman-compose` puis `export PATH="$HOME/.local/bin:$PATH"` |
| `Error: name already in use` | Conteneur d'une exécution précédente | `podman-compose -f <fichier> down` puis relancer |
| Port 8081 déjà utilisé | Autre service sur le même port | `ss -tlnp \| grep 8081` puis arrêter le service |
| `Error: pull access denied` | Image introuvable ou registre bloqué | Vérifiez le nom complet de l'image dans le YAML (préfixe docker.io/) |
| `podman-compose down` ne supprime pas les volumes | Comportement normal | Ajoutez `--volumes` pour supprimer les volumes nommés |

{% endtab %}
{% tab title="English" %}

## Before You Start

**Prerequisites**: Lab 07 must pass (pods).

**Glossary**
| Term | Definition |
|------|------------|
| Compose Spec | Open standard defining the multi-container YAML format |
| Service | A container defined in the Compose file |
| Project | Group of services (set by `name:` key in YAML) |
| depends_on | Startup order declaration between services |
| restart policy | Auto-restart policy (unless-stopped, always) |

📖 **Official docs**:
- [podman-compose](https://github.com/containers/podman-compose)
- [Compose Spec](https://compose-spec.io/)

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
export PATH="$HOME/.local/bin:$PATH"

# Verify
podman-compose --version
```

{% hint style="warning" %}
**pip3** installs binaries to `~/.local/bin`. If `podman-compose` is not found, add to your `~/.bashrc`:
```bash
export PATH="$HOME/.local/bin:$PATH"
```
{% endhint %}

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

## Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| `podman-compose: command not found` | Not installed or not in PATH | `pip3 install podman-compose` then `export PATH="$HOME/.local/bin:$PATH"` |
| `Error: name already in use` | Container from previous run | `podman-compose -f <file> down` then restart |
| Port 8081 already in use | Another service on same port | `ss -tlnp \| grep 8081` then stop that service |
| `Error: pull access denied` | Image not found or registry blocked | Check full image name in YAML (add docker.io/ prefix) |
| `podman-compose down` doesn't remove volumes | Normal behavior | Add `--volumes` to also remove named volumes |

{% endtab %}
{% endtabs %}
