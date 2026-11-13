// SPDX-License-Identifier: GPL-2.0-only
// npm run build — copies what a host page embeds into dist/.
// Does not recompile chocolate-doom.js / chocolate-doom.wasm.
import { cpSync, mkdirSync, rmSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const root = dirname(dirname(fileURLToPath(import.meta.url)));
const dist = join(root, "dist");
const shipped = [
  "ais6-bridge.js",
  "app.manifest.json",
  "chocolate-doom.js",
  "chocolate-doom.wasm",
  "index.html",
  "shell.js",
  "touch-controls.css",
  "touch-controls.js",
  "wad-picker.js",
  // The licence, the source the binary was built from, the patch and the
  // build travel beside the engine wherever it is served.
  "ENGINE-COPYING.txt",
  "SOURCE.txt",
  "chocolate-doom-3.1.1-source.tar.gz",
  "chocolate-doom-3.1.1-ai-system6.patch",
  "build",
];

rmSync(dist, { recursive: true, force: true });
mkdirSync(dist, { recursive: true });
for (const path of shipped) cpSync(join(root, path), join(dist, path), { recursive: true });
console.log(`built dist/ (${shipped.join(", ")})`);
