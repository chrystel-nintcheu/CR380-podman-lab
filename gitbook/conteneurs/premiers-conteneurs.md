---
description: >-
  Gérer les conteneurs Podman : run, exec, stop, rm /
  Manage Podman containers: run, exec, stop, rm
---

# Lab 03 — Premiers conteneurs / First Containers

{% tabs %}
{% tab title="Français" %}

## Avant de commencer

**Prérequis** : Lab 02 doit être validé (Podman configuré et fonctionnel).

**Glossaire**
| Terme | Définition |
|-------|------------|
| Conteneur | Instance en cours d'exécution d'une image |
| Image | Modèle en lecture seule pour créer des conteneurs |
| Détaché (-d) | Le conteneur tourne en arrière-plan |
| Mapping de port | Redirection d'un port hôte vers un port conteneur |
| STDIN | Entrée standard (nécessaire pour le mode interactif) |

📖 **Documentation officielle** :
- [podman-run(1)](https://docs.podman.io/en/latest/markdown/podman-run.1.html)
- [podman-exec(1)](https://docs.podman.io/en/latest/markdown/podman-exec.1.html)
- [podman-ps(1)](https://docs.podman.io/en/latest/markdown/podman-ps.1.html)
- [podman-stop(1)](https://docs.podman.io/en/latest/markdown/podman-stop.1.html)
- [podman-rm(1)](https://docs.podman.io/en/latest/markdown/podman-rm.1.html)

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

## Dépannage

| Symptôme | Cause | Solution |
|----------|-------|----------|
| `Error: address already in use` | Port 8080 déjà utilisé | `ss -tlnp \| grep 8080` pour identifier, puis arrêter le service |
| `Error: container name already in use` | Conteneur du même nom existe | `podman rm -f alpineCT` puis réessayer |
| `curl: (7) Failed to connect` | Conteneur pas encore prêt | Attendez 2-3 secondes ou `podman logs nginxCT` |
| Terminal bloqué après `podman run` | Oubli du flag `-d` (détaché) | Ctrl+C puis relancer avec `-d` |
| `podman exec` retourne erreur | Conteneur arrêté | `podman start alpineCT` puis réessayer |

{% endtab %}
{% tab title="English" %}

## Before You Start

**Prerequisites**: Lab 02 must pass (Podman configured and functional).

**Glossary**
| Term | Definition |
|------|------------|
| Container | Running instance of an image |
| Image | Read-only template to create containers |
| Detached (-d) | Container runs in the background |
| Port mapping | Forwarding a host port to a container port |
| STDIN | Standard input (needed for interactive mode) |

📖 **Official docs**:
- [podman-run(1)](https://docs.podman.io/en/latest/markdown/podman-run.1.html)
- [podman-exec(1)](https://docs.podman.io/en/latest/markdown/podman-exec.1.html)
- [podman-ps(1)](https://docs.podman.io/en/latest/markdown/podman-ps.1.html)
- [podman-stop(1)](https://docs.podman.io/en/latest/markdown/podman-stop.1.html)
- [podman-rm(1)](https://docs.podman.io/en/latest/markdown/podman-rm.1.html)

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

## Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| `Error: address already in use` | Port 8080 already taken | `ss -tlnp \| grep 8080` to identify, then stop that service |
| `Error: container name already in use` | Container with same name exists | `podman rm -f alpineCT` then retry |
| `curl: (7) Failed to connect` | Container not ready yet | Wait 2-3 seconds or check `podman logs nginxCT` |
| Terminal hangs after `podman run` | Missing `-d` (detach) flag | Ctrl+C then rerun with `-d` |
| `podman exec` returns error | Container is stopped | `podman start alpineCT` then retry |

{% endtab %}
{% endtabs %}
