"""Copy Classical Guide's public pages into an existing Web V2 checkout."""
from pathlib import Path
import shutil
import sys

if len(sys.argv) != 2:
    raise SystemExit("Usage: python3 scripts/sync-support-website.py /path/to/Web-V2")

source = Path(__file__).resolve().parents[1] / "website" / "classical-guide"
target = Path(sys.argv[1]).resolve()
if not (target / "vercel.json").is_file():
    raise SystemExit("Destination must be the existing Web V2 project root.")

for relative in ("index.html", "style.css", "privacy/index.html", "credits/index.html"):
    destination = target / "classical-guide" / relative
    destination.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(source / relative, destination)
    print(destination)

ignore = target / ".vercelignore"
rules = ignore.read_text() if ignore.exists() else ""
missing = [rule for rule in ("!/classical-guide/", "!/classical-guide/**") if rule not in rules.splitlines()]
if missing:
    with ignore.open("a") as handle:
        handle.write("\n" + "\n".join(missing) + "\n")
