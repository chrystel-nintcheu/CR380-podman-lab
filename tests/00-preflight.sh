#!/usr/bin/env bash
# =============================================================================
# CR380 - Lab 00 — Vérifications préalables / Preflight Checks
# =============================================================================
#
# FR: Vérifier que l'environnement est prêt pour les labs Podman.
#     Couvre: OS, réseau, espace disque, outils requis.
#
# EN: Verify the environment is ready for the Podman labs.
#     Covers: OS, network, disk space, required tools.
#
# Depends on: (none)
# =============================================================================

run_test() {
    section_header "00" "Vérifications préalables / Preflight Checks"

    # -------------------------------------------------------------------------
    # Step 1: Check OS
    # FR: Vérifier la version du système d'exploitation
    # -------------------------------------------------------------------------
    learn_pause \
        "Nous vérifions d'abord que le système d'exploitation est Ubuntu.\nCommande: lsb_release -d" \
        "First we verify the operating system is Ubuntu.\nCommand: lsb_release -d"

    if command -v lsb_release &>/dev/null; then
        assert_output_contains \
            "OS is Ubuntu / Le SE est Ubuntu" \
            "Ubuntu" \
            "Installez Ubuntu 22.04 LTS ou supérieur / Install Ubuntu 22.04 LTS or later" \
            lsb_release -d
    else
        assert_output_contains \
            "OS is Ubuntu / Le SE est Ubuntu" \
            "Ubuntu" \
            "Installez Ubuntu 22.04 LTS ou supérieur / Install Ubuntu 22.04 LTS or later" \
            cat /etc/os-release
    fi

    # -------------------------------------------------------------------------
    # Step 2: Check internet connectivity
    # FR: Vérifier la connexion Internet
    # -------------------------------------------------------------------------
    learn_pause \
        "Vérification de la connexion Internet vers quay.io (registre Podman).\nCommande: curl -s --max-time 10 https://quay.io" \
        "Checking Internet connectivity to quay.io (Podman registry).\nCommand: curl -s --max-time 10 https://quay.io"

    run_cmd "Check Internet" "${TIMEOUT_DEFAULT}" \
        curl -s --max-time 10 -o /dev/null -w '%{http_code}' https://quay.io || true

    if (( CMD_EXIT_CODE == 0 )); then
        pass "Internet connectivity OK / Connexion Internet OK"
    else
        fail "Internet connectivity" \
             "HTTP response from quay.io" \
             "curl exit code ${CMD_EXIT_CODE}" \
             "Vérifiez votre connexion Internet / Check your Internet connection"
    fi

    # -------------------------------------------------------------------------
    # Step 3: Check disk space
    # FR: Vérifier l'espace disque disponible
    # -------------------------------------------------------------------------
    learn_pause \
        "Vérification de l'espace disque disponible (minimum ${MIN_DISK_GB} Go).\nCommande: df -BG /" \
        "Checking available disk space (minimum ${MIN_DISK_GB} GB).\nCommand: df -BG /"

    local avail_gb
    avail_gb=$(df -BG / | awk 'NR==2 {print $4}' | tr -d 'G')

    if (( avail_gb >= MIN_DISK_GB )); then
        pass "Disk space: ${avail_gb} GB available (>= ${MIN_DISK_GB} GB) / Espace disque OK"
    else
        fail "Disk space insufficient / Espace disque insuffisant" \
             ">= ${MIN_DISK_GB} GB" \
             "${avail_gb} GB" \
             "Libérez de l'espace disque / Free up disk space"
    fi

    # -------------------------------------------------------------------------
    # Step 4: Check required tools
    # FR: Vérifier que les outils requis sont installés
    # -------------------------------------------------------------------------
    learn_pause \
        "Vérification des outils requis: curl, jq, git." \
        "Checking required tools: curl, jq, git."

    local tools=("curl" "jq" "git")
    for tool in "${tools[@]}"; do
        if command -v "${tool}" &>/dev/null; then
            pass "${tool} is installed / ${tool} est installé"
        else
            fail "${tool} is missing / ${tool} est manquant" \
                 "${tool} available in PATH" \
                 "not found" \
                 "Installez avec: sudo apt-get install -y ${tool}"
        fi
    done

    # -------------------------------------------------------------------------
    # Step 5: Check Podman is not yet installed (lab 01 will install it)
    # FR: Vérifier que Podman n'est pas déjà installé (lab 01 va l'installer)
    # -------------------------------------------------------------------------
    learn_pause \
        "Nous vérifions si Podman est déjà installé.\nSi Podman est présent, le lab 01 sera ignoré." \
        "We check if Podman is already installed.\nIf Podman is present, lab 01 will be skipped."

    if command -v podman &>/dev/null; then
        local podman_ver
        podman_ver=$(podman --version 2>/dev/null || echo "unknown")
        pass "Podman already present: ${podman_ver} — lab 01 will be skipped"
    else
        pass "Podman not yet installed — ready for lab 01 / Podman pas encore installé"
    fi

    section_summary
}
