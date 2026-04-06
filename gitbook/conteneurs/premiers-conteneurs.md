---
description: >-
  Gérer les conteneurs Podman : run, exec, stop, rm /
  Manage Podman containers: run, exec, stop, rm
---

# Lab 03 — Premiers conteneurs / First Containers

{% tabs %}
{% tab title="Français" %}

## Objectif

Apprendre les commandes de base pour créer, gérer et supprimer des conteneurs Podman.

## Commandes essentielles

| Commande | Description |
|----------|-------------|
| `podman run` | Créer et démarrer un conteneur |
| `podman ps` | Lister les conteneurs en cours |
| `podman ps -a` | Lister tous les conteneurs |
| `podman exec` | Exécuter une commande dans un conteneur |
| `podman stop` | Arrêter un conteneur |
| `podman rm` | Supprimer un conteneur |
| `podman logs` | Voir les logs d'un conteneur |

## Étapes

### 1. Conteneur interactif Alpine

```bash
# Créer un conteneur Alpine en arrière-plan
podman run -dit --name alpineCT docker.io/alpine:latest

# Exécuter une commande dans le conteneur
podman exec alpineCT cat /etc/os-release

# Lister les conteneurs
podman ps

# Arrêter et supprimer
podman stop alpineCT
podman rm alpineCT
```

### 2. Conteneur Nginx avec mapping de port

```bash
# Lancer Nginx sur le port 8080
podman run -d --name nginxCT -p 8080:80 docker.io/nginx:latest

# Attendre quelques secondes puis tester
sleep 2
curl http://localhost:8080

# Voir les logs
podman logs nginxCT

# Nettoyage
podman stop nginxCT
podman rm nginxCT
```

{% hint style="warning" %}
**Rootless et ports privilégiés**

En mode rootless, Podman ne peut mapper que les ports ≥ 1024 par défaut. Pour utiliser les ports 80 ou 443, utilisez `sysctl net.ipv4.ip_unprivileged_port_start=80` ou lancez le conteneur en mode root.
{% endhint %}

## Drapeaux importants de `podman run`

| Drapeau | Signification |
|---------|---------------|
| `-d` | Détaché (arrière-plan) |
| `-i` | Interactif (STDIN ouvert) |
| `-t` | Pseudo-terminal |
| `-p hôte:conteneur` | Mapping de port |
| `--name` | Nom du conteneur |
| `--rm` | Supprimer automatiquement après arrêt |

## Test automatisé

```bash
./run-labs.sh --learn --lab 03
```

{% endtab %}
{% tab title="English" %}

## Objective

Learn the basic commands to create, manage and delete Podman containers.

## Essential commands

| Command | Description |
|---------|-------------|
| `podman run` | Create and start a container |
| `podman ps` | List running containers |
| `podman ps -a` | List all containers |
| `podman exec` | Run a command inside a container |
| `podman stop` | Stop a container |
| `podman rm` | Remove a container |
| `podman logs` | View container logs |

## Steps

### 1. Interactive Alpine container

```bash
# Create an Alpine container in the background
podman run -dit --name alpineCT docker.io/alpine:latest

# Run a command inside the container
podman exec alpineCT cat /etc/os-release

# List containers
podman ps

# Stop and remove
podman stop alpineCT
podman rm alpineCT
```

### 2. Nginx container with port mapping

```bash
# Run Nginx on port 8080
podman run -d --name nginxCT -p 8080:80 docker.io/nginx:latest

# Wait a few seconds then test
sleep 2
curl http://localhost:8080

# View logs
podman logs nginxCT

# Cleanup
podman stop nginxCT
podman rm nginxCT
```

{% hint style="warning" %}
**Rootless and privileged ports**

In rootless mode, Podman can only map ports ≥ 1024 by default. To use ports 80 or 443, use `sysctl net.ipv4.ip_unprivileged_port_start=80` or run the container as root.
{% endhint %}

## Important `podman run` flags

| Flag | Meaning |
|------|---------|
| `-d` | Detached (background) |
| `-i` | Interactive (STDIN open) |
| `-t` | Pseudo-terminal |
| `-p host:container` | Port mapping |
| `--name` | Container name |
| `--rm` | Auto-remove after stop |

## Automated test

```bash
./run-labs.sh --learn --lab 03
```

{% endtab %}
{% endtabs %}
