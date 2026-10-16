#!/usr/bin/env bash
set -euo pipefail
for value in "${VAPOUR_BUILD:-true}" "${VAPOUR_CHUNKS:-false}" "${VAPOUR_DRY_RUN:-false}"; do
  case "$value" in true|false) ;; *) echo 'Boolean inputs must be true or false' >&2; exit 2;; esac
done
command -v vapour >/dev/null || { echo 'Install a pinned compatible Vapour CLI before this action' >&2; exit 1; }
dir=${VAPOUR_PROJECT_DIR:-.}
if [[ ${VAPOUR_BUILD:-true} == true ]]; then vapour build --dir "$dir"; fi
args=(publish --dir "$dir")
[[ ${VAPOUR_CHUNKS:-false} == true ]] && args+=(--experimental-chunks)
[[ ${VAPOUR_DRY_RUN:-false} == true ]] && args+=(--dry-run)
args+=(--version "${VAPOUR_VERSION:?version input is required}")
notes=${VAPOUR_NOTES:-}
notes_file=${VAPOUR_NOTES_FILE:-}
if [[ -n "$notes" && -n "$notes_file" ]]; then
  echo 'Pass either notes or notes-file, not both' >&2
  exit 2
fi
if [[ -n "$notes_file" ]]; then
  args+=(--notes-file "$notes_file")
else
  args+=(--notes "${notes:?notes input is required}")
fi
vapour "${args[@]}"
