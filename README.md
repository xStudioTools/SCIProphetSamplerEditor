# SCI Prophet Sampler Editor

A professional cross-platform editor and librarian for the vintage **Sequential Circuits Prophet 2000** and **Prophet 2002** 12-bit digital samplers.

The modern editor is in the architecture and workspace setup stage. The features below are targets, not yet implemented functionality.

## Key Target Features

- Full MIDI System Exclusive (SysEx) parameter editing: filter, envelopes, tuning, and mapping.
- Sample dump transfer via MIDI Sample Dump Standard (SDS) and proprietary SCI SysEx dumps, with device support verified against reference material and hardware.
- Desktop support for macOS, Windows, and Linux, plus browser access through the Web MIDI API.
- Preset library management, backup, and patch import/export.

## Repository Structure

| Path | Purpose |
| --- | --- |
| `legacy-prophet2012/` | Original reference code from [wusel76/Prophet2012](https://github.com/wusel76/Prophet2012), preserving its `Docs/`, `SRCDIR/`, and README layout. |
| `apps/desktop/` | Upcoming Electron application for macOS, Windows, and Linux. |
| `apps/web/` | Upcoming lightweight Vite + React application with Web MIDI access. |
| `packages/core/` | Shared TypeScript MIDI, SysEx, SDS, and Prophet memory model library. |
| `docs/architecture/` | Phased implementation plan and architecture decisions. |

Read [AGENTS.md](AGENTS.md) for development conventions and [PLAN.md](docs/architecture/PLAN.md) for milestones. npm workspace manifests and shared strict TypeScript settings are provided; application dependencies, runnable entry points, and build scripts will be added in the corresponding phases.

## Upstream Sync

The [upstream sync workflow](.github/workflows/upstream-sync.yml) runs weekly on Mondays at 06:00 UTC and can also be dispatched manually. It fetches the upstream default branch and opens or updates a pull request that mirrors its tracked tree exclusively into `legacy-prophet2012/`, including upstream deletions. It preserves the two curated HTML references and their marked README section, and never executes upstream code. Do not otherwise make local edits in the archive.

Repository administrators must enable **Allow GitHub Actions to create and approve pull requests** in Settings → Actions → General for the workflow to open its PR. Review and merge the sync PR normally. See the [sync design](docs/architecture/PLAN.md#upstream-preservation) for details.

## License & Credits

SCI Prophet Sampler Editor's new code is licensed under **GPL-3.0**; see [LICENSE](LICENSE).

Credit and thanks to **wusel76** for the original **Prophet2012** reverse-engineering and reference implementation, and to Bertil, credited in the original README.

The archived upstream material retains its original notices, including the no-payment statement in its [README](legacy-prophet2012/README.md). The root license does not replace those notices; clarify upstream licensing before incorporating archived code into a release.
