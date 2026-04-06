# Accueil — CR380 Labs Podman

Bienvenue dans le guide pratique du cours CR380 de Polytechnique Montréal. Ce guide accompagne la suite de tests automatisés qui reproduit chaque exercice de lab Podman.

{% tabs %}
{% tab title="Français" %}
{% hint style="info" %}
Ce guide est généré à partir du dépôt [CR380-podman-lab](https://github.com/chrystel-nintcheu/CR380-podman-lab). Les commandes présentées sont les mêmes que celles exécutées par la suite de tests automatisés.
{% endhint %}
{% endtab %}

{% tab title="English" %}
{% hint style="info" %}
This guide is generated from the [CR380-podman-lab](https://github.com/chrystel-nintcheu/CR380-podman-lab) repository. The commands shown are the same as those executed by the automated test suite.
{% endhint %}
{% endtab %}
{% endtabs %}

## Qu'est-ce que Podman ? / What is Podman?

{% tabs %}
{% tab title="Français" %}
**Podman** (Pod Manager) est un moteur de conteneurs **sans démon** (daemonless) qui est une alternative compatible avec Docker. Ses caractéristiques principales:

- 🔒 **Rootless** : les conteneurs tournent sans les droits root (plus sécurisé)
- 🚫 **Sans démon** : pas de service `dockerd` en arrière-plan
- 🐧 **Compatible OCI** : utilise les mêmes formats d'images que Docker
- ☸️ **Kubernetes-ready** : supporte les Pods et génère des YAML Kubernetes
- 📦 **Multi-registres** : Docker Hub, Quay.io, et d'autres registres
{% endtab %}

{% tab title="English" %}
**Podman** (Pod Manager) is a **daemonless** container engine that is a Docker-compatible alternative. Its main features:

- 🔒 **Rootless**: containers run without root privileges (more secure)
- 🚫 **Daemonless**: no background `dockerd` service
- 🐧 **OCI-compatible**: uses the same image formats as Docker
- ☸️ **Kubernetes-ready**: supports Pods and generates Kubernetes YAML
- 📦 **Multi-registry**: Docker Hub, Quay.io, and other registries
{% endtab %}
{% endtabs %}

## Podman vs Docker

| Fonctionnalité / Feature | Docker | Podman |
|--------------------------|--------|--------|
| Démon / Daemon | ✅ Requis | ❌ Pas de démon |
| Rootless | ⚠️ Configuré | ✅ Par défaut |
| Pods | ❌ Non | ✅ Oui |
| YAML Kubernetes | ❌ Non | ✅ `podman generate kube` |
| Compose | `docker compose` | `podman-compose` |
| CLI compatible | — | ✅ Quasiment identique |

## Progression des labs

| # | Lab | Phase | Dépendance |
|---|-----|-------|------------|
| 00 | Vérifications préalables | — | Aucune |
| 01 | Installation de Podman | Installation | Lab 00 |
| 02 | Après installation | Installation | Lab 01 |
| 03 | Premiers conteneurs | Conteneurs | Lab 02 |
| 04 | Images & Registres | Conteneurs | Lab 03 |
| 05 | Containerfile | Conteneurs | Lab 04 |
| 06 | Volumes & Persistance | Avancé | Lab 05 |
| 07 | Pods | Avancé | Lab 06 |
| 08 | Podman Compose | Compose | Lab 07 |
| 99 | Nettoyage final | Finalisation | Aucune |

## Prérequis système

{% tabs %}
{% tab title="Français" %}
- **OS** : Ubuntu 22.04 ou supérieur (amd64)
- **Disque** : au moins 10 Go d'espace libre
- **Internet** : accès à `docker.io` et `quay.io`
- **Outils** : `git`, `curl`, `jq` installés
{% endtab %}

{% tab title="English" %}
- **OS**: Ubuntu 22.04 or later (amd64)
- **Disk**: at least 10 GB free space
- **Internet**: access to `docker.io` and `quay.io`
- **Tools**: `git`, `curl`, `jq` installed
{% endtab %}
{% endtabs %}

## Démarrage rapide / Quick Start

```bash
git clone https://github.com/chrystel-nintcheu/CR380-podman-lab.git
cd CR380-podman-lab
./run-labs.sh --learn
```
