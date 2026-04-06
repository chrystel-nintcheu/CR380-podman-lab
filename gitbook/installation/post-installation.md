---
description: >-
  Configurer et vérifier Podman après installation /
  Configure and verify Podman after installation
---

# Lab 02 — Après installation / Post-Installation

{% tabs %}
{% tab title="Français" %}

## Objectif

Vérifier que Podman fonctionne correctement et comprendre la configuration par défaut (mode rootless).

## Différence clé : Podman est rootless par défaut

Contrairement à Docker qui nécessite un démon root (`dockerd`), Podman fonctionne **sans démon** et en **mode rootless** par défaut. Les conteneurs tournent avec les permissions de l'utilisateur courant.

```bash
# Docker nécessitait ceci:
sudo usermod -aG docker $USER   # ← PAS nécessaire avec Podman

# Podman fonctionne directement sans sudo:
podman run hello-world          # ← Fonctionne sans sudo!
```

## Étapes

### 1. Vérifier l'installation

```bash
podman --version
which podman
```

### 2. Afficher les informations système

```bash
podman version
podman info
```

> 🔍 Notez le champ `rootless: true` dans `podman info` — c'est la grande différence avec Docker!

### 3. Lancer le conteneur de test

```bash
podman run quay.io/podman/hello
```

### 4. Vérifier les registres configurés

```bash
cat /etc/containers/registries.conf
```

> 📋 Ce fichier liste les registres où Podman cherche les images. Par défaut: `docker.io` et `quay.io`.

## Vérification

```bash
podman --version    # Affiche la version
podman info         # Infos système
podman run --rm quay.io/podman/hello  # Test fonctionnel
```

## Test automatisé

```bash
./run-labs.sh --learn --lab 02
```

{% endtab %}
{% tab title="English" %}

## Objective

Verify Podman is working correctly and understand the default configuration (rootless mode).

## Key difference: Podman is rootless by default

Unlike Docker which requires a root daemon (`dockerd`), Podman works **without a daemon** and in **rootless mode** by default. Containers run with the current user's permissions.

```bash
# Docker required this:
sudo usermod -aG docker $USER   # ← NOT needed with Podman

# Podman works directly without sudo:
podman run hello-world          # ← Works without sudo!
```

## Steps

### 1. Verify installation

```bash
podman --version
which podman
```

### 2. Display system information

```bash
podman version
podman info
```

> 🔍 Note the `rootless: true` field in `podman info` — this is the big difference from Docker!

### 3. Run the test container

```bash
podman run quay.io/podman/hello
```

### 4. Check configured registries

```bash
cat /etc/containers/registries.conf
```

> 📋 This file lists the registries where Podman looks for images. Default: `docker.io` and `quay.io`.

## Verification

```bash
podman --version    # Shows version
podman info         # System info
podman run --rm quay.io/podman/hello  # Functional test
```

## Automated test

```bash
./run-labs.sh --learn --lab 02
```

{% endtab %}
{% endtabs %}
