#!/usr/bin/env python3

import hashlib
import os
import subprocess
import sys
from pathlib import Path

CACHEDIR = Path(".cache")


def main(args):
    spec = hashlib.md5(" ".join(args).encode("utf-8")).hexdigest()

    CACHEDIR.mkdir(exist_ok=True)

    cache = (CACHEDIR / spec).with_suffix(".tex")
    sys.stderr.write(f"Using cache file at {cache}\n")
    if not cache.exists() or os.environ.get("NOCACHE"):
        out = subprocess.run(args, capture_output=True)
        cache.write_bytes(out.stdout)

    sys.stdout.write(cache.read_text())


if __name__ == "__main__":
    main(sys.argv[1:])
