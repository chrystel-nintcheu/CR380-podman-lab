#!/usr/bin/env bash
# =============================================================================
# CR380 - Podman Lab Test Suite — Master Runner / Lanceur principal
# =============================================================================
#
# FR: Script principal qui orchestre l'exécution de tous les tests de lab.
#     Supporte plusieurs modes d'exécution pour enseignants et étudiants.
#
# EN: Main script that orchestrates the execution of all lab tests.
#     Supports multiple execution modes for teachers and students.
#
# Usage:
#   ./run-labs.sh                    # Default: validate mode (teacher)
#   ./run-labs.sh --validate         # Same as default
#   ./run-labs.sh --learn            # Student mode: interactive, with pauses
#   ./run-labs.sh --lab 03           # Run only lab 03
#   ./run-labs.sh --reset 05         # Cleanup + rerun lab 05
#   ./run-labs.sh --quick            # Skip install if podman present
#   ./run-labs.sh --diff             # Compare last two reports
#   ./run-labs.sh --verbose          # Show full command output
#   ./run-labs.sh --learn --lab 03   # Combine: learn mode on lab 03 only
#
# =============================================================================

# Resolve paths
RUNNER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TESTS_DIR="${RUNNER_DIR}/tests"

# =============================================================================
# PARSE ARGUMENTS / ANALYSE DES ARGUMENTS
# =============================================================================

# Defaults
export MODE="validate"
export VERBOSE=1
RUN_LAB=""
RESET_LAB=""
QUICK_MODE=false
DIFF_ONLY=false

usage() {
    cat <<'USAGE'
CR380 - Podman Lab Test Suite

Usage: ./run-labs.sh [OPTIONS]

Modes:
  --validate        Mode enseignant (défaut): exécution rapide, résumé à la fin
                    Teacher mode (default): fast execution, summary at end
  --learn           Mode étudiant: explications bilingues, pause entre les étapes
                    Student mode: bilingual explanations, pause between steps

Options:
  --lab NN          Exécuter uniquement le lab NN / Run only lab NN
  --reset NN        Nettoyer puis réexécuter le lab NN / Clean then rerun lab NN
  --quick           Sauter install si Podman est déjà présent / Skip install if Podman present
  --diff            Comparer les 2 derniers rapports / Compare last 2 reports
  --verbose         Afficher toutes les sorties / Show all output
  --help            Afficher cette aide / Show this help

Examples:
  ./run-labs.sh --learn              # Tutoriel interactif / Interactive tutorial
  ./run-labs.sh --validate           # Validation rapide / Quick validation
  ./run-labs.sh --learn --lab 03     # Lab 03 en mode apprentissage / Lab 03 in learn mode
  ./run-labs.sh --reset 99           # Tout nettoyer / Full cleanup
USAGE
    exit 0
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --validate)  MODE="validate"; shift ;;
        --learn)     MODE="learn"; shift ;;
        --lab)       RUN_LAB="$2"; shift 2 ;;
        --reset)     RESET_LAB="$2"; shift 2 ;;
        --quick)     QUICK_MODE=true; shift ;;
        --diff)      DIFF_ONLY=true; shift ;;
        --verbose)   VERBOSE=2; shift ;;
        --help|-h)   usage ;;
        *)           echo "Unknown option: $1"; usage ;;
    esac
done

# =============================================================================
# SOURCE FRAMEWORK / CHARGER LE FRAMEWORK
# =============================================================================

source "${TESTS_DIR}/_common.sh"

# =============================================================================
# HANDLE --diff / GÉRER --diff
# =============================================================================

if [[ "${DIFF_ONLY}" == "true" ]]; then
    diff_reports
    exit 0
fi

# =============================================================================
# BANNER / BANNIÈRE
# =============================================================================

echo ""
echo -e "${BOLD}${BLUE}"
echo "  ╔══════════════════════════════════════════════════════════╗"
echo "  ║                                                          ║"
echo "  ║   CR380 — Introduction aux conteneurs (Podman)           ║"
echo "  ║   Suite de tests automatisés / Automated Test Suite      ║"
echo "  ║                                                          ║"
echo "  ╚══════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo -e "  ${DIM}Mode     : ${MODE}${NC}"
echo -e "  ${DIM}Date     : $(date '+%Y-%m-%d %H:%M:%S')${NC}"
echo -e "  ${DIM}Log      : ${LOG_FILE}${NC}"
echo -e "  ${DIM}Lab      : ${RUN_LAB:-all}${NC}"
echo -e "  ${DIM}Reset    : ${RESET_LAB:-none}${NC}"

log "=========================================="
log "CR380 Podman Lab Test Suite"
log "Mode: ${MODE}"
log "Lab: ${RUN_LAB:-all}"
log "Reset: ${RESET_LAB:-none}"
log "=========================================="

# =============================================================================
# DEFINE TEST ORDER / DÉFINIR L'ORDRE DES TESTS
# =============================================================================

# FR: Liste ordonnée de tous les scripts de test
# EN: Ordered list of all test scripts
ALL_TESTS=(
    "00-preflight.sh"
    "01-install.sh"
    "02-post-install.sh"
    "03-first-containers.sh"
    "04-images.sh"
    "05-containerfile.sh"
    "06-volumes.sh"
    "07-pods.sh"
    "08-compose.sh"
    "99-teardown.sh"
)

# Quick mode: skip install-related tests if podman is already present
# FR: Mode rapide : sauter les tests d'installation si podman est déjà installé
if [[ "${QUICK_MODE}" == "true" ]] && command -v podman &>/dev/null; then
    echo -e "  ${DIM}Quick mode: Podman found, skipping install labs${NC}"
    ALL_TESTS=("${ALL_TESTS[@]:2}")
    TEST_RESULTS["00"]="pass"
    TEST_RESULTS["01"]="pass"
fi

# =============================================================================
# HANDLE --lab / GÉRER --lab
# =============================================================================

if [[ -n "${RUN_LAB}" ]]; then
    target_file=""
    for test_file in "${ALL_TESTS[@]}"; do
        if [[ "${test_file}" == "${RUN_LAB}-"* ]]; then
            target_file="${test_file}"
            break
        fi
    done

    if [[ -z "${target_file}" ]]; then
        echo -e "  ${RED}Lab ${RUN_LAB} not found in test suite${NC}"
        echo "  Available labs:"
        for test_file in "${ALL_TESTS[@]}"; do
            echo "    ${test_file%%-*}"
        done
        exit 1
    fi

    for test_file in "${ALL_TESTS[@]}"; do
        local_num="${test_file%%-*}"
        if [[ "${local_num}" < "${RUN_LAB}" ]]; then
            TEST_RESULTS["${local_num}"]="pass"
        fi
    done

    ALL_TESTS=("${target_file}")
fi

# =============================================================================
# HANDLE --reset / GÉRER --reset
# =============================================================================

if [[ -n "${RESET_LAB}" ]]; then
    target_file=""
    for test_file in "${ALL_TESTS[@]}"; do
        if [[ "${test_file}" == "${RESET_LAB}-"* ]]; then
            target_file="${test_file}"
            break
        fi
    done

    if [[ -z "${target_file}" ]]; then
        echo -e "  ${RED}Lab ${RESET_LAB} not found in test suite${NC}"
        exit 1
    fi

    echo -e "  ${YELLOW}Reset mode: running teardown first...${NC}"

    for test_file in "${ALL_TESTS[@]}"; do
        local_num="${test_file%%-*}"
        if [[ "${local_num}" < "${RESET_LAB}" ]]; then
            TEST_RESULTS["${local_num}"]="pass"
        fi
    done

    ALL_TESTS=("${target_file}")
fi

# =============================================================================
# EXECUTE TESTS / EXÉCUTER LES TESTS
# =============================================================================

for test_file in "${ALL_TESTS[@]}"; do
    test_path="${TESTS_DIR}/${test_file}"

    if [[ ! -f "${test_path}" ]]; then
        echo -e "  ${YELLOW}⊘ Test file not found: ${test_file} — skipping${NC}"
        continue
    fi

    source "${test_path}"
    run_test
done

# =============================================================================
# FINALIZE / FINALISER
# =============================================================================

finalize_report
print_final_summary

if (( TOTAL_FAIL > 0 )); then
    exit 1
fi

exit 0
