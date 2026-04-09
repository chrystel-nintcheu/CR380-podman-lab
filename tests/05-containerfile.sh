#!/usr/bin/env bash
# =============================================================================
# CR380 - Lab 05 — Containerfile & Construction d'images / Containerfile & Image Build
# =============================================================================
#
# FR: Construire une image personnalisée avec Podman et un Containerfile.
#     Le Containerfile est l'équivalent Podman du Dockerfile — ils sont
#     interchangeables. Podman accepte les deux noms de fichier.
#     Couvre: écrire un Containerfile, podman build, podman run l'image.
#
# EN: Build a custom image with Podman and a Containerfile.
#     The Containerfile is Podman's equivalent of Dockerfile — they are
#     interchangeable. Podman accepts both file names.
#     Covers: writing a Containerfile, podman build, podman run the image.
#
# Depends on: 04
#
# 📖 podman-build(1): https://docs.podman.io/en/latest/markdown/podman-build.1.html
# 📖 Containerfile reference: https://docs.podman.io/en/latest/markdown/podman-build.1.html#containerfile
# 📖 podman-image-inspect(1): https://docs.podman.io/en/latest/markdown/podman-image-inspect.1.html
# 📖 podman-image-history(1): https://docs.podman.io/en/latest/markdown/podman-image-history.1.html
# =============================================================================

run_test() {
    section_header "05" "Containerfile & Construction d'images / Image Build" \
        "${GITBOOK_URL_05}"

    check_dependency "04" || { section_summary; return; }

    # Cleanup
    cleanup_container "${CT_APP}"
    cleanup_image "${IMG_BASE}"

    local cf="${CONTAINERFILES_DIR}/containerfile-base"

    # -------------------------------------------------------------------------
    # Step 1: Verify the Containerfile exists
    # FR: Vérifier que le Containerfile existe
    # 📖 Containerfile vs Dockerfile: both are OCI-compatible. Podman
    #    searches for 'Containerfile' first, then 'Dockerfile'.
    #    https://docs.podman.io/en/latest/markdown/podman-build.1.html
    # ⚠  Pitfall: Build context (.) must contain or reference the Containerfile
    # -------------------------------------------------------------------------
    learn_pause \
        "Un Containerfile (ou Dockerfile) décrit comment construire une image.\nIl contient des instructions comme FROM, RUN, COPY, EXPOSE, CMD.\n\nNous allons utiliser: ${cf}" \
        "A Containerfile (or Dockerfile) describes how to build an image.\nIt contains instructions like FROM, RUN, COPY, EXPOSE, CMD.\n\nWe will use: ${cf}"

    if [[ -f "${cf}" ]]; then
        pass "Containerfile found / Containerfile trouvé: ${cf}"
    else
        fail "Containerfile not found / Containerfile introuvable" \
             "file at ${cf}" "not found" \
             "Vérifiez que le fichier ${cf} existe dans le dépôt"
        section_summary
        return
    fi

    # Show the Containerfile content
    learn_pause \
        "Contenu du Containerfile:\n$(cat "${cf}")" \
        "Containerfile content:\n$(cat "${cf}")"

    # -------------------------------------------------------------------------
    # Step 2: Build the image
    # FR: Construire l'image
    # 📖 https://docs.podman.io/en/latest/markdown/podman-build.1.html
    #    -t: tag the image, -f: specify Containerfile path
    # ⚠  Pitfall: Large build context slows builds; use .containerignore
    #    to exclude unnecessary files (like .git, node_modules)
    # -------------------------------------------------------------------------
    learn_pause \
        "Construisons l'image avec 'podman build'.\n  -t  : tag de l'image (nom:version)\n  -f  : chemin vers le Containerfile\n  .   : contexte de construction (dossier courant)\n\nCommande: podman build -t ${IMG_BASE} -f ${cf} ${PROJECT_DIR}" \
        "Let's build the image with 'podman build'.\n  -t  : image tag (name:version)\n  -f  : path to the Containerfile\n  .   : build context (current folder)\n\nCommand: podman build -t ${IMG_BASE} -f ${cf} ${PROJECT_DIR}"

    run_cmd "Build image ${IMG_BASE}" "${TIMEOUT_BUILD}" \
        podman build -t "${IMG_BASE}" -f "${cf}" "${PROJECT_DIR}" || true

    if (( CMD_EXIT_CODE == 0 )); then
        pass "podman build succeeded / construction réussie: ${IMG_BASE}"
    else
        fail "podman build failed" \
             "exit code 0" "exit code ${CMD_EXIT_CODE}" \
             "Vérifiez le Containerfile: ${cf}"
        section_summary
        return
    fi

    # -------------------------------------------------------------------------
    # Step 3: Verify the image was created
    # FR: Vérifier que l'image a été créée
    # -------------------------------------------------------------------------
    learn_pause \
        "Vérifions que l'image est bien dans le stockage local Podman.\nCommande: podman images ${IMG_BASE}" \
        "Let's verify the image is in Podman's local storage.\nCommand: podman images ${IMG_BASE}"

    assert_image_exists "${IMG_BASE}"

    assert_output_contains \
        "podman images shows ${IMG_BASE}" \
        "monimage" \
        "Essayez: podman build -t ${IMG_BASE} -f ${cf} ${PROJECT_DIR}" \
        podman images --format '{{.Repository}}:{{.Tag}}'

    # -------------------------------------------------------------------------
    # Step 4: Inspect the built image
    # FR: Inspecter l'image construite
    # -------------------------------------------------------------------------
    learn_pause \
        "Inspectons les métadonnées de l'image construite.\nCommande: podman image inspect ${IMG_BASE} --format '{{.Config.Cmd}}'" \
        "Let's inspect the built image metadata.\nCommand: podman image inspect ${IMG_BASE} --format '{{.Config.Cmd}}'"

    assert_output_not_empty \
        "podman inspect shows image config / podman inspect montre la config" \
        "Essayez: podman image inspect ${IMG_BASE}" \
        podman image inspect "${IMG_BASE}" --format '{{.Config.Cmd}}'

    # -------------------------------------------------------------------------
    # Step 5: Run a container from the built image
    # FR: Lancer un conteneur depuis l'image construite
    # 📖 https://docs.podman.io/en/latest/markdown/podman-run.1.html
    # ⚠  Pitfall: Port conflict if previous lab's container still runs on
    #    same port; cleanup_container at top handles this
    # -------------------------------------------------------------------------
    learn_pause \
        "Lançons un conteneur depuis notre image personnalisée.\nCommande: podman run --rm --name ${CT_APP} -p ${PORT_APP}:80 ${IMG_BASE}" \
        "Let's run a container from our custom image.\nCommand: podman run --rm --name ${CT_APP} -p ${PORT_APP}:80 ${IMG_BASE}"

    run_cmd "Run container from built image" "${TIMEOUT_CONTAINER_READY}" \
        podman run --rm --name "${CT_APP}" -p "${PORT_APP}:80" -d "${IMG_BASE}" || true

    if (( CMD_EXIT_CODE == 0 )); then
        pass "Container '${CT_APP}' started from custom image / Conteneur démarré"
        sleep 2
        assert_http_reachable "http://localhost:${PORT_APP}" 200
        cleanup_container "${CT_APP}"
    else
        skip "Container failed to start — checking image build only" \
             "The image was built successfully; run manually: podman run -p ${PORT_APP}:80 ${IMG_BASE}"
    fi

    # -------------------------------------------------------------------------
    # Step 6: Image history — see the layers
    # FR: Historique de l'image — voir les couches
    # -------------------------------------------------------------------------
    learn_pause \
        "Chaque instruction RUN, COPY, ADD dans le Containerfile crée une couche.\n'podman image history' les affiche avec leurs tailles.\n\nCommande: podman image history ${IMG_BASE}" \
        "Each RUN, COPY, ADD instruction in the Containerfile creates a layer.\n'podman image history' shows them with their sizes.\n\nCommand: podman image history ${IMG_BASE}"

    assert_output_not_empty \
        "podman image history shows layers / les couches sont visibles" \
        "Essayez: podman image history ${IMG_BASE}" \
        podman image history "${IMG_BASE}"

    section_summary
}
