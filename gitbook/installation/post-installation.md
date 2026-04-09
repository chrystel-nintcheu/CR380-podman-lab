---
description: >-
  Configurer et vérifier Podman après installation /
  Configure and verify Podman after installation
---

# Lab 02 — Après installation / Post-Installation

{% tabs %}
{% tab title="Français" %}

## Avant de commencer

**Prérequis** : Lab 01 doit être validé (Podman installé via APT).

**Glossaire**
| Terme | Définition |
|-------|------------|
| Rootless | Exécution de conteneurs sans privilèges root |
| Daemon | Processus serveur permanent (Docker en a un, Podman non) |
| Registre | Serveur d'images de conteneurs (docker.io, quay.io) |
| User namespace | Isolation des UIDs entre l'hôte et le conteneur |

📖 **Documentation officielle** :
- [podman-info(1)](https://docs.podman.io/en/latest/markdown/podman-info.1.html)
- [podman-run(1)](https://docs.podman.io/en/latest/markdown/podman-run.1.html)
- [Mode rootless](https://docs.podman.io/en/latest/markdown/podman.1.html#rootless-mode)

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

## Dépannage

| Symptôme | Cause | Solution |
|----------|-------|----------|
| `ERRO[0000] cannot find mappings for user` | subuid/subgid non configuré | `sudo usermod --add-subuids 100000-165535 $USER` |
| `podman run` timeout sur quay.io | Réseau lent ou registre bloqué | Essayez `podman run docker.io/alpine echo hello` |
| `rootless: false` dans podman info | Podman exécuté avec sudo | Relancez sans sudo : `podman info` |
| `registries.conf not found` | Config par défaut utilisée | Normal — Podman utilise docker.io et quay.io par défaut |
| `WARN: image platform does not match` | Architecture différente | Spécifiez `--arch amd64` si sur ARM |

{% endtab %}
{% tab title="English" %}

## Before You Start

**Prerequisites**: Lab 01 must pass (Podman installed via APT).

**Glossary**
| Term | Definition |
|------|------------|
| Rootless | Running containers without root privileges |
| Daemon | Persistent server process (Docker has one, Podman doesn't) |
| Registry | Container image server (docker.io, quay.io) |
| User namespace | UID isolation between host and container |

📖 **Official docs**:
- [podman-info(1)](https://docs.podman.io/en/latest/markdown/podman-info.1.html)
- [podman-run(1)](https://docs.podman.io/en/latest/markdown/podman-run.1.html)
- [Rootless mode](https://docs.podman.io/en/latest/markdown/podman.1.html#rootless-mode)

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

## Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| `ERRO[0000] cannot find mappings for user` | subuid/subgid not configured | `sudo usermod --add-subuids 100000-165535 $USER` |
| `podman run` timeout on quay.io | Slow network or blocked registry | Try `podman run docker.io/alpine echo hello` |
| `rootless: false` in podman info | Podman run with sudo | Re-run without sudo: `podman info` |
| `registries.conf not found` | Default config used | Normal — Podman uses docker.io and quay.io by default |
| `WARN: image platform does not match` | Architecture mismatch | Specify `--arch amd64` if on ARM |

{% endtab %}
{% endtabs %}
