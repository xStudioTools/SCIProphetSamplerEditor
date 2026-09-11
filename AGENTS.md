# Agent and Contributor Guidelines

## Scope and workflow

- Read `docs/architecture/PLAN.md` and the relevant workspace documentation before implementation.
- Keep changes focused on the requested phase. State assumptions, acceptance criteria, and verification results; distinguish planned features from working features.
- Treat `legacy-prophet2012/` as read-only reference material. Do not edit, format, modernize, or add files there. Only the upstream sync workflow may update its snapshot from upstream. Explicitly requested curated references in `legacy-prophet2012/docs/` and the marked README reference section are exceptions; preserve them during sync.
- Preserve upstream attribution and license notices. New project code uses GPL-3.0-only.
- Never commit credentials, generated bundles, private sample libraries, or local device configuration.

## Workspace boundaries

- `packages/core`: platform-independent protocol logic and memory models; no React, Electron, DOM, or native MIDI imports.
- `apps/web`: Vite + React UI, browser MIDI adapter, and browser persistence.
- `apps/desktop`: Electron main process, narrow preload bridge, and native MIDI adapter; reuse the web UI and core instead of duplicating protocol logic.
- Use npm workspaces. Add dependencies to their owning workspace and commit the root lockfile when dependencies are introduced.

## TypeScript and protocol standards

- Extend `tsconfig.base.json`; keep strict mode, unchecked index checks, and exact optional properties enabled. Avoid `any`; validate external inputs as `unknown`.
- Use `Uint8Array` for wire data, named constants with units for timings/addresses, and explicit types for transport state and protocol errors.
- Keep encoding and parsing deterministic. Validate lengths, ranges, manufacturer/device identifiers, framing, and checksums before accepting data or sending messages.
- Cite reference files or specification sections for protocol constants and memory layouts. Do not invent undocumented opcodes, memory limits, or SDS support; mark uncertainties and resolve with fixtures or hardware evidence.
- Isolate transport from codecs. Transfers need bounded retries, timeouts, cancellation, progress, and disconnect handling. Never send bulk data merely on application startup.

## Browser and desktop integration

- Follow the [W3C Web MIDI API](https://www.w3.org/TR/webmidi/). Detect API availability, use a secure context, request `navigator.requestMIDIAccess({ sysex: true })` from an explicit connect action, and handle denied permission and missing SysEx access.
- Support port selection, connection changes, and clean listener/port disposal. Explain unavailable MIDI support in the UI.
- Follow [Electron security guidance](https://www.electronjs.org/docs/latest/tutorial/security): context isolation and sandboxing enabled, Node integration disabled in renderers, restrictive CSP, and validated IPC with a minimal preload API.
- Keep native MIDI dependencies in the desktop process and validate compatibility on each supported OS before selecting a backend.
- Require an explicit user action before overwriting sampler memory; show the target device and operation.

## Verification

- For protocol work, test known byte fixtures, malformed/truncated messages, boundary values, and encode/decode behavior against independent expected bytes.
- Test transfer state machines with a fake transport and controlled timing, including retry, cancellation, and disconnect behavior.
- Run the affected workspace's type checks, tests, and builds once available. Never report hardware or platform testing that was not performed.
- Keep hardware integration tests opt-in. Record sampler model, firmware, MIDI interface, and observed behavior when testing physical devices.
