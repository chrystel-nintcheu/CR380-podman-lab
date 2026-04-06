---
description: >-
  Découvrir les Pods — fonctionnalité unique à Podman /
  Discover Pods — feature unique to Podman
---

# Lab 07 — Pods

{% tabs %}
{% tab title="Français" %}

## Objectif

Comprendre et utiliser les Pods, une fonctionnalité de Podman absente de Docker.

{% hint style="info" %}
**Pods et Kubernetes**

Les Pods Podman utilisent exactement le même concept que les Pods Kubernetes. Un pod = un groupe de conteneurs partageant le même namespace réseau, IPC, et optionnellement PID. Podman peut même **générer des fichiers YAML Kubernetes** depuis vos pods locaux!
{% endhint %}

## Qu'est-ce qu'un Pod ?

```
┌──────────────── Pod "mypod" ────────────────┐
│  Port 8082:80                                 │
│  ┌──────────────┐    ┌──────────────────┐    │
│  │  Nginx       │    │  Alpine          │    │
│  │  (web server)│    │  (client)        │    │
│  │  port :80    │    │  curl localhost  │    │
│  └──────────────┘    └──────────────────┘    │
│         ↑ partagent le même réseau ↑          │
└──────────────────────────────────────────────┘
```

## Étapes

### 1. Créer un pod

```bash
podman pod create --name mypod -p 8082:80
```

> Le port est défini au niveau du **pod**, pas du conteneur.

### 2. Ajouter des conteneurs au pod

```bash
# Ajouter Nginx au pod
podman run -d --pod mypod --name pod-nginx docker.io/nginx:latest
```

### 3. Lister les pods

```bash
podman pod ps
```

### 4. Tester la communication interne

```bash
# Alpine accède à Nginx via localhost (même namespace réseau)
podman run --rm --pod mypod docker.io/alpine:latest \
    wget -q -O - http://localhost:80
```

### 5. Bonus — Générer du YAML Kubernetes

```bash
podman generate kube mypod > mypod.yaml
cat mypod.yaml
```

### 6. Supprimer le pod

```bash
# Supprime le pod ET tous ses conteneurs
podman pod rm -f mypod
```

## Commandes Pod

| Commande | Description |
|----------|-------------|
| `podman pod create` | Créer un pod |
| `podman pod ps` | Lister les pods |
| `podman pod start` | Démarrer un pod |
| `podman pod stop` | Arrêter un pod |
| `podman pod rm` | Supprimer un pod |
| `podman pod inspect` | Inspecter un pod |
| `podman generate kube` | Générer YAML Kubernetes |

## Test automatisé

```bash
./run-labs.sh --learn --lab 07
```

{% endtab %}
{% tab title="English" %}

## Objective

Understand and use Pods, a Podman feature not found in Docker.

{% hint style="info" %}
**Pods and Kubernetes**

Podman Pods use exactly the same concept as Kubernetes Pods. A pod = a group of containers sharing the same network, IPC, and optionally PID namespace. Podman can even **generate Kubernetes YAML files** from your local pods!
{% endhint %}

## What is a Pod?

```
┌──────────────── Pod "mypod" ────────────────┐
│  Port 8082:80                                 │
│  ┌──────────────┐    ┌──────────────────┐    │
│  │  Nginx       │    │  Alpine          │    │
│  │  (web server)│    │  (client)        │    │
│  │  port :80    │    │  curl localhost  │    │
│  └──────────────┘    └──────────────────┘    │
│         ↑ share the same network ↑            │
└──────────────────────────────────────────────┘
```

## Steps

### 1. Create a pod

```bash
podman pod create --name mypod -p 8082:80
```

> The port is defined at the **pod** level, not the container.

### 2. Add containers to the pod

```bash
# Add Nginx to the pod
podman run -d --pod mypod --name pod-nginx docker.io/nginx:latest
```

### 3. List pods

```bash
podman pod ps
```

### 4. Test internal communication

```bash
# Alpine accesses Nginx via localhost (same network namespace)
podman run --rm --pod mypod docker.io/alpine:latest \
    wget -q -O - http://localhost:80
```

### 5. Bonus — Generate Kubernetes YAML

```bash
podman generate kube mypod > mypod.yaml
cat mypod.yaml
```

### 6. Remove the pod

```bash
# Removes the pod AND all its containers
podman pod rm -f mypod
```

## Pod commands

| Command | Description |
|---------|-------------|
| `podman pod create` | Create a pod |
| `podman pod ps` | List pods |
| `podman pod start` | Start a pod |
| `podman pod stop` | Stop a pod |
| `podman pod rm` | Remove a pod |
| `podman pod inspect` | Inspect a pod |
| `podman generate kube` | Generate Kubernetes YAML |

## Automated test

```bash
./run-labs.sh --learn --lab 07
```

{% endtab %}
{% endtabs %}
