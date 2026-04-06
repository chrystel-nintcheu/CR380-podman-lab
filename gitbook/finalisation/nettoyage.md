---
description: >-
  Nettoyer l'environnement Podman / 
  Clean up the Podman environment
---

# Lab 99 — Nettoyage final / Final Teardown

{% tabs %}
{% tab title="Français" %}

## Objectif

Supprimer tous les artefacts créés pendant les labs pour remettre l'environnement à zéro.

## Commandes de nettoyage

```bash
# Supprimer un conteneur spécifique
podman rm -f <nom>

# Supprimer un pod et ses conteneurs
podman pod rm -f <nom>

# Supprimer une image
podman rmi -f <image>

# Supprimer un volume
podman volume rm <nom>

# Nettoyage global (conteneurs arrêtés, images orphelines, réseaux inutilisés)
podman system prune -f

# Nettoyage complet avec volumes
podman system prune -f --volumes
```

## Nettoyage des labs CR380

```bash
# Conteneurs des labs
podman rm -f alpineCT nginxCT appCT volCT pod-nginx cr380-podman-nginx

# Pods des labs
podman pod rm -f mypod

# Images construites
podman rmi -f monimage:base monimage:slim

# Volumes des labs
podman volume rm podman_data

# Nettoyage global
podman system prune -f
```

## Exécution automatisée

```bash
./run-labs.sh --lab 99
```

{% endtab %}
{% tab title="English" %}

## Objective

Remove all artifacts created during the labs to reset the environment.

## Cleanup commands

```bash
# Remove a specific container
podman rm -f <name>

# Remove a pod and its containers
podman pod rm -f <name>

# Remove an image
podman rmi -f <image>

# Remove a volume
podman volume rm <name>

# Global cleanup (stopped containers, dangling images, unused networks)
podman system prune -f

# Full cleanup including volumes
podman system prune -f --volumes
```

## CR380 lab cleanup

```bash
# Lab containers
podman rm -f alpineCT nginxCT appCT volCT pod-nginx cr380-podman-nginx

# Lab pods
podman pod rm -f mypod

# Built images
podman rmi -f monimage:base monimage:slim

# Lab volumes
podman volume rm podman_data

# Global cleanup
podman system prune -f
```

## Automated run

```bash
./run-labs.sh --lab 99
```

{% endtab %}
{% endtabs %}
