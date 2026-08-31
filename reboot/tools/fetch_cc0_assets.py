#!/usr/bin/env python3
"""Fetch audited CC0 production-base assets for the Pale Signal reboot.

All URLs are pinned to immutable upstream commits. Hash verification is mandatory.
The game retains procedural fallbacks, but release CI fetches and imports these assets.
"""
from __future__ import annotations

import hashlib
import pathlib
import shutil
import sys
import urllib.request

ROOT = pathlib.Path(__file__).resolve().parents[1]
OUT = ROOT / "assets" / "imported"
OUT.mkdir(parents=True, exist_ok=True)

ASSETS = [
    {
        "name": "eva_suit.glb",
        "url": "https://raw.githubusercontent.com/Seyamalam/blood-league-kickoff/aa02a4e6d8337a0604d2da131bcbbeb1f01badf0/public/assets/vendor/quaternius/night-striker.glb",
        "sha256": "a466828c67a4acc9b2413212ce6d9cde235e3aed9b675680c14fd9673858f118",
        "role": "Quaternius Universal Base Character temporary EVA rig/body foundation",
    },
    {
        "name": "humanoid_animations.glb",
        "url": "https://raw.githubusercontent.com/Seyamalam/blood-league-kickoff/aa02a4e6d8337a0604d2da131bcbbeb1f01badf0/public/assets/vendor/quaternius/universal-animation-library.glb",
        "sha256": "4c748767741a3e495d89667b9a218b690ba9810b9517a12e960780e3ca72c4e9",
        "role": "Quaternius Universal Animation Library",
    },
    {
        "name": "ship_player.gltf",
        "url": "https://raw.githubusercontent.com/euuuuuuan/voidclad-public/440916aabc30abe014cb33ad90bd150bfbf22dd0/assets/vendor/quaternius_ultimate_spaceships/Challenger.gltf",
        "sha256": "c600b39fd587c323557c682e7aae2e976b62fff2984929163b7ee12a0e4323fd",
        "role": "Quaternius Challenger temporary hero-ship remodeling base",
    },
    {
        "name": "kestra_module.glb",
        "url": "https://raw.githubusercontent.com/0xrise/cc0-assets-nft/4c16444b4133f4ffe7679b59d26b9565e3258be0/models/kenney/environment/corridor.glb",
        "git_blob_sha1": "48574011a86d5fccd6505417eb8402218b7689fe",
        "role": "Kenney modular space corridor temporary Kestra structural support",
    },
]

LICENSES = [
    (
        "QUATERNIUS_BASE_CHARACTER_LICENSE.txt",
        "https://raw.githubusercontent.com/Seyamalam/blood-league-kickoff/aa02a4e6d8337a0604d2da131bcbbeb1f01badf0/public/assets/vendor/quaternius/LICENSE-BASE-CHARACTERS.txt",
    ),
    (
        "QUATERNIUS_ANIMATIONS_LICENSE.txt",
        "https://raw.githubusercontent.com/Seyamalam/blood-league-kickoff/aa02a4e6d8337a0604d2da131bcbbeb1f01badf0/public/assets/vendor/quaternius/LICENSE-ANIMATIONS.txt",
    ),
]


def fetch(url: str) -> bytes:
    req = urllib.request.Request(url, headers={"User-Agent": "Pale-Signal-Reboot-CI/1"})
    with urllib.request.urlopen(req, timeout=90) as response:
        return response.read()


def git_blob_sha1(data: bytes) -> str:
    header = f"blob {len(data)}\0".encode("ascii")
    return hashlib.sha1(header + data).hexdigest()


def verify(asset: dict, data: bytes) -> None:
    if "sha256" in asset:
        actual = hashlib.sha256(data).hexdigest()
        if actual != asset["sha256"]:
            raise RuntimeError(f"SHA-256 mismatch for {asset['name']}: {actual}")
    if "git_blob_sha1" in asset:
        actual = git_blob_sha1(data)
        if actual != asset["git_blob_sha1"]:
            raise RuntimeError(f"Git blob SHA-1 mismatch for {asset['name']}: {actual}")


def main() -> int:
    for asset in ASSETS:
        print(f"Fetching {asset['name']} — {asset['role']}")
        data = fetch(asset["url"])
        verify(asset, data)
        (OUT / asset["name"]).write_bytes(data)
        print(f"  wrote {len(data):,} bytes")

    # Talari starts from the same audited humanoid rig so animation retargeting is
    # mechanically stable. Its final mesh/proportions/materials are intentionally custom.
    shutil.copy2(OUT / "eva_suit.glb", OUT / "talari_civilian.glb")

    license_dir = OUT / "licenses"
    license_dir.mkdir(exist_ok=True)
    for filename, url in LICENSES:
        (license_dir / filename).write_bytes(fetch(url))

    print("CC0 asset fetch: PASS")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as exc:
        print(f"CC0 asset fetch: FAIL — {exc}", file=sys.stderr)
        raise
