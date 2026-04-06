---
description: >-
  Persister les données avec des volumes Podman /
  Persist data with Podman volumes
---

# Lab 06 — Volumes & Persistance / Volumes & Persistence

{% tabs %}
{% tab title="Français" %}

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

{% endtab %}
{% tab title="English" %}

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

{% endtab %}
{% endtabs %}
