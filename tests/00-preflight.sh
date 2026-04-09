#!/usr/bin/env bash
# =============================================================================
# CR380 - Lab 00 — Vérifications préalables / Preflight Checks
# =============================================================================
#
# FR: Vérifier que l'environnement est prêt pour les labs Podman.
#     Couvre: OS, réseau, espace disque, outils requis, subuid/subgid.
#
# EN: Verify the environment is ready for the Podman labs.
#     Covers: OS, network, disk space, required tools, subuid/subgid.
#
# Depends on: (none)
#
# 📖 Official doc: https://docs.podman.io/en/latest/markdown/podman.1.html
# 📖 Rootless setup: https://docs.podman.io/en/latest/markdown/podman.1.html#rootless-mode
# =============================================================================

run_test() {
    section_header "00" "Vérifications préalables / Preflight Checks"

    # -------------------------------------------------------------------------
    # Step 1: Check OS
    # FR: Vérifier la version du système d'exploitation
    # 📖 Podman supports: https://podman.io/docs/installation#linux-distributions
    # ⚠  Pitfall: Podman version differs across Ubuntu releases (22.04 vs 24.04)
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
    # 📖 Podman registries: https://docs.podman.io/en/latest/markdown/podman.1.html#registries
    # ⚠  Pitfall: Corporate firewalls may block quay.io or docker.io
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
    # 📖 Podman stores images in ~/.local/share/containers (rootless)
    # ⚠  Pitfall: df / may not reflect the partition where containers are stored
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
    # ⚠  Pitfall: jq may not be installed by default on minimal Ubuntu
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
    # Step 5: Check subuid/subgid for rootless Podman
    # FR: Vérifier la configuration des plages UID/GID pour le mode rootless
    # 📖 Rootless requires subordinate UIDs/GIDs:
    #    https://docs.podman.io/en/latest/markdown/podman.1.html#rootless-mode
    # ⚠  Pitfall: Missing subuid/subgid causes "cannot set up namespace" errors
    # -------------------------------------------------------------------------
    learn_pause \
        "Le mode rootless de Podman nécessite des plages d'UIDs/GIDs\nsubordonnés dans /etc/subuid et /etc/subgid.\nSans cela, Podman ne peut pas créer les namespaces utilisateur." \
        "Podman's rootless mode requires subordinate UID/GID ranges\nin /etc/subuid and /etc/subgid.\nWithout this, Podman cannot create user namespaces."

    local current_user
    current_user=$(whoami)

    if grep -q "^${current_user}:" /etc/subuid 2>/dev/null; then
        pass "subuid configured for ${current_user} / subuid configuré"
    else
        fail "subuid not configured for ${current_user}" \
             "${current_user} entry in /etc/subuid" \
             "not found" \
             "Exécutez: sudo usermod --add-subuids 100000-165535 ${current_user}"
    fi

    if grep -q "^${current_user}:" /etc/subgid 2>/dev/null; then
        pass "subgid configured for ${current_user} / subgid configuré"
    else
        fail "subgid not configured for ${current_user}" \
             "${current_user} entry in /etc/subgid" \
             "not found" \
             "Exécutez: sudo usermod --add-subgids 100000-165535 ${current_user}"
    fi

    # -------------------------------------------------------------------------
    # Step 6: Check Podman is not yet installed (lab 01 will install it)
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
