#!/usr/bin/env bash
# Converte stems para MP3 e gera manifest.json para GitHub Pages.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"

if ! command -v ffmpeg >/dev/null 2>&1; then
  echo "ffmpeg não encontrado. Instale com: brew install ffmpeg"
  exit 1
fi

echo "==> Convertendo vocals.wav e guitar.wav para MP3…"
for dir in */; do
  [ -d "$dir" ] || continue
  for stem in vocals guitar; do
    wav="${dir}${stem}.wav"
    mp3="${dir}${stem}.mp3"
    if [ -f "$wav" ]; then
      if [ -f "$mp3" ]; then
        echo "  skip ${mp3} (já existe)"
      else
        echo "  ffmpeg ${wav}"
        ffmpeg -y -hide_banner -loglevel error -i "$wav" \
          -codec:a libmp3lame -qscale:a 2 "$mp3"
      fi
    elif [ ! -f "$mp3" ]; then
      echo "  AVISO: sem ${stem} em ${dir}"
    fi
  done
done

echo "==> Gerando manifest.json…"
python3 - <<'PY'
import json
import re
from pathlib import Path

root = Path(".")
tracks = []
for folder in sorted(root.iterdir()):
    if not folder.is_dir() or folder.name.startswith("."):
        continue
    vocals = folder / "vocals.mp3"
    guitar = folder / "guitar.mp3"
    if not vocals.exists() or not guitar.exists():
        continue
    name = folder.name
    m = re.match(r"^(\d+)\s+(.+?)\s*\[", name)
    num = int(m.group(1)) if m else 999
    title = m.group(2).strip() if m else name
    tracks.append({
        "id": folder.name,
        "num": num,
        "title": title,
        "folder": folder.name,
        "vocals": f"{folder.name}/vocals.mp3",
        "guitar": f"{folder.name}/guitar.mp3",
    })

tracks.sort(key=lambda t: t["num"])
manifest = {
    "album": "A Flor da Pele",
    "artists": "Raphael Rabello & Ney Matogrosso",
    "tracks": tracks,
}
(root / "manifest.json").write_text(
    json.dumps(manifest, ensure_ascii=False, indent=2) + "\n",
    encoding="utf-8",
)
print(f"  {len(tracks)} faixas em manifest.json")
PY

echo "==> Removendo ficheiros que não vão para o Git…"
for dir in */; do
  [ -d "$dir" ] || continue
  find "$dir" -type f \( -name "*.wav" -o -name "*.mid" -o -name "*.gp5" \) -delete 2>/dev/null || true
  find "$dir" -type d \( -name transcricao -o -name arranjo \) -prune -exec rm -rf {} + 2>/dev/null || true
done

echo "==> Pronto. Ficheiros no repo:"
find . -maxdepth 3 -type f ! -path './.git/*' | sort
