#!/usr/bin/env bash
# =============================================================================
# CR380 - Lab 01 — Installation de Podman / Podman Installation
# =============================================================================
#
# FR: Installer Podman sur Ubuntu via le gestionnaire de paquets APT.
#     Podman est un moteur de conteneurs sans démon, compatible avec Docker.
#     Il n'a pas besoin de root pour lancer des conteneurs (mode rootless).
#
# EN: Install Podman on Ubuntu via the APT package manager.
#     Podman is a daemonless container engine, compatible with Docker.
#     It does not need root to run containers (rootless mode).
#
# Depends on: 00
#
# 📖 Installation guide: https://docs.podman.io/en/latest/installation.html
# 📖 podman(1): https://docs.podman.io/en/latest/markdown/podman.1.html
# 📖 podman-compose: https://github.com/containers/podman-compose
# =============================================================================

run_test() {
    section_header "01" "Installation de Podman / Podman Installation" \
        "${GITBOOK_URL_01}"

    check_dependency "00" || { section_summary; return; }

    # -------------------------------------------------------------------------
    # Step 1: Skip if Podman is already installed
    # FR: Ignorer si Podman est déjà installé
    # -------------------------------------------------------------------------
    if command -v podman &>/dev/null; then
        local ver
        ver=$(podman --version 2>/dev/null)
        pass "Podman already installed: ${ver} / Podman déjà installé"
        section_summary
        return
    fi

    # -------------------------------------------------------------------------
    # Step 2: Update APT package list
    # FR: Mettre à jour la liste des paquets APT
    # 📖 https://docs.podman.io/en/latest/installation.html#ubuntu
    # ⚠  Pitfall: Stale APT cache can install older Podman versions
    # -------------------------------------------------------------------------
    learn_pause \
        "Avant d'installer Podman, nous mettons à jour la liste des paquets.\nCommande: sudo apt-get update" \
        "Before installing Podman, we update the package list.\nCommand: sudo apt-get update"

    assert_success \
        "apt-get update succeeds / apt-get update réussi" \
        "Vérifiez votre connexion Internet / Check your Internet connection" \
        sudo apt-get update -y

    # -------------------------------------------------------------------------
    # Step 3: Install Podman
    # FR: Installer Podman
    # 📖 https://docs.podman.io/en/latest/installation.html#ubuntu
    # ⚠  Pitfall: Ubuntu 22.04 ships Podman 3.x; 24.04 ships 4.x+ with
    #    different features (e.g., podman machine, quadlet support)
    # -------------------------------------------------------------------------
    learn_pause \
        "Installation de Podman.\nSur Ubuntu, Podman est disponible dans les dépôts officiels.\nCommande: sudo apt-get install -y podman" \
        "Installing Podman.\nOn Ubuntu, Podman is available in the official repositories.\nCommand: sudo apt-get install -y podman"

    run_cmd "Install podman" "${TIMEOUT_APT}" \
        sudo apt-get install -y podman || true

    if (( CMD_EXIT_CODE == 0 )); then
        pass "podman package installed / paquet podman installé"
    else
        fail "podman installation failed" \
             "exit code 0" "exit code ${CMD_EXIT_CODE}" \
             "Essayez: sudo apt-get install -y podman"
    fi

    # -------------------------------------------------------------------------
    # Step 4: Verify podman command is available
    # FR: Vérifier que la commande podman est disponible
    # -------------------------------------------------------------------------
    learn_pause \
        "Vérifions que Podman est bien installé avec 'podman --version'." \
        "Let's verify Podman is installed with 'podman --version'."

    assert_output_contains \
        "podman command available / commande podman disponible" \
        "podman version" \
        "Relancez l'installation: sudo apt-get install -y podman" \
        podman --version

    # -------------------------------------------------------------------------
    # Step 5: Install podman-compose
    # FR: Installer podman-compose pour les labs Compose
    # 📖 https://github.com/containers/podman-compose#installation
    # ⚠  Pitfall: pip3 install puts binary in ~/.local/bin which may not
    #    be in PATH. Verify with: echo $PATH | tr ':' '\n' | grep local
    # -------------------------------------------------------------------------
    learn_pause \
        "Nous installons aussi podman-compose pour les labs Podman Compose.\nCommande: sudo apt-get install -y podman-compose\n\nSi indisponible dans APT, on utilisera pip3:\n  sudo apt-get install -y python3-pip\n  pip3 install podman-compose" \
        "We also install podman-compose for the Podman Compose labs.\nCommand: sudo apt-get install -y podman-compose\n\nIf not available in APT, we use pip3:\n  sudo apt-get install -y python3-pip\n  pip3 install podman-compose"

    # Try apt first, fall back to pip3
    run_cmd "Install podman-compose via apt" "${TIMEOUT_APT}" \
        sudo apt-get install -y podman-compose || true

    if (( CMD_EXIT_CODE != 0 )); then
        run_cmd "Install python3-pip" "${TIMEOUT_APT}" \
            sudo apt-get install -y python3-pip || true
        run_cmd "Install podman-compose via pip3" "${TIMEOUT_APT}" \
            pip3 install podman-compose || true
        # Ensure ~/.local/bin is in PATH (pip3 installs there)
        if [[ -d "${HOME}/.local/bin" ]] && ! echo "${PATH}" | grep -q "${HOME}/.local/bin"; then
            export PATH="${HOME}/.local/bin:${PATH}"
        fi
    fi

    if command -v podman-compose &>/dev/null; then
        pass "podman-compose installed / podman-compose installé"
    else
        skip "podman-compose not available — lab 08 may be skipped" \
             "Install manually: pip3 install podman-compose"
    fi

    section_summary
}
