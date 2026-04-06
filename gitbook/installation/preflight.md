---
description: >-
  Vérifier que l'environnement est prêt pour les labs Podman /
  Verify the environment is ready for Podman labs
---

# Lab 00 — Vérifications préalables / Preflight Checks

{% tabs %}
{% tab title="Français" %}

## Objectif

Vérifier que votre environnement répond aux exigences minimales pour exécuter les labs Podman.

## Vérifications effectuées

| Vérification | Commande | Valeur attendue |
|-------------|---------|-----------------|
| OS Ubuntu | `lsb_release -d` | contient "Ubuntu" |
| Connexion Internet | `curl https://quay.io` | code HTTP |
| Espace disque | `df -BG /` | ≥ 10 Go |
| `curl` installé | `which curl` | dans PATH |
| `jq` installé | `which jq` | dans PATH |
| `git` installé | `which git` | dans PATH |

## Installer les outils manquants

```bash
sudo apt-get update
sudo apt-get install -y git curl jq
```

## Exécution

```bash
./run-labs.sh --learn --lab 00
```

{% endtab %}
{% tab title="English" %}

## Objective

Verify your environment meets the minimum requirements to run the Podman labs.

## Checks performed

| Check | Command | Expected |
|-------|---------|----------|
| Ubuntu OS | `lsb_release -d` | contains "Ubuntu" |
| Internet | `curl https://quay.io` | HTTP response |
| Disk space | `df -BG /` | ≥ 10 GB |
| `curl` installed | `which curl` | in PATH |
| `jq` installed | `which jq` | in PATH |
| `git` installed | `which git` | in PATH |

## Install missing tools

```bash
sudo apt-get update
sudo apt-get install -y git curl jq
```

## Run

```bash
./run-labs.sh --learn --lab 00
```

{% endtab %}
{% endtabs %}
