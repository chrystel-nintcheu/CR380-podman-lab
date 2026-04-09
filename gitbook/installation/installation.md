---
description: >-
  Installer Podman sur Ubuntu via APT /
  Install Podman on Ubuntu via APT
---

# Lab 01 — Installation de Podman / Podman Installation

{% tabs %}
{% tab title="Français" %}

## Avant de commencer

**Prérequis** : Lab 00 doit être validé (OS Ubuntu, Internet, espace disque, outils).

**Glossaire**
| Terme | Définition |
|-------|------------|
| APT | Gestionnaire de paquets Ubuntu/Debian |
| Daemonless | Podman n'a pas de processus serveur permanent (contrairement à Docker) |
| pip3 | Gestionnaire de paquets Python |

📖 **Documentation officielle** : [Installation Podman](https://docs.podman.io/en/latest/installation.html)

## Objectif

Installer Podman sur Ubuntu en utilisant le gestionnaire de paquets APT.

{% hint style="info" %}
Podman est disponible dans les dépôts officiels Ubuntu 22.04+. Aucun dépôt tiers n'est nécessaire.
{% endhint %}

## Étapes

### 1. Mettre à jour la liste des paquets

```bash
sudo apt-get update
```

### 2. Installer Podman

```bash
sudo apt-get install -y podman
```

### 3. Installer Podman Compose (pour les labs 08+)

```bash
# Option 1: via APT (si disponible)
sudo apt-get install -y podman-compose

# Option 2: via pip3
sudo apt-get install -y python3-pip
pip3 install podman-compose
```

### 4. Vérifier l'installation

```bash
podman --version
podman-compose --version
```

## Qu'est-ce qui est installé ?

| Composant | Description |
|-----------|-------------|
| `podman` | Le moteur de conteneurs |
| `podman-compose` | L'orchestrateur multi-conteneurs |
| `containers-common` | Configurations et registres par défaut |

## Test automatisé

```bash
./run-labs.sh --learn --lab 01
```

## Dépannage

| Symptôme | Cause | Solution |
|----------|-------|----------|
| `E: Unable to locate package podman` | APT cache obsolète | `sudo apt-get update` puis réessayer |
| `pip3: command not found` | python3-pip non installé | `sudo apt-get install -y python3-pip` |
| `podman-compose: command not found` après pip3 | ~/.local/bin pas dans PATH | `export PATH="$HOME/.local/bin:$PATH"` (ajouter dans ~/.bashrc) |
| `dpkg: error processing package podman` | Installation corrompue | `sudo dpkg --configure -a && sudo apt-get install -f` |
| Timeout pendant l'installation | Réseau lent ou miroir surchargé | Réessayer ou changer le miroir APT |

{% endtab %}
{% tab title="English" %}

## Before You Start

**Prerequisites**: Lab 00 must pass (Ubuntu OS, Internet, disk space, tools).

**Glossary**
| Term | Definition |
|------|------------|
| APT | Ubuntu/Debian package manager |
| Daemonless | Podman has no persistent server process (unlike Docker) |
| pip3 | Python package manager |

📖 **Official docs**: [Podman Installation](https://docs.podman.io/en/latest/installation.html)

## Objective

Install Podman on Ubuntu using the APT package manager.

{% hint style="info" %}
Podman is available in the official Ubuntu 22.04+ repositories. No third-party repository is needed.
{% endhint %}

## Steps

### 1. Update package list

```bash
sudo apt-get update
```

### 2. Install Podman

```bash
sudo apt-get install -y podman
```

### 3. Install Podman Compose (for labs 08+)

```bash
# Option 1: via APT (if available)
sudo apt-get install -y podman-compose

# Option 2: via pip3
sudo apt-get install -y python3-pip
pip3 install podman-compose
```

### 4. Verify installation

```bash
podman --version
podman-compose --version
```

## What gets installed?

| Component | Description |
|-----------|-------------|
| `podman` | The container engine |
| `podman-compose` | Multi-container orchestrator |
| `containers-common` | Default configurations and registries |

## Automated test

```bash
./run-labs.sh --learn --lab 01
```

## Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| `E: Unable to locate package podman` | Stale APT cache | `sudo apt-get update` then retry |
| `pip3: command not found` | python3-pip not installed | `sudo apt-get install -y python3-pip` |
| `podman-compose: command not found` after pip3 | ~/.local/bin not in PATH | `export PATH="$HOME/.local/bin:$PATH"` (add to ~/.bashrc) |
| `dpkg: error processing package podman` | Corrupted installation | `sudo dpkg --configure -a && sudo apt-get install -f` |
| Timeout during installation | Slow network or overloaded mirror | Retry or change APT mirror |

{% endtab %}
{% endtabs %}
