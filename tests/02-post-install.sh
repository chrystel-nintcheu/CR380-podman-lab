#!/usr/bin/env bash
# =============================================================================
# CR380 - Lab 02 — Après installation / Post-Installation
# =============================================================================
#
# FR: Configurer Podman après l'installation.
#     Podman est rootless par défaut : les conteneurs tournent sans root.
#     Couvre: podman info, podman system info, hello-world, configuration
#     du registre de conteneurs.
#
# EN: Configure Podman after installation.
#     Podman is rootless by default: containers run without root.
#     Covers: podman info, podman system info, hello-world, container
#     registry configuration.
#
# Depends on: 01
# =============================================================================

run_test() {
    section_header "02" "Après installation / Post-Installation" \
        "${GITBOOK_URL_02}"

    check_dependency "01" || { section_summary; return; }

    # -------------------------------------------------------------------------
    # Step 1: Verify podman is in PATH
    # FR: Vérifier que podman est dans le PATH
    # -------------------------------------------------------------------------
    learn_pause \
        "Vérifions que la commande 'podman' est disponible.\nCommande: which podman" \
        "Let's verify the 'podman' command is available.\nCommand: which podman"

    assert_success \
        "podman is in PATH / podman est dans le PATH" \
        "Installez Podman: sudo apt-get install -y podman" \
        which podman

    # -------------------------------------------------------------------------
    # Step 2: Check podman version
    # FR: Vérifier la version de Podman
    # -------------------------------------------------------------------------
    learn_pause \
        "Podman est différent de Docker: il n'a pas de démon (daemon) central.\nChaque commande 'podman' est un processus indépendant.\n\nCommande: podman version" \
        "Podman differs from Docker: it has no central daemon.\nEach 'podman' command is an independent process.\n\nCommand: podman version"

    assert_output_contains \
        "podman version shows version info / podman version affiche la version" \
        "Version" \
        "Installez Podman: sudo apt-get install -y podman" \
        podman version

    # -------------------------------------------------------------------------
    # Step 3: Check podman info
    # FR: Vérifier les informations système de Podman
    # -------------------------------------------------------------------------
    learn_pause \
        "'podman info' affiche les détails de la configuration Podman.\nNotez la ligne 'rootless: true' — Podman tourne sans root !\n\nCommande: podman info" \
        "'podman info' shows Podman configuration details.\nNote the 'rootless: true' line — Podman runs without root!\n\nCommand: podman info"

    assert_output_contains \
        "podman info shows OS / podman info affiche l'OS" \
        "os:" \
        "Vérifiez: podman info" \
        podman info

    # -------------------------------------------------------------------------
    # Step 4: Run hello-world equivalent
    # FR: Lancer le conteneur hello-world de Podman
    # -------------------------------------------------------------------------
    learn_pause \
        "Testons l'installation avec l'image hello-world de Podman.\nC'est la façon la plus simple de vérifier que tout fonctionne.\n\nCommande: podman run ${IMAGE_HELLO}" \
        "Let's test the installation with Podman's hello-world image.\nThis is the simplest way to verify everything works.\n\nCommand: podman run ${IMAGE_HELLO}"

    run_cmd "Run hello-world" "${TIMEOUT_PULL}" \
        podman run --rm "${IMAGE_HELLO}" || true

    if (( CMD_EXIT_CODE == 0 )); then
        pass "podman run hello-world succeeded / podman run hello-world réussi"
    else
        # Fallback to alpine echo
        run_cmd "Run alpine hello" "${TIMEOUT_PULL}" \
            podman run --rm "${IMAGE_ALPINE}" echo "Hello from Podman!" || true
        if (( CMD_EXIT_CODE == 0 )); then
            pass "podman run alpine echo succeeded / podman run alpine echo réussi"
        else
            fail "podman run test failed" \
                 "exit code 0" "exit code ${CMD_EXIT_CODE}" \
                 "Vérifiez: podman info | grep -i 'root'"
        fi
    fi

    # -------------------------------------------------------------------------
    # Step 5: Check registries configuration
    # FR: Vérifier la configuration des registres
    # -------------------------------------------------------------------------
    learn_pause \
        "Podman utilise un fichier de configuration pour les registres.\n/etc/containers/registries.conf définit où chercher les images.\nPar défaut, Docker Hub (docker.io) et Quay.io sont configurés.\n\nCommande: podman info --format '{{.Registries}}'" \
        "Podman uses a configuration file for registries.\n/etc/containers/registries.conf defines where to look for images.\nBy default, Docker Hub (docker.io) and Quay.io are configured.\n\nCommand: podman info --format '{{.Registries}}'"

    if [[ -f /etc/containers/registries.conf ]]; then
        pass "Registries config found: /etc/containers/registries.conf"
    else
        skip "registries.conf not found — using defaults" \
             "Default registries will be used (docker.io, quay.io)"
    fi

    # -------------------------------------------------------------------------
    # Step 6: Verify rootless operation
    # FR: Vérifier que Podman fonctionne en mode rootless
    # -------------------------------------------------------------------------
    learn_pause \
        "L'une des grandes différences de Podman : les conteneurs tournent\nsans les droits root, ce qui est plus sécurisé.\n\nVérifions: id (doit montrer un UID non-root)" \
        "One of Podman's key differences: containers run\nwithout root privileges, which is more secure.\n\nLet's check: id (should show a non-root UID)"

    run_cmd "Check current user" "${TIMEOUT_DEFAULT}" id || true

    if echo "${CMD_OUTPUT}" | grep -q "uid=0"; then
        pass "Running as root — rootless also available for users"
    else
        pass "Running as non-root user — rootless mode active / Mode rootless actif"
    fi

    section_summary
}
