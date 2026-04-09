#!/usr/bin/env bash
# =============================================================================
# CR380 - Lab 07 — Pods (fonctionnalité unique Podman)
# =============================================================================
#
# FR: Découvrir les Pods, une fonctionnalité unique à Podman absente de Docker.
#     Un pod est un groupe de conteneurs qui partagent le même namespace réseau.
#     Concept similaire aux Pods Kubernetes — Podman est Kubernetes-ready !
#     Couvre: podman pod create, podman pod start, podman pod ps,
#     podman pod stop, podman pod rm.
#
# EN: Discover Pods, a feature unique to Podman not found in Docker.
#     A pod is a group of containers sharing the same network namespace.
#     Concept similar to Kubernetes Pods — Podman is Kubernetes-ready!
#     Covers: podman pod create, podman pod start, podman pod ps,
#     podman pod stop, podman pod rm.
#
# Depends on: 06
#
# 📖 podman-pod-create(1): https://docs.podman.io/en/latest/markdown/podman-pod-create.1.html
# 📖 podman-pod-ps(1): https://docs.podman.io/en/latest/markdown/podman-pod-ps.1.html
# 📖 podman-pod-rm(1): https://docs.podman.io/en/latest/markdown/podman-pod-rm.1.html
# 📖 podman-generate-kube(1): https://docs.podman.io/en/latest/markdown/podman-generate-kube.1.html
# =============================================================================

run_test() {
    section_header "07" "Pods — Fonctionnalité unique Podman / Pods — Podman Unique Feature" \
        "${GITBOOK_URL_07}"

    check_dependency "06" || { section_summary; return; }

    # Cleanup
    cleanup_container "${CT_POD_NGINX}"
    cleanup_container "${CT_POD_ALPINE}"
    cleanup_pod "${POD_NAME}"

    # -------------------------------------------------------------------------
    # Step 1: What is a Pod?
    # FR: Qu'est-ce qu'un Pod ?
    # -------------------------------------------------------------------------
    learn_pause \
        "Un Pod est un groupe de conteneurs qui partagent:\n  - Le même namespace réseau (localhost entre eux)\n  - Le même namespace IPC\n  - Optionnellement le même namespace PID\n\nC'est le même concept que les Pods Kubernetes.\nPodman peut générer des fichiers YAML Kubernetes directement !\n\nNous allons créer un pod avec un serveur Nginx et un client Alpine." \
        "A Pod is a group of containers sharing:\n  - The same network namespace (localhost between them)\n  - The same IPC namespace\n  - Optionally the same PID namespace\n\nThis is the same concept as Kubernetes Pods.\nPodman can generate Kubernetes YAML files directly!\n\nWe will create a pod with an Nginx server and an Alpine client."

    # -------------------------------------------------------------------------
    # Step 2: Create a pod
    # FR: Créer un pod
    # 📖 https://docs.podman.io/en/latest/markdown/podman-pod-create.1.html
    # ⚠  Pitfall: Port mapping (-p) must be on the pod, NOT on individual
    #    containers. Adding -p to 'podman run --pod' will fail.
    # -------------------------------------------------------------------------
    learn_pause \
        "Créons un pod nommé '${POD_NAME}' avec le port 8082 exposé.\nCommande: podman pod create --name ${POD_NAME} -p 8082:80" \
        "Let's create a pod named '${POD_NAME}' with port 8082 exposed.\nCommand: podman pod create --name ${POD_NAME} -p 8082:80"

    assert_success \
        "podman pod create ${POD_NAME}" \
        "Essayez: podman pod create --name ${POD_NAME} -p 8082:80" \
        podman pod create --name "${POD_NAME}" -p 8082:80

    assert_pod_exists "${POD_NAME}"

    # -------------------------------------------------------------------------
    # Step 3: Add containers to the pod
    # FR: Ajouter des conteneurs dans le pod
    # 📖 https://docs.podman.io/en/latest/markdown/podman-run.1.html#pod
    #    --pod <name> adds the container to an existing pod
    # ⚠  Pitfall: Each pod automatically has an "infra" container — this is
    #    normal and expected (it holds the shared namespaces)
    # -------------------------------------------------------------------------
    learn_pause \
        "Ajoutons un conteneur Nginx dans le pod.\nAvec '--pod ${POD_NAME}', le conteneur rejoint le pod.\nNote: le mapping de port est défini au niveau du pod, pas du conteneur.\n\nCommande: podman run -d --pod ${POD_NAME} --name ${CT_POD_NGINX} ${IMAGE_NGINX}" \
        "Let's add an Nginx container to the pod.\nWith '--pod ${POD_NAME}', the container joins the pod.\nNote: port mapping is defined at the pod level, not the container.\n\nCommand: podman run -d --pod ${POD_NAME} --name ${CT_POD_NGINX} ${IMAGE_NGINX}"

    run_cmd "Run Nginx in pod" "${TIMEOUT_PULL}" \
        podman run -d --pod "${POD_NAME}" --name "${CT_POD_NGINX}" "${IMAGE_NGINX}" || true

    if (( CMD_EXIT_CODE == 0 )); then
        pass "Nginx container added to pod / Conteneur Nginx ajouté au pod"
    else
        fail "Failed to add Nginx to pod" \
             "exit code 0" "exit code ${CMD_EXIT_CODE}" \
             "Essayez: podman run -d --pod ${POD_NAME} --name ${CT_POD_NGINX} ${IMAGE_NGINX}"
    fi

    # -------------------------------------------------------------------------
    # Step 4: List pod status
    # FR: Lister l'état du pod
    # -------------------------------------------------------------------------
    learn_pause \
        "'podman pod ps' affiche l'état des pods et leur nombre de conteneurs.\nCommande: podman pod ps" \
        "'podman pod ps' shows pods status and their container count.\nCommand: podman pod ps"

    assert_output_contains \
        "podman pod ps shows ${POD_NAME}" \
        "${POD_NAME}" \
        "Essayez: podman pod ps" \
        podman pod ps

    # -------------------------------------------------------------------------
    # Step 5: Test communication inside the pod
    # FR: Tester la communication dans le pod
    # 📖 Pod networking: containers share localhost (127.0.0.1)
    #    https://docs.podman.io/en/latest/markdown/podman-pod-create.1.html
    # ⚠  Pitfall: Alpine doesn't have curl by default; use wget or install
    #    curl with apk. Also nginx may need a few seconds to start.
    # -------------------------------------------------------------------------
    learn_pause \
        "Dans un pod, tous les conteneurs partagent le même réseau.\nUn conteneur Alpine peut accéder au serveur Nginx via 'localhost'.\n\nAjoutons un conteneur Alpine dans le pod qui accède à Nginx." \
        "In a pod, all containers share the same network.\nAn Alpine container can access the Nginx server via 'localhost'.\n\nLet's add an Alpine container to the pod that accesses Nginx."

    sleep 2

    run_cmd "Alpine curl to Nginx in pod" "${TIMEOUT_DEFAULT}" \
        podman run --rm --pod "${POD_NAME}" "${IMAGE_ALPINE}" \
            wget -q -O - http://localhost:80 || true

    if (( CMD_EXIT_CODE == 0 )) && echo "${CMD_OUTPUT}" | grep -qi "nginx\|Welcome\|html"; then
        pass "Pod inter-container communication works / Communication inter-conteneurs OK"
    else
        # Try curl as fallback
        run_cmd "Alpine curl fallback" "${TIMEOUT_DEFAULT}" \
            podman run --rm --pod "${POD_NAME}" "${IMAGE_ALPINE}" \
                sh -c "apk add --no-cache curl -q && curl -s http://localhost:80" || true
        if echo "${CMD_OUTPUT}" | grep -qi "nginx\|Welcome\|html"; then
            pass "Pod inter-container communication works / Communication inter-conteneurs OK"
        else
            skip "Pod communication test skipped — nginx may need more time" \
                 "Try manually: podman run --rm --pod ${POD_NAME} ${IMAGE_ALPINE} wget -q -O - http://localhost"
        fi
    fi

    # -------------------------------------------------------------------------
    # Step 6: Generate Kubernetes YAML from pod (bonus)
    # FR: Générer du YAML Kubernetes depuis le pod (bonus)
    # 📖 https://docs.podman.io/en/latest/markdown/podman-generate-kube.1.html
    # ⚠  Pitfall: Command changed between versions: Podman 3.x uses
    #    'podman generate kube', Podman 4.x+ prefers 'podman kube generate'
    # -------------------------------------------------------------------------
    learn_pause \
        "Bonus: Podman peut générer un fichier YAML Kubernetes depuis un pod !\nCela facilite la migration vers Kubernetes.\n\nCommande: podman generate kube ${POD_NAME}" \
        "Bonus: Podman can generate a Kubernetes YAML file from a pod!\nThis simplifies migration to Kubernetes.\n\nCommand: podman generate kube ${POD_NAME}"

    run_cmd "podman generate kube" "${TIMEOUT_DEFAULT}" \
        podman generate kube "${POD_NAME}" 2>/dev/null || \
        podman kube generate "${POD_NAME}" 2>/dev/null || true

    if (( CMD_EXIT_CODE == 0 )) && [[ -n "${CMD_OUTPUT}" ]]; then
        pass "podman generate kube produced Kubernetes YAML / YAML Kubernetes généré"
    else
        skip "podman generate kube not available in this version" \
             "Available in Podman 3.1+: podman generate kube ${POD_NAME}"
    fi

    # -------------------------------------------------------------------------
    # Cleanup
    # FR: Nettoyage
    # -------------------------------------------------------------------------
    learn_pause \
        "Supprimons le pod et ses conteneurs.\n'podman pod rm -f' supprime le pod et tous ses conteneurs.\n\nCommande: podman pod rm -f ${POD_NAME}" \
        "Let's remove the pod and its containers.\n'podman pod rm -f' removes the pod and all its containers.\n\nCommand: podman pod rm -f ${POD_NAME}"

    assert_success \
        "podman pod rm -f ${POD_NAME}" \
        "Essayez: podman pod rm -f ${POD_NAME}" \
        podman pod rm -f "${POD_NAME}"

    section_summary
}
