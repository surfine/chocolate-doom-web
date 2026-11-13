# Licence notes (Chocolate Doom web)

This file names which licence text belongs at the public repository root and how adapters are marked. It does not reprint any licence text.

## Root licence file

Place `ENGINE-COPYING.txt` (already in this tree) at the repository root.

- `SOURCE.txt`: “Engine license: GNU General Public License version 2; see the exact upstream notices and ENGINE-COPYING.txt for terms and version-option details.”
- `ENGINE-COPYING.txt` is the GPL-2 text shipped beside the engine.
- Adapter source is “provided under GPL-2.0-only, as marked in each file” (`SOURCE.txt`).

Do not invent a different SPDX at the root; keep the tree’s own GPL-2 text and the adapters’ `GPL-2.0-only` headers.

## Adapters in this tree (this project’s browser side)

Marked `GPL-2.0-only` (`SOURCE.txt` lists them; each file’s first line is `SPDX-License-Identifier: GPL-2.0-only`):

| File | Marking |
| --- | --- |
| `shell.js` | `// SPDX-License-Identifier: GPL-2.0-only` |
| `wad-picker.js` | `// SPDX-License-Identifier: GPL-2.0-only` |
| `touch-controls.js` | `// SPDX-License-Identifier: GPL-2.0-only` |
| `touch-controls.css` | `/* SPDX-License-Identifier: GPL-2.0-only */` |

Corresponding source and patch for the engine binaries:

| File | Role |
| --- | --- |
| `chocolate-doom-3.1.1-source.tar.gz` | Unmodified upstream source (`SOURCE.txt`) |
| `chocolate-doom-3.1.1-ai-system6.patch` | Complete native changes (`SOURCE.txt`) |
| `build/patches/emscripten-runtime.patch` | Same patch used by `build/build-doom.sh` (`build/build.md`) |
| `build/build-doom.sh`, `build/build.md`, `build/build.zh-CN.md` | Rebuild pipeline |

## Files with no stated licence in the tree

| File | What the tree says |
| --- | --- |
| `index.html` | No licence header |
| `ais6-bridge.js` | No licence / SPDX header |
| `app.manifest.json` | No licence field |
| `chocolate-doom.js`, `chocolate-doom.wasm` | Generated engine payload; licence pointed at by `SOURCE.txt` / `ENGINE-COPYING.txt`, not restated inside the binaries |
| `tools/build.mjs`, `package.json`, README files (public-repo additions) | Not present in the game tree; no licence stated there either until the publisher marks them |
