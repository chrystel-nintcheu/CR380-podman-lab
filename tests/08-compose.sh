#!/usr/bin/env bash
# =============================================================================
# CR380 - Lab 08 — Podman Compose
# =============================================================================
#
# FR: Découvrir Podman Compose pour orchestrer plusieurs conteneurs.
#     podman-compose est l'équivalent de docker compose pour Podman.
#     Il utilise le même format de fichier YAML (Compose Spec).
#     Couvre: installation de podman-compose, cycle de vie (up/down/ps/logs).
#
# EN: Discover Podman Compose to orchestrate multiple containers.
#     podman-compose is the equivalent of docker compose for Podman.
#     It uses the same YAML file format (Compose Spec).
#     Covers: podman-compose installation, lifecycle (up/down/ps/logs).
#
# Depends on: 07
#
# 📖 podman-compose: https://github.com/containers/podman-compose
# 📖 Compose Spec: https://compose-spec.io/
# 📖 podman-run(1): https://docs.podman.io/en/latest/markdown/podman-run.1.html
# =============================================================================

run_test() {
    section_header "08" "Podman Compose" \
        "${GITBOOK_URL_08}"

    check_dependency "07" || { section_summary; return; }

    # -------------------------------------------------------------------------
    # Step 1: Check podman-compose is installed
    # FR: Vérifier que podman-compose est installé
    # 📖 https://github.com/containers/podman-compose#installation
    # ⚠  Pitfall: podman-compose is a separate project from Podman itself;
    #    `docker compose` (v2) is built-in, but podman-compose must be
    #    installed separately via apt or pip3
    # -------------------------------------------------------------------------
    learn_pause \
        "Podman Compose utilise le même format YAML que Docker Compose.\nLa commande est 'podman-compose' (avec tiret).\n\nSi non installé:\n  sudo apt-get install -y podman-compose\n  # ou\n  pip3 install podman-compose\n\nCommande: podman-compose --version" \
        "Podman Compose uses the same YAML format as Docker Compose.\nThe command is 'podman-compose' (with hyphen).\n\nIf not installed:\n  sudo apt-get install -y podman-compose\n  # or\n  pip3 install podman-compose\n\nCommand: podman-compose --version"

    if ! command -v podman-compose &>/dev/null; then
        skip "podman-compose not installed — attempting installation" \
             "Run: pip3 install podman-compose"
        run_cmd "Install podman-compose" "${TIMEOUT_APT}" \
            pip3 install podman-compose || true
        if ! command -v podman-compose &>/dev/null; then
            skip "podman-compose installation failed — skipping all compose labs" \
                 "Install manually: pip3 install podman-compose OR sudo apt-get install -y podman-compose"
            section_summary
            return
        fi
    fi

    assert_output_contains \
        "podman-compose is available / podman-compose est disponible" \
        "podman-compose\|version" \
        "Installez: pip3 install podman-compose" \
        podman-compose --version

    # -------------------------------------------------------------------------
    # Step 2: Verify the compose file exists
    # FR: Vérifier que le fichier Compose existe
    # -------------------------------------------------------------------------
    learn_pause \
        "Nous allons utiliser le fichier Compose: ${COMPOSE_NGINX_BASIC}\n\nCe fichier définit un service Nginx simple.\nLa clé 'name:' définit le nom du projet Compose." \
        "We will use the Compose file: ${COMPOSE_NGINX_BASIC}\n\nThis file defines a simple Nginx service.\nThe 'name:' key defines the Compose project name."

    if [[ -f "${COMPOSE_NGINX_BASIC}" ]]; then
        pass "Compose file found / Fichier Compose trouvé: ${COMPOSE_NGINX_BASIC}"
    else
        fail "Compose file not found / Fichier Compose introuvable" \
             "file at ${COMPOSE_NGINX_BASIC}" "not found" \
             "Vérifiez que le fichier ${COMPOSE_NGINX_BASIC} existe dans le dépôt"
        section_summary
        return
    fi

    # Cleanup any leftovers
    cleanup_container "${CT_COMPOSE_NGINX}"
    podman-compose -f "${COMPOSE_NGINX_BASIC}" down &>/dev/null || true

    # -------------------------------------------------------------------------
    # Step 3: Start the compose stack
    # FR: Démarrer la pile Compose
    # 📖 https://github.com/containers/podman-compose#usage
    #    podman-compose up -d: start services in detached mode
    # ⚠  Pitfall: The 'name:' key in the YAML sets the project name;
    #    without it, the directory name is used, which may cause conflicts
    # -------------------------------------------------------------------------
    learn_pause \
        "Démarrons la pile avec 'podman-compose up -d'.\n  -d : mode détaché (background)\n\nCommande: podman-compose -f ${COMPOSE_NGINX_BASIC} up -d" \
        "Let's start the stack with 'podman-compose up -d'.\n  -d: detached mode (background)\n\nCommand: podman-compose -f ${COMPOSE_NGINX_BASIC} up -d"

    run_cmd "podman-compose up" "${TIMEOUT_PULL}" \
        podman-compose -f "${COMPOSE_NGINX_BASIC}" up -d || true

    if (( CMD_EXIT_CODE == 0 )); then
        pass "podman-compose up -d succeeded / démarrage réussi"
    else
        fail "podman-compose up failed" \
             "exit code 0" "exit code ${CMD_EXIT_CODE}" \
             "Essayez: podman-compose -f ${COMPOSE_NGINX_BASIC} up -d"
        section_summary
        return
    fi

    wait_for_container "${CT_COMPOSE_NGINX}" "${TIMEOUT_CONTAINER_READY}" || true

    # -------------------------------------------------------------------------
    # Step 4: Check running services
    # FR: Vérifier les services en cours d'exécution
    # -------------------------------------------------------------------------
    learn_pause \
        "'podman-compose ps' affiche les services en cours d'exécution.\nCommande: podman-compose -f ${COMPOSE_NGINX_BASIC} ps" \
        "'podman-compose ps' shows running services.\nCommand: podman-compose -f ${COMPOSE_NGINX_BASIC} ps"

    assert_container_running "${CT_COMPOSE_NGINX}"

    assert_output_not_empty \
        "podman-compose ps shows services / podman-compose ps liste les services" \
        "Essayez: podman-compose -f ${COMPOSE_NGINX_BASIC} ps" \
        podman-compose -f "${COMPOSE_NGINX_BASIC}" ps

    # -------------------------------------------------------------------------
    # Step 5: Test HTTP response
    # FR: Tester la réponse HTTP
    # -------------------------------------------------------------------------
    learn_pause \
        "Nginx écoute sur le port ${PORT_COMPOSE_NGINX}.\nCommande: curl -s http://localhost:${PORT_COMPOSE_NGINX}" \
        "Nginx listens on port ${PORT_COMPOSE_NGINX}.\nCommand: curl -s http://localhost:${PORT_COMPOSE_NGINX}"

    sleep 2
    assert_http_reachable "http://localhost:${PORT_COMPOSE_NGINX}" 200

    # -------------------------------------------------------------------------
    # Step 6: View logs
    # FR: Consulter les journaux
    # -------------------------------------------------------------------------
    learn_pause \
        "'podman-compose logs' affiche les journaux de tous les services.\nCommande: podman-compose -f ${COMPOSE_NGINX_BASIC} logs" \
        "'podman-compose logs' shows logs for all services.\nCommand: podman-compose -f ${COMPOSE_NGINX_BASIC} logs"

    assert_success \
        "podman-compose logs produces output / journaux disponibles" \
        "Le service doit être démarré" \
        podman-compose -f "${COMPOSE_NGINX_BASIC}" logs

    # -------------------------------------------------------------------------
    # Step 7: Stop and remove
    # FR: Arrêter et supprimer
    # 📖 https://github.com/containers/podman-compose#usage
    #    podman-compose down: stops and removes containers and networks
    # ⚠  Pitfall: 'down' does NOT remove named volumes unless you add
    #    --volumes flag; data persists otherwise
    # -------------------------------------------------------------------------
    learn_pause \
        "'podman-compose down' arrête et supprime les conteneurs et réseaux.\nLes volumes nommés sont conservés (sauf avec --volumes).\n\nCommande: podman-compose -f ${COMPOSE_NGINX_BASIC} down" \
        "'podman-compose down' stops and removes containers and networks.\nNamed volumes are kept (unless --volumes is used).\n\nCommand: podman-compose -f ${COMPOSE_NGINX_BASIC} down"

    assert_success \
        "podman-compose down succeeded / arrêt réussi" \
        "Vérifiez: podman-compose -f ${COMPOSE_NGINX_BASIC} down" \
        podman-compose -f "${COMPOSE_NGINX_BASIC}" down

    assert_container_not_exists "${CT_COMPOSE_NGINX}"

    section_summary
}
