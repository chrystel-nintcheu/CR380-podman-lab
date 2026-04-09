---
description: >-
  Persister les données avec des volumes Podman /
  Persist data with Podman volumes
---

# Lab 06 — Volumes & Persistance / Volumes & Persistence

{% tabs %}
{% tab title="Français" %}

## Avant de commencer

**Prérequis** : Lab 05 doit être validé (construction d'images).

**Glossaire**
| Terme | Définition |
|-------|------------|
| Volume nommé | Espace de stockage géré par Podman, indépendant des conteneurs |
| Bind mount | Montage direct d'un dossier de l'hôte dans le conteneur |
| tmpfs | Volume en mémoire (RAM), perdu au redémarrage |
| Mountpoint | Chemin réel sur l'hôte où le volume est stocké |
| SELinux z/Z | Options de relabeling pour SELinux (RHEL/Fedora) |

📖 **Documentation officielle** :
- [podman-volume-create(1)](https://docs.podman.io/en/latest/markdown/podman-volume-create.1.html)
- [podman-run -v](https://docs.podman.io/en/latest/markdown/podman-run.1.html#volume)

## Objectif

Apprendre à persister les données au-delà du cycle de vie des conteneurs avec les volumes Podman.

{% hint style="warning" %}
**Données éphémères**

Par défaut, toutes les données écrites dans un conteneur sont **perdues** quand le conteneur est supprimé. Les volumes et bind mounts permettent de résoudre ce problème.
{% endhint %}

## Types de stockage persistant

| Type | Description | Cas d'usage |
|------|-------------|-------------|
| **Volume nommé** | Géré par Podman | Données de base de données, logs |
| **Bind mount** | Dossier hôte monté | Code source, config |
| **Volume tmpfs** | En mémoire | Données temporaires sensibles |

## Étapes

### 1. Créer un volume nommé

```bash
podman volume create podman_data
```

### 2. Inspecter le volume

```bash
podman volume inspect podman_data
```

### 3. Lister les volumes

```bash
podman volume ls
```

### 4. Écrire des données via un conteneur

```bash
podman run --rm \
    -v podman_data:/data \
    docker.io/alpine:latest \
    sh -c 'echo "Hello Podman Volume" > /data/test.txt'
```

### 5. Lire les données depuis un autre conteneur

```bash
podman run --rm \
    -v podman_data:/data \
    docker.io/alpine:latest \
    cat /data/test.txt
# Affiche: Hello Podman Volume
```

### 6. Bind mount (dossier hôte)

```bash
# Monter /tmp en lecture seule dans le conteneur
podman run --rm \
    -v /tmp:/mnt/host:ro \
    docker.io/alpine:latest \
    ls /mnt/host
```

### 7. Supprimer un volume

```bash
podman volume rm podman_data
```

## Syntaxe des volumes

```
-v <source>:<destination>[:<options>]
```

| Option | Signification |
|--------|---------------|
| `ro` | Lecture seule / Read-only |
| `rw` | Lecture-écriture (défaut) |
| `z` | Relabel SELinux (partagé) |
| `Z` | Relabel SELinux (privé) |

## Test automatisé

```bash
./run-labs.sh --learn --lab 06
```

## Dépannage

| Symptôme | Cause | Solution |
|----------|-------|----------|
| `Error: volume already exists` | Volume du même nom existant | `podman volume rm podman_data` puis recréer |
| `Permission denied` dans le conteneur | Problème de permissions UID | Ajoutez `:Z` au montage ou utilisez `--userns=keep-id` |
| Données perdues après `podman rm` | Données dans le conteneur, pas le volume | Assurez-vous que `-v volume:/path` est bien spécifié |
| Bind mount vide dans le conteneur | Chemin hôte inexistant | Vérifiez que le chemin source existe avec `ls -la` |
| `Error: volume in use` lors de rm | Volume utilisé par un conteneur | `podman rm -f <conteneur>` d'abord |

{% endtab %}
{% tab title="English" %}

## Before You Start

**Prerequisites**: Lab 05 must pass (image building).

**Glossary**
| Term | Definition |
|------|------------|
| Named volume | Storage space managed by Podman, independent from containers |
| Bind mount | Direct mounting of a host folder into the container |
| tmpfs | In-memory volume (RAM), lost on restart |
| Mountpoint | Actual path on host where volume is stored |
| SELinux z/Z | Relabeling options for SELinux (RHEL/Fedora) |

📖 **Official docs**:
- [podman-volume-create(1)](https://docs.podman.io/en/latest/markdown/podman-volume-create.1.html)
- [podman-run -v](https://docs.podman.io/en/latest/markdown/podman-run.1.html#volume)

## Objective

Learn to persist data beyond container lifecycle with Podman volumes.

{% hint style="warning" %}
**Ephemeral data**

By default, all data written to a container is **lost** when the container is removed. Volumes and bind mounts solve this problem.
{% endhint %}

## Types of persistent storage

| Type | Description | Use case |
|------|-------------|----------|
| **Named volume** | Managed by Podman | Database data, logs |
| **Bind mount** | Host folder mounted | Source code, config |
| **tmpfs volume** | In memory | Sensitive temporary data |

## Steps

### 1. Create a named volume

```bash
podman volume create podman_data
```

### 2. Inspect the volume

```bash
podman volume inspect podman_data
```

### 3. List volumes

```bash
podman volume ls
```

### 4. Write data via a container

```bash
podman run --rm \
    -v podman_data:/data \
    docker.io/alpine:latest \
    sh -c 'echo "Hello Podman Volume" > /data/test.txt'
```

### 5. Read data from another container

```bash
podman run --rm \
    -v podman_data:/data \
    docker.io/alpine:latest \
    cat /data/test.txt
# Outputs: Hello Podman Volume
```

### 6. Bind mount (host folder)

```bash
# Mount /tmp as read-only in container
podman run --rm \
    -v /tmp:/mnt/host:ro \
    docker.io/alpine:latest \
    ls /mnt/host
```

### 7. Remove a volume

```bash
podman volume rm podman_data
```

## Volume syntax

```
-v <source>:<destination>[:<options>]
```

| Option | Meaning |
|--------|---------|
| `ro` | Read-only |
| `rw` | Read-write (default) |
| `z` | SELinux relabel (shared) |
| `Z` | SELinux relabel (private) |

## Automated test

```bash
./run-labs.sh --learn --lab 06
```

## Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| `Error: volume already exists` | Volume with same name exists | `podman volume rm podman_data` then recreate |
| `Permission denied` inside container | UID permissions issue | Add `:Z` to mount or use `--userns=keep-id` |
| Data lost after `podman rm` | Data was in container, not volume | Ensure `-v volume:/path` is specified |
| Bind mount empty in container | Host path doesn't exist | Check source path exists with `ls -la` |
| `Error: volume in use` on rm | Volume used by a container | `podman rm -f <container>` first |

{% endtab %}
{% endtabs %}
