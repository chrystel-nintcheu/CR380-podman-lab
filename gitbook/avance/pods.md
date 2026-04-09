---
description: >-
  Découvrir les Pods — fonctionnalité unique à Podman /
  Discover Pods — feature unique to Podman
---

# Lab 07 — Pods

{% tabs %}
{% tab title="Français" %}

## Avant de commencer

**Prérequis** : Lab 06 doit être validé (volumes et persistance).

**Glossaire**
| Terme | Définition |
|-------|------------|
| Pod | Groupe de conteneurs partageant le même namespace réseau |
| Infra container | Conteneur invisible qui maintient les namespaces du pod |
| Namespace réseau | Isolation réseau — les conteneurs du pod partagent localhost |
| Namespace IPC | Isolation de la mémoire partagée entre processus |
| `podman generate kube` | Génère du YAML Kubernetes depuis un pod local |

📖 **Documentation officielle** :
- [podman-pod-create(1)](https://docs.podman.io/en/latest/markdown/podman-pod-create.1.html)
- [podman-pod-ps(1)](https://docs.podman.io/en/latest/markdown/podman-pod-ps.1.html)
- [podman-generate-kube(1)](https://docs.podman.io/en/latest/markdown/podman-generate-kube.1.html)

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

## Dépannage

| Symptôme | Cause | Solution |
|----------|-------|----------|
| `Error: pod already exists` | Pod du même nom existant | `podman pod rm -f mypod` puis recréer |
| `Error: address already in use` sur le port | Port 8082 déjà pris | `ss -tlnp \| grep 8082` puis libérer |
| `-p` sur `podman run --pod` échoue | Port mapping au mauvais niveau | Le port doit être sur `podman pod create -p`, pas sur `podman run` |
| `wget: error getting response` | Nginx pas encore démarré | Attendre 2-3s ou `podman logs pod-nginx` |
| `podman generate kube` retourne une erreur | Version Podman ancienne | Essayez `podman kube generate mypod` (syntaxe Podman 4.x+) |

{% endtab %}
{% tab title="English" %}

## Before You Start

**Prerequisites**: Lab 06 must pass (volumes and persistence).

**Glossary**
| Term | Definition |
|------|------------|
| Pod | Group of containers sharing the same network namespace |
| Infra container | Invisible container that holds the pod's shared namespaces |
| Network namespace | Network isolation — pod containers share localhost |
| IPC namespace | Shared memory isolation between processes |
| `podman generate kube` | Generates Kubernetes YAML from a local pod |

📖 **Official docs**:
- [podman-pod-create(1)](https://docs.podman.io/en/latest/markdown/podman-pod-create.1.html)
- [podman-pod-ps(1)](https://docs.podman.io/en/latest/markdown/podman-pod-ps.1.html)
- [podman-generate-kube(1)](https://docs.podman.io/en/latest/markdown/podman-generate-kube.1.html)

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

## Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| `Error: pod already exists` | Pod with same name exists | `podman pod rm -f mypod` then recreate |
| `Error: address already in use` on port | Port 8082 already taken | `ss -tlnp \| grep 8082` then free it |
| `-p` on `podman run --pod` fails | Port mapping at wrong level | Port must be on `podman pod create -p`, not `podman run` |
| `wget: error getting response` | Nginx not started yet | Wait 2-3s or check `podman logs pod-nginx` |
| `podman generate kube` returns error | Old Podman version | Try `podman kube generate mypod` (Podman 4.x+ syntax) |

{% endtab %}
{% endtabs %}
