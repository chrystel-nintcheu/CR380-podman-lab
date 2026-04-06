#!/usr/bin/env bash
# =============================================================================
# CR380 - Lab 99 — Nettoyage final / Final Teardown
# =============================================================================
#
# FR: Nettoyer tous les conteneurs, images, volumes et pods créés pendant les labs.
#     Ce lab peut être exécuté à tout moment pour remettre l'environnement à zéro.
#
# EN: Clean up all containers, images, volumes and pods created during the labs.
#     This lab can be run at any time to reset the environment.
#
# Depends on: (none — can always run)
# =============================================================================

run_test() {
    section_header "99" "Nettoyage final / Final Teardown" \
        "${GITBOOK_URL_99}"

    learn_pause \
        "Ce lab nettoie tous les artefacts créés pendant les labs:\n  - Conteneurs\n  - Pods\n  - Images construites\n  - Volumes\n\nAttention: les images téléchargées (pull) sont aussi supprimées." \
        "This lab cleans up all artifacts created during the labs:\n  - Containers\n  - Pods\n  - Built images\n  - Volumes\n\nWarning: pulled (downloaded) images are also removed."

    # -------------------------------------------------------------------------
    # Step 1: Stop and remove all containers
    # FR: Arrêter et supprimer tous les conteneurs
    # -------------------------------------------------------------------------
    learn_pause \
        "Supprimons tous les conteneurs de lab.\nCommande: podman rm -f <nom>" \
        "Let's remove all lab containers.\nCommand: podman rm -f <name>"

    local containers=(
        "${CT_ALPINE}"
        "${CT_NGINX}"
        "${CT_APP}"
        "${CT_VOL}"
        "${CT_POD_NGINX}"
        "${CT_POD_ALPINE}"
        "${CT_COMPOSE_NGINX}"
    )

    for ct in "${containers[@]}"; do
        if podman ps -a --format '{{.Names}}' 2>/dev/null | grep -qx "${ct}"; then
            run_cmd "Remove container ${ct}" "${TIMEOUT_DEFAULT}" \
                podman rm -f "${ct}" || true
            if (( CMD_EXIT_CODE == 0 )); then
                pass "Container '${ct}' removed / Conteneur '${ct}' supprimé"
            else
                fail "Failed to remove container '${ct}'" \
                     "removed" "still present" \
                     "Essayez: podman rm -f ${ct}"
            fi
        else
            pass "Container '${ct}' not present (already clean) / Déjà nettoyé"
        fi
    done

    # -------------------------------------------------------------------------
    # Step 2: Stop and remove pods
    # FR: Supprimer les pods
    # -------------------------------------------------------------------------
    learn_pause \
        "Supprimons le pod de lab.\nCommande: podman pod rm -f ${POD_NAME}" \
        "Let's remove the lab pod.\nCommand: podman pod rm -f ${POD_NAME}"

    if podman pod inspect "${POD_NAME}" &>/dev/null; then
        assert_success \
            "Pod '${POD_NAME}' removed / Pod '${POD_NAME}' supprimé" \
            "Essayez: podman pod rm -f ${POD_NAME}" \
            podman pod rm -f "${POD_NAME}"
    else
        pass "Pod '${POD_NAME}' not present (already clean) / Déjà nettoyé"
    fi

    # -------------------------------------------------------------------------
    # Step 3: Remove built images
    # FR: Supprimer les images construites
    # -------------------------------------------------------------------------
    learn_pause \
        "Supprimons les images construites pendant les labs.\nCommande: podman rmi -f <image>" \
        "Let's remove images built during the labs.\nCommand: podman rmi -f <image>"

    local images=("${IMG_BASE}" "${IMG_SLIM}")
    for img in "${images[@]}"; do
        if podman image inspect "${img}" &>/dev/null; then
            run_cmd "Remove image ${img}" "${TIMEOUT_DEFAULT}" \
                podman rmi -f "${img}" || true
            if (( CMD_EXIT_CODE == 0 )); then
                pass "Image '${img}' removed / Image '${img}' supprimée"
            else
                fail "Failed to remove image '${img}'" \
                     "removed" "still present" \
                     "Essayez: podman rmi -f ${img}"
            fi
        else
            pass "Image '${img}' not present (already clean) / Déjà nettoyée"
        fi
    done

    # -------------------------------------------------------------------------
    # Step 4: Remove volumes
    # FR: Supprimer les volumes
    # -------------------------------------------------------------------------
    learn_pause \
        "Supprimons les volumes créés pendant les labs.\nCommande: podman volume rm ${VOL_NAME}" \
        "Let's remove volumes created during the labs.\nCommand: podman volume rm ${VOL_NAME}"

    if podman volume inspect "${VOL_NAME}" &>/dev/null; then
        assert_success \
            "Volume '${VOL_NAME}' removed / Volume '${VOL_NAME}' supprimé" \
            "Essayez: podman volume rm ${VOL_NAME}" \
            podman volume rm "${VOL_NAME}"
    else
        pass "Volume '${VOL_NAME}' not present (already clean) / Déjà nettoyé"
    fi

    # -------------------------------------------------------------------------
    # Step 5: Prune unused resources (optional)
    # FR: Nettoyer les ressources inutilisées (optionnel)
    # -------------------------------------------------------------------------
    learn_pause \
        "'podman system prune' supprime les ressources non utilisées:\n  - Conteneurs arrêtés\n  - Images sans tag (dangling)\n  - Réseaux non utilisés\n\nCommande: podman system prune -f" \
        "'podman system prune' removes unused resources:\n  - Stopped containers\n  - Untagged (dangling) images\n  - Unused networks\n\nCommand: podman system prune -f"

    run_cmd "podman system prune" "${TIMEOUT_DEFAULT}" \
        podman system prune -f || true

    if (( CMD_EXIT_CODE == 0 )); then
        pass "podman system prune succeeded / nettoyage système réussi"
    else
        skip "podman system prune had non-zero exit (may be OK)" \
             "Nothing to prune / Rien à nettoyer"
    fi

    # -------------------------------------------------------------------------
    # Final check
    # FR: Vérification finale
    # -------------------------------------------------------------------------
    learn_pause \
        "Vérification finale: l'environnement est propre." \
        "Final check: the environment is clean."

    local remaining_cts
    remaining_cts=$(podman ps -a --format '{{.Names}}' 2>/dev/null | \
        grep -E "^(${CT_ALPINE}|${CT_NGINX}|${CT_APP}|${CT_VOL}|${CT_POD_NGINX}|${CT_COMPOSE_NGINX})$" || true)

    if [[ -z "${remaining_cts}" ]]; then
        pass "All lab containers removed / Tous les conteneurs de lab supprimés"
    else
        fail "Some lab containers remain / Des conteneurs de lab restent" \
             "no lab containers" "${remaining_cts}" \
             "Essayez: podman rm -f ${remaining_cts}"
    fi

    section_summary
}
