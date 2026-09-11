# Implementation Plan

## Architecture and current state

This repository currently provides a preserved legacy source snapshot with curated standalone HTML references, npm workspace boundaries, and strict TypeScript defaults. The modern applications and protocol engine are not implemented yet. Use TypeScript throughout the new work, Vite + React for the browser UI, and Electron for the desktop host.

The core owns codecs, memory models, transfer state machines, and a transport interface. Browser and native MIDI adapters implement that interface. The UI calls application operations without encoding wire messages itself. Keep sample and preset formats versioned and independent of UI state.

## Phase 1: Core SysEx / MIDI engine

Implement `packages/core` with documented Prophet 2000/2002 parameter and memory specifications, MIDI message handling, SCI SysEx encoding/decoding, and SDS parsing and transfer support where verified for each device.

1. Inventory the legacy protocol implementation and available manuals; document sources and unresolved assumptions for every device-specific command and memory offset.
2. Define transport interfaces and typed device capabilities, preset/sample models, and parse errors.
3. Implement validated codecs and byte fixtures, followed by transfer state machines with pacing, acknowledgements, bounded retries, timeout, progress, and cancellation.
4. Add versioned library import/export and backup formats without platform dependencies.

Exit criteria: strict type checks and automated fixture/state-machine tests pass; malformed data is rejected; capability claims are traceable to reference evidence. Record hardware validation separately before calling a device operation supported.

## Phase 2: Lightweight Web Application

Build `apps/web` using Vite + React and the shared core. Add an explicit connect flow, MIDI port selection, parameter controls, mapping, transfer progress, preset management, and local backup/import/export.

Follow the [Web MIDI specification](https://www.w3.org/TR/webmidi/): require a secure context, feature-detect the API, request SysEx permission, and handle permission refusal and device disconnection. Provide a useful unsupported-browser state. Keep device writes explicit and confirm memory replacement. Use browser persistence behind a storage interface.

Exit criteria: browser build and type checks pass; simulated MIDI tests cover connection failures and transfers; documented manual checks cover compatible browsers and real sampler round trips. Offline library operations remain usable without MIDI permission.

## Phase 3: Cross-Platform Electron Wrapper

Build `apps/desktop` for macOS, Windows, and Linux, reusing the web renderer and core. Evaluate native MIDI backends such as `node-midi` or `@johannesvollmer/web-midi-api` for maintenance, licensing, Electron ABI support, and successful SysEx transfers on each target before choosing one.

Keep native MIDI in the main process or a dedicated worker. Expose a small typed preload API with validated IPC; enable context isolation and sandboxing, disable renderer Node integration, and apply a restrictive CSP following [Electron security guidance](https://www.electronjs.org/docs/latest/tutorial/security). Add file dialogs and filesystem persistence through application interfaces.

Exit criteria: desktop launch and MIDI enumeration work on all three operating systems; native dependencies rebuild/package correctly; UI and transport integration checks pass; device testing records include cancellation and unplugging during a transfer.

## Phase 4: Automated CI/CD Builds

Introduce pull-request CI for dependency installation with the committed lockfile, type checks, protocol tests, and application builds. Then add tagged release workflows using a macOS/Windows/Linux runner matrix and Electron packaging tooling.

| Platform | Deliverables |
| --- | --- |
| macOS | `.app` bundle and `.dmg`; test Intel and Apple Silicon targets. |
| Windows | `.exe` application and installer. |
| Linux | `.AppImage` and `.deb`. |

Rebuild native MIDI modules for each target; smoke-test packaged applications and include checksums and license notices. Configure signing/notarization through repository secrets and document unsigned development builds. Publish release artifacts only after the validation jobs pass.

Exit criteria: reproducible tagged builds generate all listed formats, install/launch checks pass on target platforms, and release documentation states hardware validation and known limitations.

## Upstream preservation

The initial archive preserves every original tracked file byte-for-byte at the same relative path. Repository administration directories (`.git`, `.agents`, `.codex`) stay at the root.

`.github/workflows/upstream-sync.yml` fetches `wusel76/Prophet2012`'s default branch into a temporary repository. `scripts/sync-upstream.sh` extracts its Git tree and mirrors it into `legacy-prophet2012/`, including additions, changes, deletions, and file modes. The two curated HTML files in `legacy-prophet2012/docs/` and the marked Archived Reference Materials README section are preserved as explicit local additions. No upstream scripts or build hooks run. The fetched commit SHA is recorded in the sync PR body and commit message.

The workflow grants write access only for repository contents and PR creation and maintains a dedicated `automation/upstream-sync` branch. The PR action stages only the archive path. No automatic merge is configured, and repeated runs without tree changes produce no new commit. The root application workspaces and documentation are outside the sync destination.

Enable GitHub Actions PR creation in repository settings before the first run. GitHub may not trigger additional workflows from PRs created with the default `GITHUB_TOKEN`; account for this when adding required CI checks. Resolve archive differences by checking the upstream snapshot, not by making local modifications that the next mirror would overwrite.
