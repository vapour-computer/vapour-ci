# vapour-ci
CI/CD templates and GitHub Actions for publishing games to Vapour

## Build and publish preview

This composite action runs an **already installed, pinned CLI**. Install engines,
templates and the CLI in preceding workflow steps; it never downloads tools.
It calls `vapour build --dir ...`, then publish, stopping if export fails.
Godot, Unity and Bevy use the same local command and vapour.toml configuration.
Unity editor/WebGL support and CI licensing remain developer-managed; Bevy needs
the WASM target and matching wasm-bindgen; Godot needs matching Web templates.

Inputs: token (required, environment only), version (required), notes (required
unless notes-file is set), optional notes-file (alternative to notes), dir, build (true), experimental-chunks
(false), dry-run (false), and api. Dry run still builds locally. Use build=false
for a pre-exported project. Chunk publishing is opt-in and requires a compatible
experimental server; the deployed API does not support it yet.

The included tag templates strip a leading `v` before passing `version`, and use
`notes: "Release ${{ github.ref_name }}"` by default.

Ready-to-copy examples are in `templates/godot-publish.yml`,
`templates/unity-publish.yml`, and `templates/bevy-publish.yml`.

**Status: planned** for a release with integrated chunk delivery. Depends on
[CLI engine build](https://github.com/vapour-computer/vapour-cli/pull/1) and the
[chunk-publish PR](https://github.com/vapour-computer/vapour-cli/pull/2). No assumptions are made about unpublished checkout
commits, existing v1 tags, release installers or checksum verification.

Local check: `bash tests/test.sh` tests orchestration for all three engine project
paths using a fixture CLI, plus failure propagation and no tokens in argv/logs.
These are action contract tests, not actual Unity/Bevy exports or hosted CI runs.
