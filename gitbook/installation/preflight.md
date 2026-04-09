---
description: >-
  Vérifier que l'environnement est prêt pour les labs Podman /
  Verify the environment is ready for Podman labs
---

# Lab 00 — Vérifications préalables / Preflight Checks

{% tabs %}
{% tab title="Français" %}

## Avant de commencer

Ce lab ne nécessite aucune connaissance préalable de Podman. Vous devez simplement avoir accès à un terminal sur une machine Ubuntu.

**Glossaire**
| Terme | Définition |
|-------|-----------|
| Rootless | Exécution de conteneurs sans privilèges root |
| subuid/subgid | Plages d'identifiants utilisateur/groupe subordonnés pour le mode rootless |
| Registre | Serveur hébergeant des images de conteneurs (ex: docker.io, quay.io) |

📖 **Documentation officielle** : [podman(1)](https://docs.podman.io/en/latest/markdown/podman.1.html)

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
| subuid configuré | `grep $USER /etc/subuid` | entrée trouvée |
| subgid configuré | `grep $USER /etc/subgid` | entrée trouvée |

## Installer les outils manquants

```bash
sudo apt-get update
sudo apt-get install -y git curl jq
```

## Configurer subuid/subgid (si manquant)

```bash
sudo usermod --add-subuids 100000-165535 $USER
sudo usermod --add-subgids 100000-165535 $USER
```

## Dépannage

| Symptôme | Cause | Solution |
|----------|-------|----------|
| `lsb_release: command not found` | Outil manquant sur install minimale | `sudo apt-get install -y lsb-release` |
| `curl: (6) Could not resolve host: quay.io` | Pas de DNS / pas d'Internet | Vérifiez `ping 8.8.8.8` puis `cat /etc/resolv.conf` |
| Espace disque insuffisant | Partition / pleine | `df -h` pour identifier, `sudo apt-get clean` pour libérer |
| `grep $USER /etc/subuid` ne retourne rien | subuid non configuré | `sudo usermod --add-subuids 100000-165535 $USER` |
| `jq` non trouvé | Pas installé par défaut sur Ubuntu minimal | `sudo apt-get install -y jq` |

## Exécution

```bash
./run-labs.sh --learn --lab 00
```

{% endtab %}
{% tab title="English" %}

## Before You Start

This lab requires no prior Podman knowledge. You only need terminal access to an Ubuntu machine.

**Glossary**
| Term | Definition |
|------|-----------|
| Rootless | Running containers without root privileges |
| subuid/subgid | Subordinate user/group ID ranges for rootless mode |
| Registry | Server hosting container images (e.g., docker.io, quay.io) |

📖 **Official docs**: [podman(1)](https://docs.podman.io/en/latest/markdown/podman.1.html)

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
| subuid configured | `grep $USER /etc/subuid` | entry found |
| subgid configured | `grep $USER /etc/subgid` | entry found |

## Install missing tools

```bash
sudo apt-get update
sudo apt-get install -y git curl jq
```

## Configure subuid/subgid (if missing)

```bash
sudo usermod --add-subuids 100000-165535 $USER
sudo usermod --add-subgids 100000-165535 $USER
```

## Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| `lsb_release: command not found` | Missing tool on minimal install | `sudo apt-get install -y lsb-release` |
| `curl: (6) Could not resolve host: quay.io` | No DNS / No Internet | Check `ping 8.8.8.8` then `cat /etc/resolv.conf` |
| Insufficient disk space | Root partition full | `df -h` to identify, `sudo apt-get clean` to free space |
| `grep $USER /etc/subuid` returns nothing | subuid not configured | `sudo usermod --add-subuids 100000-165535 $USER` |
| `jq` not found | Not installed on minimal Ubuntu | `sudo apt-get install -y jq` |

## Run

```bash
./run-labs.sh --learn --lab 00
```

{% endtab %}
{% endtabs %}
