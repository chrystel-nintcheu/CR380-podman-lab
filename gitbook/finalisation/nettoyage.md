---
description: >-
  Nettoyer l'environnement Podman / 
  Clean up the Podman environment
---

# Lab 99 — Nettoyage final / Final Teardown

{% tabs %}
{% tab title="Français" %}

## Avant de commencer

**Prérequis** : Aucun — ce lab peut être exécuté à tout moment.

**Glossaire**
| Terme | Définition |
|-------|------------|
| prune | Supprimer les ressources inutilisées (conteneurs arrêtés, images orphelines) |
| dangling image | Image sans tag (résultat d'un rebuild) |
| system prune | Nettoyage global de toutes les ressources Podman inutilisées |

📖 **Documentation officielle** :
- [podman-system-prune(1)](https://docs.podman.io/en/latest/markdown/podman-system-prune.1.html)
- [podman-rm(1)](https://docs.podman.io/en/latest/markdown/podman-rm.1.html)

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

## Dépannage

| Symptôme | Cause | Solution |
|----------|-------|----------|
| `Error: container is running` lors de rm | Conteneur pas arrêté | Utilisez `podman rm -f` (force) |
| Images de base restent après prune | `system prune` sans `--all` | Ajoutez `--all` : `podman system prune -f --all` |
| Volumes restent après prune | `system prune` ne touche pas les volumes par défaut | Ajoutez `--volumes` : `podman system prune -f --volumes` |
| `Error: pod has running containers` | Pod actif | `podman pod rm -f mypod` |
| Espace disque pas libéré | Couches partagées entre images | Supprimez toutes les images : `podman rmi -a` |

{% endtab %}
{% tab title="English" %}

## Before You Start

**Prerequisites**: None — this lab can be run at any time.

**Glossary**
| Term | Definition |
|------|------------|
| prune | Remove unused resources (stopped containers, orphan images) |
| dangling image | Image without a tag (result of a rebuild) |
| system prune | Global cleanup of all unused Podman resources |

📖 **Official docs**:
- [podman-system-prune(1)](https://docs.podman.io/en/latest/markdown/podman-system-prune.1.html)
- [podman-rm(1)](https://docs.podman.io/en/latest/markdown/podman-rm.1.html)

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

## Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| `Error: container is running` on rm | Container not stopped | Use `podman rm -f` (force) |
| Base images remain after prune | `system prune` without `--all` | Add `--all`: `podman system prune -f --all` |
| Volumes remain after prune | `system prune` doesn't touch volumes by default | Add `--volumes`: `podman system prune -f --volumes` |
| `Error: pod has running containers` | Active pod | `podman pod rm -f mypod` |
| Disk space not freed | Shared layers between images | Remove all images: `podman rmi -a` |

{% endtab %}
{% endtabs %}
