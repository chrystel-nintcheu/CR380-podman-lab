#!/usr/bin/env bash
# =============================================================================
# CR380 - Lab 06 — Volumes & Persistance / Volumes & Persistence
# =============================================================================
#
# FR: Gérer la persistance des données avec Podman.
#     Par défaut, les données dans un conteneur sont perdues à sa suppression.
#     Les volumes et les bind mounts permettent de persister les données.
#     Couvre: podman volume create, podman run -v, bind mount, podman volume ls.
#
# EN: Manage data persistence with Podman.
#     By default, data inside a container is lost when it is removed.
#     Volumes and bind mounts allow persisting data.
#     Covers: podman volume create, podman run -v, bind mount, podman volume ls.
#
# Depends on: 05
#
# 📖 podman-volume-create(1): https://docs.podman.io/en/latest/markdown/podman-volume-create.1.html
# 📖 podman-volume-inspect(1): https://docs.podman.io/en/latest/markdown/podman-volume-inspect.1.html
# 📖 podman-volume-ls(1): https://docs.podman.io/en/latest/markdown/podman-volume-ls.1.html
# 📖 podman-volume-rm(1): https://docs.podman.io/en/latest/markdown/podman-volume-rm.1.html
# 📖 podman-run -v: https://docs.podman.io/en/latest/markdown/podman-run.1.html#volume
# =============================================================================

run_test() {
    section_header "06" "Volumes & Persistance / Volumes & Persistence" \
        "${GITBOOK_URL_06}"

    check_dependency "05" || { section_summary; return; }

    # Cleanup
    cleanup_container "${CT_VOL}"
    cleanup_volume "${VOL_NAME}"

    # -------------------------------------------------------------------------
    # Step 1: Create a named volume
    # FR: Créer un volume nommé
    # 📖 https://docs.podman.io/en/latest/markdown/podman-volume-create.1.html
    # ⚠  Pitfall: Rootless volumes are stored in ~/.local/share/containers/
    #    storage/volumes/ — not in /var/lib like rootful Podman
    # -------------------------------------------------------------------------
    learn_pause \
        "Créons un volume nommé avec 'podman volume create'.\nLes volumes nommés sont gérés par Podman et persistent indépendamment\ndes conteneurs.\n\nCommande: podman volume create ${VOL_NAME}" \
        "Let's create a named volume with 'podman volume create'.\nNamed volumes are managed by Podman and persist independently\nfrom containers.\n\nCommand: podman volume create ${VOL_NAME}"

    assert_success \
        "podman volume create ${VOL_NAME}" \
        "Essayez: podman volume create ${VOL_NAME}" \
        podman volume create "${VOL_NAME}"

    assert_volume_exists "${VOL_NAME}"

    # -------------------------------------------------------------------------
    # Step 2: Inspect the volume
    # FR: Inspecter le volume
    # -------------------------------------------------------------------------
    learn_pause \
        "'podman volume inspect' affiche les détails d'un volume.\nNote: le chemin 'Mountpoint' est l'emplacement réel sur l'hôte.\n\nCommande: podman volume inspect ${VOL_NAME}" \
        "'podman volume inspect' shows volume details.\nNote: the 'Mountpoint' is the actual location on the host.\n\nCommand: podman volume inspect ${VOL_NAME}"

    assert_output_contains \
        "podman volume inspect shows Mountpoint / podman volume inspect affiche le point de montage" \
        "Mountpoint" \
        "Essayez: podman volume create ${VOL_NAME}" \
        podman volume inspect "${VOL_NAME}"

    # -------------------------------------------------------------------------
    # Step 3: List volumes
    # FR: Lister les volumes
    # -------------------------------------------------------------------------
    learn_pause \
        "'podman volume ls' liste tous les volumes Podman.\nCommande: podman volume ls" \
        "'podman volume ls' lists all Podman volumes.\nCommand: podman volume ls"

    assert_output_contains \
        "podman volume ls shows ${VOL_NAME}" \
        "${VOL_NAME}" \
        "Essayez: podman volume create ${VOL_NAME}" \
        podman volume ls

    # -------------------------------------------------------------------------
    # Step 4: Write data to volume via a container
    # FR: Écrire des données dans le volume via un conteneur
    # 📖 https://docs.podman.io/en/latest/markdown/podman-run.1.html#volume
    #    -v syntax: <source>:<destination>[:<options>]
    # ⚠  Pitfall: Forgetting --rm creates stopped containers that pile up
    # -------------------------------------------------------------------------
    learn_pause \
        "Écrivons des données dans le volume via un conteneur.\nLe dossier ${VOL_MOUNT} dans le conteneur est monté sur notre volume.\n\nCommande: podman run --rm -v ${VOL_NAME}:${VOL_MOUNT} ${IMAGE_ALPINE} \\\n    sh -c 'echo \"Hello Podman Volume\" > ${VOL_MOUNT}/test.txt'" \
        "Let's write data to the volume via a container.\nThe ${VOL_MOUNT} folder inside the container is mounted on our volume.\n\nCommand: podman run --rm -v ${VOL_NAME}:${VOL_MOUNT} ${IMAGE_ALPINE} \\\n    sh -c 'echo \"Hello Podman Volume\" > ${VOL_MOUNT}/test.txt'"

    assert_success \
        "Write data to volume / Écriture dans le volume" \
        "Vérifiez que le volume existe: podman volume ls" \
        podman run --rm -v "${VOL_NAME}:${VOL_MOUNT}" "${IMAGE_ALPINE}" \
            sh -c "echo 'Hello Podman Volume' > ${VOL_MOUNT}/test.txt"

    # -------------------------------------------------------------------------
    # Step 5: Read data from volume in a new container
    # FR: Lire les données depuis un nouveau conteneur
    # -------------------------------------------------------------------------
    learn_pause \
        "Lisons les données depuis un second conteneur.\nCela prouve que les données persistent entre les conteneurs.\n\nCommande: podman run --rm -v ${VOL_NAME}:${VOL_MOUNT} ${IMAGE_ALPINE} \\\n    cat ${VOL_MOUNT}/test.txt" \
        "Let's read the data from a second container.\nThis proves that data persists across containers.\n\nCommand: podman run --rm -v ${VOL_NAME}:${VOL_MOUNT} ${IMAGE_ALPINE} \\\n    cat ${VOL_MOUNT}/test.txt"

    assert_output_contains \
        "Data persists in volume / Les données persistent dans le volume" \
        "Hello Podman Volume" \
        "Vérifiez les étapes précédentes" \
        podman run --rm -v "${VOL_NAME}:${VOL_MOUNT}" "${IMAGE_ALPINE}" \
            cat "${VOL_MOUNT}/test.txt"

    # -------------------------------------------------------------------------
    # Step 6: Bind mount — mount a host directory
    # FR: Bind mount — monter un répertoire de l'hôte
    # 📖 https://docs.podman.io/en/latest/markdown/podman-run.1.html#volume
    #    Options: ro (read-only), rw (default), z/Z (SELinux relabel)
    # ⚠  Pitfall: On SELinux-enabled hosts, bind mounts may fail without
    #    :z (shared) or :Z (private) suffix. Ubuntu uses AppArmor by
    #    default, so this is mainly relevant for RHEL/Fedora.
    # -------------------------------------------------------------------------
    learn_pause \
        "Un 'bind mount' monte un dossier de l'hôte directement dans le conteneur.\nC'est utile pour le développement (code source, configuration).\n\nCommande: podman run --rm -v /tmp:/mnt/host:ro ${IMAGE_ALPINE} ls /mnt/host" \
        "A 'bind mount' mounts a host directory directly into the container.\nThis is useful for development (source code, configuration).\n\nCommand: podman run --rm -v /tmp:/mnt/host:ro ${IMAGE_ALPINE} ls /mnt/host"

    assert_success \
        "Bind mount /tmp into container / Bind mount /tmp dans le conteneur" \
        "Vérifiez les permissions sur /tmp" \
        podman run --rm -v /tmp:/mnt/host:ro "${IMAGE_ALPINE}" ls /mnt/host

    # -------------------------------------------------------------------------
    # Cleanup
    # FR: Nettoyage
    # -------------------------------------------------------------------------
    learn_pause \
        "Supprimons le volume.\nNote: on ne peut pas supprimer un volume utilisé par un conteneur.\n\nCommande: podman volume rm ${VOL_NAME}" \
        "Let's remove the volume.\nNote: you cannot remove a volume used by a container.\n\nCommand: podman volume rm ${VOL_NAME}"

    assert_success \
        "podman volume rm ${VOL_NAME}" \
        "Essayez: podman volume rm ${VOL_NAME}" \
        podman volume rm "${VOL_NAME}"

    section_summary
}
