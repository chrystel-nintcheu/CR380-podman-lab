#!/usr/bin/env bash
# =============================================================================
# CR380 - Podman Lab — Teacher Validation / Validation enseignant
# =============================================================================
#
# FR: Script de validation rapide pour l'enseignant.
#     Exécute tous les tests sans interaction et affiche un résumé.
#
# EN: Quick validation script for the teacher.
#     Runs all tests without interaction and displays a summary.
#
# Usage:
#   ./run-teacher-validation.sh
#   ./run-teacher-validation.sh --lab 03
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

exec "${SCRIPT_DIR}/run-labs.sh" --validate "$@"
