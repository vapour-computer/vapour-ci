#!/usr/bin/env bash
set -euo pipefail
root=$(cd -- "$(dirname -- "$0")/.." && pwd)
tmp=$(mktemp -d "${TMPDIR:-/tmp}/vapour-ci-test.XXXXXX")
trap 'rm -rf "$tmp"' EXIT
cat > "$tmp/vapour" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "$*" >> "$TEST_LOG"
[[ "$1" == build && ${FAIL_BUILD:-false} == true ]] && exit 7
exit 0
EOF
chmod +x "$tmp/vapour"
export PATH="$tmp:$PATH" TEST_LOG="$tmp/log" VAPOUR_TOKEN='fixture-secret'
export VAPOUR_CHUNKS=true VAPOUR_DRY_RUN=true VAPOUR_VERSION='v1' VAPOUR_BUILD=true
for engine in godot unity bevy; do
  export VAPOUR_PROJECT_DIR="$engine project"
  : > "$TEST_LOG"
  bash "$root/scripts/publish.sh"
  test "$(head -1 "$TEST_LOG")" = "build --dir $engine project"
  test "$(tail -1 "$TEST_LOG")" = "publish --dir $engine project --experimental-chunks --dry-run --version v1"
  ! grep -q fixture-secret "$TEST_LOG"
done
: > "$TEST_LOG"
export FAIL_BUILD=true
if bash "$root/scripts/publish.sh"; then echo 'ignored build failure' >&2; exit 1; fi
test "$(wc -l < "$TEST_LOG")" = 1
echo 'Godot/Unity/Bevy orchestration, secret handling and build failure tests passed'
