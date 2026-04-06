#!/usr/bin/env bash
# =============================================================================
# CR380 - Lab 03 — Premiers conteneurs / First Containers
# =============================================================================
#
# FR: Apprendre les commandes de base de Podman pour gérer les conteneurs.
#     Couvre: podman run (interactif et détaché), podman exec, podman stop,
#     podman rm, podman ps, mapping de ports.
#
# EN: Learn the basic Podman commands to manage containers.
#     Covers: podman run (interactive and detached), podman exec, podman stop,
#     podman rm, podman ps, port mapping.
#
# Depends on: 02
# =============================================================================

run_test() {
    section_header "03" "Premiers conteneurs / First Containers" \
        "${GITBOOK_URL_03}"

    check_dependency "02" || { section_summary; return; }

    # Cleanup leftovers from previous runs
    cleanup_container "${CT_ALPINE}"
    cleanup_container "${CT_NGINX}"

    # -------------------------------------------------------------------------
    # Part A: Conteneur Alpine interactif
    # FR: Lancer un conteneur Alpine en mode interactif
    # -------------------------------------------------------------------------
    learn_pause \
        "Nous allons créer un conteneur Alpine en mode interactif.\nAlpine est une image minimaliste (<10 Mo) très utilisée.\n\nCommande: podman run -dit --name ${CT_ALPINE} ${IMAGE_ALPINE}\n\n  -d : détaché (en arrière-plan)\n  -i : interactif (garder STDIN ouvert)\n  -t : allouer un pseudo-terminal" \
        "We'll create an interactive Alpine container.\nAlpine is a minimal image (<10 MB) widely used.\n\nCommand: podman run -dit --name ${CT_ALPINE} ${IMAGE_ALPINE}\n\n  -d: detached (background)\n  -i: interactive (keep STDIN open)\n  -t: allocate a pseudo-terminal"

    run_cmd "Pull Alpine image" "${TIMEOUT_PULL}" \
        podman pull "${IMAGE_ALPINE}" || true

    run_cmd "Create Alpine container" "${TIMEOUT_DEFAULT}" \
        podman run -dit --name "${CT_ALPINE}" "${IMAGE_ALPINE}" || true

    if (( CMD_EXIT_CODE == 0 )); then
        pass "Container '${CT_ALPINE}' created / Conteneur '${CT_ALPINE}' créé"
    else
        fail "Failed to create container '${CT_ALPINE}'" \
             "exit code 0" "exit code ${CMD_EXIT_CODE}" \
             "Essayez: podman run -dit --name ${CT_ALPINE} ${IMAGE_ALPINE}"
    fi

    if wait_for_container "${CT_ALPINE}"; then
        pass "Container '${CT_ALPINE}' is running / Conteneur en exécution"
    else
        fail "Container '${CT_ALPINE}' not running after timeout" \
             "running" "not running" \
             "Essayez: podman logs ${CT_ALPINE}"
    fi

    # -------------------------------------------------------------------------
    # podman exec: run a command inside the container
    # FR: Exécuter une commande dans le conteneur
    # -------------------------------------------------------------------------
    learn_pause \
        "Exécutons une commande dans le conteneur avec 'podman exec'.\nCommande: podman exec ${CT_ALPINE} cat /etc/os-release" \
        "Let's run a command inside the container with 'podman exec'.\nCommand: podman exec ${CT_ALPINE} cat /etc/os-release"

    assert_output_contains \
        "podman exec reads /etc/os-release / podman exec lit /etc/os-release" \
        "Alpine" \
        "Le conteneur doit être en marche: podman start ${CT_ALPINE}" \
        podman exec "${CT_ALPINE}" cat /etc/os-release

    # -------------------------------------------------------------------------
    # podman ps: list running containers
    # FR: Lister les conteneurs en cours d'exécution
    # -------------------------------------------------------------------------
    learn_pause \
        "'podman ps' liste les conteneurs en cours d'exécution.\nUtilisez 'podman ps -a' pour voir tous les conteneurs (y compris arrêtés).\n\nCommande: podman ps" \
        "'podman ps' lists running containers.\nUse 'podman ps -a' to see all containers (including stopped).\n\nCommand: podman ps"

    assert_output_contains \
        "podman ps shows '${CT_ALPINE}' / podman ps montre '${CT_ALPINE}'" \
        "${CT_ALPINE}" \
        "Essayez: podman start ${CT_ALPINE}" \
        podman ps --format '{{.Names}}'

    # -------------------------------------------------------------------------
    # podman stop + podman rm
    # FR: Arrêter et supprimer le conteneur Alpine
    # -------------------------------------------------------------------------
    learn_pause \
        "Arrêtons et supprimons le conteneur Alpine.\n  podman stop ${CT_ALPINE}\n  podman rm ${CT_ALPINE}\n\nDifférence avec Docker: Podman supporte aussi 'podman rm -f'\npour forcer la suppression sans arrêt préalable." \
        "Let's stop and remove the Alpine container.\n  podman stop ${CT_ALPINE}\n  podman rm ${CT_ALPINE}\n\nDifference from Docker: Podman also supports 'podman rm -f'\nto force removal without prior stop."

    assert_success \
        "podman stop '${CT_ALPINE}'" \
        "Essayez: podman stop ${CT_ALPINE}" \
        podman stop "${CT_ALPINE}"

    assert_success \
        "podman rm '${CT_ALPINE}'" \
        "Essayez: podman rm ${CT_ALPINE}" \
        podman rm "${CT_ALPINE}"

    assert_container_not_exists "${CT_ALPINE}"

    # -------------------------------------------------------------------------
    # Part B: Conteneur Nginx avec mapping de port
    # FR: Lancer un conteneur Nginx avec mapping de port
    # -------------------------------------------------------------------------
    learn_pause \
        "Lançons un serveur web Nginx dans un conteneur avec mapping de port.\nCommande: podman run -d --name ${CT_NGINX} -p ${PORT_NGINX}:80 ${IMAGE_NGINX}\n\n  -p ${PORT_NGINX}:80 : mappe le port ${PORT_NGINX} de l'hôte au port 80 du conteneur\n\nNote: Podman rootless redirige les ports non-privilégiés (>1024).\nLes ports 80 et 443 nécessitent une configuration spéciale en rootless." \
        "Let's run an Nginx web server in a container with port mapping.\nCommand: podman run -d --name ${CT_NGINX} -p ${PORT_NGINX}:80 ${IMAGE_NGINX}\n\n  -p ${PORT_NGINX}:80: maps host port ${PORT_NGINX} to container port 80\n\nNote: Rootless Podman redirects non-privileged ports (>1024).\nPorts 80 and 443 require special configuration in rootless mode."

    run_cmd "Pull Nginx image" "${TIMEOUT_PULL}" \
        podman pull "${IMAGE_NGINX}" || true

    run_cmd "Create Nginx container" "${TIMEOUT_DEFAULT}" \
        podman run -d --name "${CT_NGINX}" -p "${PORT_NGINX}:80" "${IMAGE_NGINX}" || true

    if (( CMD_EXIT_CODE == 0 )); then
        pass "Container '${CT_NGINX}' created / Conteneur '${CT_NGINX}' créé"
    else
        fail "Failed to create container '${CT_NGINX}'" \
             "exit code 0" "exit code ${CMD_EXIT_CODE}" \
             "Essayez: podman run -d --name ${CT_NGINX} -p ${PORT_NGINX}:80 ${IMAGE_NGINX}"
    fi

    if wait_for_container "${CT_NGINX}" "${TIMEOUT_CONTAINER_READY}"; then
        pass "Container '${CT_NGINX}' is running / Conteneur en exécution"
    else
        fail "Container '${CT_NGINX}' not running" \
             "running" "not running" \
             "Essayez: podman logs ${CT_NGINX}"
    fi

    # Test HTTP access
    learn_pause \
        "Testons l'accès HTTP au serveur Nginx via le port mappé.\nCommande: curl -s http://localhost:${PORT_NGINX}" \
        "Let's test HTTP access to the Nginx server via the mapped port.\nCommand: curl -s http://localhost:${PORT_NGINX}"

    sleep 2

    assert_output_contains \
        "Nginx responds on port ${PORT_NGINX} / Nginx répond sur le port ${PORT_NGINX}" \
        "Welcome to nginx" \
        "Vérifiez que le port ${PORT_NGINX} n'est pas utilisé: ss -tlnp | grep ${PORT_NGINX}" \
        curl -s --max-time 10 "http://localhost:${PORT_NGINX}"

    # podman logs
    learn_pause \
        "Consultez les logs du conteneur avec 'podman logs'." \
        "Check the container logs with 'podman logs'."

    assert_output_not_empty \
        "podman logs '${CT_NGINX}' has output / podman logs a une sortie" \
        "Le conteneur doit être démarré" \
        podman logs "${CT_NGINX}"

    # -------------------------------------------------------------------------
    # Cleanup
    # FR: Nettoyage
    # -------------------------------------------------------------------------
    learn_pause \
        "Nettoyage : arrêtons et supprimons le conteneur Nginx." \
        "Cleanup: let's stop and remove the Nginx container."

    assert_success \
        "podman stop '${CT_NGINX}'" \
        "Essayez: podman stop ${CT_NGINX}" \
        podman stop "${CT_NGINX}"

    assert_success \
        "podman rm '${CT_NGINX}'" \
        "Essayez: podman rm ${CT_NGINX}" \
        podman rm "${CT_NGINX}"

    assert_container_not_exists "${CT_NGINX}"

    section_summary
}
