#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "$0")" && pwd)"
repository_root="$(cd "$script_dir/../../../../.." && pwd)"
source_dir="${DOOM_SOURCE_DIR:-$repository_root/external/chocolate-doom}"
output_dir="$repository_root/apps/desktop/apps/doom"
patch_file="$script_dir/patches/emscripten-runtime.patch"
expected_commit="410d96855b5df5410ff591a90efeafa889119224"
temporary_build=""
build_dir="${DOOM_BUILD_DIR:-}"

if [[ ! -d "$source_dir/.git" ]]; then
  echo "Missing Chocolate Doom source at $source_dir" >&2
  echo "Clone tag chocolate-doom-3.1.1 there first." >&2
  exit 1
fi

actual_commit="$(git -C "$source_dir" rev-parse HEAD)"
if [[ "$actual_commit" != "$expected_commit" ]]; then
  echo "Expected Chocolate Doom $expected_commit, found $actual_commit" >&2
  exit 1
fi

for command_name in emcmake cmake ninja git; do
  if ! command -v "$command_name" >/dev/null 2>&1; then
    echo "Missing required command: $command_name" >&2
    exit 1
  fi
done

if git -C "$source_dir" apply --reverse --check "$patch_file" >/dev/null 2>&1; then
  : # Patch is already applied in this ignored source checkout.
elif git -C "$source_dir" apply --check "$patch_file" >/dev/null 2>&1; then
  git -C "$source_dir" apply "$patch_file"
else
  echo "Chocolate Doom source has unexpected changes; patch does not apply cleanly." >&2
  exit 1
fi

if [[ -z "$build_dir" ]]; then
  build_dir="$(mktemp -d "${TMPDIR:-/tmp}/ai-system6-doom.XXXXXX")"
  temporary_build="$build_dir"
fi

cleanup() {
  if [[ -n "$temporary_build" && -d "$temporary_build" ]]; then
    rm -rf "$temporary_build"
  fi
}
trap cleanup EXIT

# Remap absolute build paths out of the published .wasm / .js so machine-local
# directories (source, build tree, Emscripten SDK) never appear in the binaries.
# Escape spaces so CMake's CMAKE_C_FLAGS / CMAKE_CXX_FLAGS splitting keeps each
# -ffile-prefix-map=... as a single compiler argument.
emsdk_root="$(cd "$(dirname "$(command -v emcc)")/../.." && pwd)"
cmake_escape() {
  printf '%s' "$1" | sed 's/ /\\ /g'
}
file_prefix_maps=(
  "-ffile-prefix-map=$(cmake_escape "$source_dir")=/src/chocolate-doom"
  "-ffile-prefix-map=$(cmake_escape "$build_dir")=/build"
  "-ffile-prefix-map=$(cmake_escape "$emsdk_root")=/emsdk"
)
# The SDL2 port and the system libraries are compiled by emcc itself, into the
# SDK's cache, without these flags: their assertion strings carry the cache's
# own path. So the cache lives at a neutral place for this build. The first
# run there compiles the libraries again and takes a few minutes longer.
export EM_CACHE="${EM_CACHE:-/tmp/emscripten-cache-chocolate-doom}"
file_prefix_maps+=("-ffile-prefix-map=$(cmake_escape "$EM_CACHE")=/emsdk/cache")

c_flags="${CMAKE_C_FLAGS:-}"
cxx_flags="${CMAKE_CXX_FLAGS:-}"
for map_flag in "${file_prefix_maps[@]}"; do
  c_flags="${c_flags:+$c_flags }${map_flag}"
  cxx_flags="${cxx_flags:+$cxx_flags }${map_flag}"
done

emcmake cmake \
  -S "$source_dir" \
  -B "$build_dir" \
  -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_C_FLAGS="$c_flags" \
  -DCMAKE_CXX_FLAGS="$cxx_flags" \
  -DCMAKE_DISABLE_FIND_PACKAGE_FluidSynth=TRUE \
  -DCMAKE_DISABLE_FIND_PACKAGE_PNG=TRUE \
  -DCMAKE_DISABLE_FIND_PACKAGE_SampleRate=TRUE \
  -DENABLE_SDL2_NET=OFF \
  -DENABLE_SDL2_MIXER=ON

cmake --build "$build_dir" --target chocolate-doom --parallel

install -m 0644 "$build_dir/src/chocolate-doom.js" "$output_dir/chocolate-doom.js"
install -m 0644 "$build_dir/src/chocolate-doom.wasm" "$output_dir/chocolate-doom.wasm"
install -m 0644 "$source_dir/COPYING.md" "$output_dir/ENGINE-COPYING.txt"
install -m 0644 "$patch_file" "$output_dir/chocolate-doom-3.1.1-ai-system6.patch"
git -C "$source_dir" archive \
  --format=tar.gz \
  --prefix=chocolate-doom-3.1.1/ \
  --output="$output_dir/chocolate-doom-3.1.1-source.tar.gz" \
  "$expected_commit"

echo "Built Chocolate Doom browser engine in $output_dir"
