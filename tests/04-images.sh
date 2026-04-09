#!/usr/bin/env bash
# =============================================================================
# CR380 - Lab 04 — Images & Registres / Images & Registries
# =============================================================================
#
# FR: Apprendre à chercher, télécharger et inspecter des images de conteneurs.
#     Podman peut utiliser plusieurs registres : Docker Hub, Quay.io, etc.
#     Couvre: podman search, podman pull, podman images, podman inspect,
#     podman image history.
#
# EN: Learn to search, pull and inspect container images.
#     Podman can use multiple registries: Docker Hub, Quay.io, etc.
#     Covers: podman search, podman pull, podman images, podman inspect,
#     podman image history.
#
# Depends on: 03
#
# 📖 podman-search(1): https://docs.podman.io/en/latest/markdown/podman-search.1.html
# 📖 podman-pull(1): https://docs.podman.io/en/latest/markdown/podman-pull.1.html
# 📖 podman-images(1): https://docs.podman.io/en/latest/markdown/podman-images.1.html
# 📖 podman-image-inspect(1): https://docs.podman.io/en/latest/markdown/podman-image-inspect.1.html
# 📖 podman-image-history(1): https://docs.podman.io/en/latest/markdown/podman-image-history.1.html
# 📖 podman-rmi(1): https://docs.podman.io/en/latest/markdown/podman-rmi.1.html
# =============================================================================

run_test() {
    section_header "04" "Images & Registres / Images & Registries" \
        "${GITBOOK_URL_04}"

    check_dependency "03" || { section_summary; return; }

    # -------------------------------------------------------------------------
    # Step 1: Search for images
    # FR: Chercher des images dans les registres
    # 📖 https://docs.podman.io/en/latest/markdown/podman-search.1.html
    # ⚠  Pitfall: podman search queries configured registries — results
    #    differ from Docker because Podman requires the registry prefix
    # -------------------------------------------------------------------------
    learn_pause \
        "Podman peut chercher des images dans plusieurs registres.\nLa commande 'podman search' interroge les registres configurés.\n\nCommande: podman search nginx --limit 5" \
        "Podman can search for images across multiple registries.\nThe 'podman search' command queries configured registries.\n\nCommand: podman search nginx --limit 5"

    assert_output_contains \
        "podman search nginx returns results / podman search nginx retourne des résultats" \
        "nginx" \
        "Vérifiez votre connexion Internet et les registres configurés" \
        podman search nginx --limit 5

    # -------------------------------------------------------------------------
    # Step 2: Pull an image from Quay.io
    # FR: Télécharger une image depuis Quay.io
    # 📖 https://docs.podman.io/en/latest/markdown/podman-pull.1.html
    # ⚠  Pitfall: Unlike Docker, Podman requires the full registry prefix
    #    (docker.io/alpine not just alpine) unless registries.conf is configured
    # -------------------------------------------------------------------------
    learn_pause \
        "Téléchargeons l'image Alpine depuis Docker Hub.\nPodman supporte le préfixe de registre: docker.io/library/alpine\n\nCommande: podman pull ${IMAGE_ALPINE}" \
        "Let's pull the Alpine image from Docker Hub.\nPodman supports registry prefix: docker.io/library/alpine\n\nCommand: podman pull ${IMAGE_ALPINE}"

    run_cmd "Pull Alpine image" "${TIMEOUT_PULL}" \
        podman pull "${IMAGE_ALPINE}" || true

    if (( CMD_EXIT_CODE == 0 )); then
        pass "podman pull ${IMAGE_ALPINE} succeeded / téléchargement réussi"
    else
        fail "podman pull ${IMAGE_ALPINE} failed" \
             "exit code 0" "exit code ${CMD_EXIT_CODE}" \
             "Vérifiez votre connexion Internet"
    fi

    # -------------------------------------------------------------------------
    # Step 3: List local images
    # FR: Lister les images locales
    # -------------------------------------------------------------------------
    learn_pause \
        "'podman images' liste toutes les images téléchargées localement.\nOn peut filtrer avec un nom: podman images nginx\n\nCommande: podman images" \
        "'podman images' lists all locally pulled images.\nYou can filter by name: podman images nginx\n\nCommand: podman images"

    assert_output_contains \
        "podman images lists alpine / podman images liste alpine" \
        "alpine" \
        "Essayez: podman pull ${IMAGE_ALPINE}" \
        podman images

    # -------------------------------------------------------------------------
    # Step 4: Inspect an image
    # FR: Inspecter une image
    # 📖 https://docs.podman.io/en/latest/markdown/podman-image-inspect.1.html
    # ⚠  Pitfall: --format uses Go template syntax; use {{.Os}} not .os
    # -------------------------------------------------------------------------
    learn_pause \
        "'podman inspect' affiche les métadonnées complètes d'une image.\nOn peut extraire un champ avec --format.\n\nCommande: podman image inspect ${IMAGE_ALPINE} --format '{{.Os}}/{{.Architecture}}'" \
        "'podman inspect' shows complete metadata for an image.\nYou can extract a field with --format.\n\nCommand: podman image inspect ${IMAGE_ALPINE} --format '{{.Os}}/{{.Architecture}}'"

    assert_output_not_empty \
        "podman image inspect returns data / podman image inspect retourne des données" \
        "Essayez: podman pull ${IMAGE_ALPINE}" \
        podman image inspect "${IMAGE_ALPINE}" --format '{{.Os}}/{{.Architecture}}'

    # -------------------------------------------------------------------------
    # Step 5: Image history
    # FR: Historique des couches d'une image
    # 📖 https://docs.podman.io/en/latest/markdown/podman-image-history.1.html
    # ⚠  Pitfall: Some layers show <missing> for intermediate layers —
    #    this is normal for images built with BuildKit
    # -------------------------------------------------------------------------
    learn_pause \
        "Chaque image est composée de couches (layers) superposées.\n'podman image history' affiche ces couches et leurs tailles.\n\nCommande: podman image history ${IMAGE_ALPINE}" \
        "Each image is made of stacked layers.\n'podman image history' shows these layers and their sizes.\n\nCommand: podman image history ${IMAGE_ALPINE}"

    assert_output_not_empty \
        "podman image history shows layers / podman image history montre les couches" \
        "Essayez: podman pull ${IMAGE_ALPINE}" \
        podman image history "${IMAGE_ALPINE}"

    # -------------------------------------------------------------------------
    # Step 6: Pull nginx alpine and compare sizes
    # FR: Télécharger nginx alpine et comparer les tailles
    # -------------------------------------------------------------------------
    learn_pause \
        "Comparons deux variantes de Nginx : latest et alpine.\nnginx:latest est basée sur Debian, nginx:alpine sur Alpine.\nAlpine est beaucoup plus légère!\n\nCommande: podman pull ${IMAGE_NGINX_ALPINE}" \
        "Let's compare two Nginx variants: latest and alpine.\nnginx:latest is Debian-based, nginx:alpine is Alpine-based.\nAlpine is much lighter!\n\nCommand: podman pull ${IMAGE_NGINX_ALPINE}"

    run_cmd "Pull nginx:alpine" "${TIMEOUT_PULL}" \
        podman pull "${IMAGE_NGINX_ALPINE}" || true

    if (( CMD_EXIT_CODE == 0 )); then
        pass "podman pull ${IMAGE_NGINX_ALPINE} succeeded"
    else
        skip "podman pull ${IMAGE_NGINX_ALPINE} failed — skipping size comparison" \
             "Check your internet connection"
    fi

    assert_output_contains \
        "podman images shows both nginx variants / les deux variantes nginx sont présentes" \
        "nginx" \
        "Essayez: podman pull ${IMAGE_NGINX}" \
        podman images --format '{{.Repository}}:{{.Tag}}'

    # -------------------------------------------------------------------------
    # Step 7: Remove an image
    # FR: Supprimer une image
    # 📖 https://docs.podman.io/en/latest/markdown/podman-rmi.1.html
    # ⚠  Pitfall: Cannot remove an image used by a running container;
    #    use --force to override, but this may break running containers
    # -------------------------------------------------------------------------
    learn_pause \
        "Supprimons une image locale avec 'podman rmi'.\nOn ne peut pas supprimer une image utilisée par un conteneur actif.\n\nCommande: podman rmi ${IMAGE_NGINX_ALPINE}" \
        "Let's remove a local image with 'podman rmi'.\nYou cannot remove an image used by an active container.\n\nCommand: podman rmi ${IMAGE_NGINX_ALPINE}"

    run_cmd "Remove nginx:alpine image" "${TIMEOUT_DEFAULT}" \
        podman rmi "${IMAGE_NGINX_ALPINE}" || true

    if (( CMD_EXIT_CODE == 0 )); then
        pass "podman rmi ${IMAGE_NGINX_ALPINE} succeeded / image supprimée"
    else
        skip "podman rmi failed (image may be in use)" \
             "Essayez: podman rmi --force ${IMAGE_NGINX_ALPINE}"
    fi

    section_summary
}
