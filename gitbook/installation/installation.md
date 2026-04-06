---
description: >-
  Installer Podman sur Ubuntu via APT /
  Install Podman on Ubuntu via APT
---

# Lab 01 — Installation de Podman / Podman Installation

{% tabs %}
{% tab title="Français" %}

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

{% endtab %}
{% tab title="English" %}

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

{% endtab %}
{% endtabs %}
