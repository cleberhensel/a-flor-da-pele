# A Flor da Pele — Player de Stems

Player estático para GitHub Pages: **voz** e **violão** tocam em simultâneo, com mute independente em cada canal.

**Site:** `https://SEU_USUARIO.github.io/a-flor-da-pele/`

## Conteúdo

- `index.html` — player dual (GitHub Pages)
- `manifest.json` — lista de faixas
- `NN Nome da Música [...]/vocals.mp3` — stem de voz
- `NN Nome da Música [...]/guitar.mp3` — stem de violão
- `prepare-repo.sh` — converte WAV → MP3 e regenera o manifest

## Preparar o repositório

```bash
./prepare-repo.sh
```

Requer `ffmpeg` (`brew install ffmpeg`). O script:

1. Converte `vocals.wav` e `guitar.wav` para MP3 (se existirem)
2. Gera `manifest.json`
3. Remove WAV, MIDI e pastas de transcrição

## Testar localmente

```bash
python3 -m http.server 8765
```

Abra `http://localhost:8765` (não use `file://` — o browser bloqueia áudio).

## Publicar no GitHub Pages

```bash
git add .
git commit -m "Publica player de stems para GitHub Pages"
git remote add origin https://github.com/SEU_USUARIO/a-flor-da-pele.git
git push -u origin main
```

No GitHub: **Settings → Pages → Branch: main / (root)**.

Os MP3s somam ~118 MB (16 faixas × 2 stems).
