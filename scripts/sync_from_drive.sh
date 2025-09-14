#!/usr/bin/env bash
set -euo pipefail

# ──────────────────────────────────────────────────────────────────────────────
# Sync desde un ZIP/carpeta de Google Drive → repo local data_flow_consulting
# - Copia por defecto SOLO archivos NUEVOS (no sobreescribe) [MODE=new]
# - Modo opcional para nuevos + modificados [MODE=update]
# - No usa --delete (no borra nada en el repo)
# - Pide mensaje adicional para el commit
# - Configura Git LFS para docx/xlsx/pptx/pdf/zip/mp4 si está instalado
# Uso:
#   DRY_RUN=1 ./scripts/sync_from_drive.sh /ruta/Drive_export.zip
#   MODE=update ./scripts/sync_from_drive.sh /ruta/carpeta_descomprimida
# Vars opcionales:
#   BRANCH=main (por defecto), MAX_SHOW=30, SNAP=/ruta/snapshot
# ──────────────────────────────────────────────────────────────────────────────

# 0) Autodetectar REPO root a partir de la ubicación del script
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
if [[ -d "$SCRIPT_DIR/../.git" ]]; then
  REPO="${REPO:-$(cd "$SCRIPT_DIR/.." && pwd)}"
else
  REPO="${REPO:-$SCRIPT_DIR}"
fi

# 1) Config por defecto (ajustables via env)
SNAP="${SNAP:-$HOME/github/data_flow_consulting_drive_snapshot}"  # carpeta para descomprimir ZIP (fuera del repo)
BRANCH="${BRANCH:-main}"
MODE="${MODE:-new}"                 # new | update
MAX_SHOW="${MAX_SHOW:-30}"
INPUT_PATH="${1:-}"

# 2) Validaciones básicas
if [[ -z "$INPUT_PATH" ]]; then
  echo "Uso: $0 /ruta/al/ZIP_de_Drive.zip  (o carpeta ya descomprimida)"
  echo "Vars: BRANCH=... MODE=new|update DRY_RUN=1 SNAP=/otra/ruta MAX_SHOW=30"
  exit 1
fi
[[ -d "$REPO/.git" ]] || { echo "ERROR: No parece un repo git: $REPO"; exit 1; }

for cmd in git rsync; do
  command -v "$cmd" >/dev/null || { echo "ERROR: falta '$cmd' en PATH"; exit 1; }
done
if [[ -f "$INPUT_PATH" ]]; then
  command -v unzip >/dev/null || { echo "ERROR: falta 'unzip' para manejar ZIPs"; exit 1; }
fi

echo "==> REPO: $REPO"
echo "==> BRANCH: $BRANCH"
echo "==> SNAP: $SNAP"

# 3) Alinear repo local con remoto
git -C "$REPO" fetch origin
git -C "$REPO" switch "$BRANCH"
git -C "$REPO" reset --hard "origin/$BRANCH"

# 4) Preparar fuente (ZIP o carpeta)
if [[ -f "$INPUT_PATH" ]]; then
  echo "==> Limpiando snapshot y descomprimiendo ZIP"
  mkdir -p "$SNAP"
  rm -rf "${SNAP:?}/"*
  unzip -q "$INPUT_PATH" -d "$SNAP"

  # Detectar si el ZIP trae una única carpeta raíz
  mapfile -t _top <<<"$(find "$SNAP" -mindepth 1 -maxdepth 1 -printf '%f\n')"
  SRC="$SNAP"
  if [[ "${#_top[@]}" -eq 1 && -d "$SNAP/${_top[0]}" ]]; then
    SRC="$SNAP/${_top[0]}"
  fi
else
  [[ -d "$INPUT_PATH" ]] || { echo "ERROR: no es archivo ni carpeta: $INPUT_PATH"; exit 1; }
  SRC="$INPUT_PATH"
fi
echo "==> Fuente detectada: $SRC"

# 5) Archivo de exclusiones (fuente) — evita basura y sobrescribir el propio script
EXC_FILE="$(mktemp)"; trap 'rm -f "$EXC_FILE"' EXIT
cat >"$EXC_FILE" <<'EOF'
~$*
*.tmp
*.bak
.DS_Store
Thumbs.db
desktop.ini
.git/
scripts/
EOF
# Excluir explícitamente ESTE script si el origen trae uno con el mismo nombre
SCRIPT_BASENAME="$(basename "$0")"
echo "$SCRIPT_BASENAME" >> "$EXC_FILE"

# 6) Configurar Git LFS si existe
if git -C "$REPO" lfs env >/dev/null 2>&1; then
  git -C "$REPO" lfs install >/dev/null
  touch "$REPO/.gitattributes"
  add_track() {
    # añade regla solo si no existe
    grep -qE "^\*\.$1(\s|$).*filter=lfs" "$REPO/.gitattributes" 2>/dev/null \
      || echo "*.$1 filter=lfs diff=lfs merge=lfs -text" >> "$REPO/.gitattributes"
  }
  for ext in docx xlsx pptx pdf zip mp4; do add_track "$ext"; done
else
  echo "==> Aviso: Git LFS no instalado; omitiendo configuración."
fi

# 7) Previa: listar ARCHIVOS NUEVOS (SRC y no en REPO)
#    (excluyendo .git y scripts para evitar “falsos positivos”)
list_files() {
  local root="$1"
  ( cd "$root" &&
    find . \
      -path './.git' -prune -o \
      -path './scripts' -prune -o \
      -type f -print | sort
  )
}
mapfile -t NEW_PRE <<<"$(
  comm -23 \
    <(list_files "$SRC") \
    <(list_files "$REPO") \
  | sed 's#^\./##'
)"
echo "==> Archivos NUEVOS detectados: ${#NEW_PRE[@]}"
if (( ${#NEW_PRE[@]} > 0 )); then
  printf '   - %s\n' "${NEW_PRE[@]:0:MAX_SHOW}"
  (( ${#NEW_PRE[@]} > MAX_SHOW )) && echo "   ... (+$(( ${#NEW_PRE[@]} - MAX_SHOW )) más)"
fi

# 8) rsync (sin --delete). DRY_RUN opcional
RSYNC_FLAGS=(-av --exclude-from="$EXC_FILE")
[[ "${DRY_RUN:-}" == "1" ]] && RSYNC_FLAGS+=(--dry-run --itemize-changes)
case "$MODE" in
  new)    RSYNC_FLAGS+=(--ignore-existing); echo "==> MODE=new (solo nuevos)";;
  update) echo "==> MODE=update (nuevos + sobrescribir modificados)";;
  *) echo "ERROR: MODE debe ser 'new' o 'update'"; exit 1;;
esac

echo "==> Copiando desde SRC → REPO (rsync)"
rsync "${RSYNC_FLAGS[@]}" "$SRC"/ "$REPO"/

if [[ "${DRY_RUN:-}" == "1" ]]; then
  echo "==> DRY_RUN activo: simulación, no se aplicaron cambios."
  exit 0
fi

# 9) Commit si hay cambios
git -C "$REPO" add -A
if git -C "$REPO" diff --cached --quiet; then
  echo "==> Sin cambios que commitear."
  exit 0
fi

echo
echo "Escribe un MENSAJE adicional para el commit (Enter para dejar vacío)."
echo "Ej.: 'Se agregan minutas y plantillas de informe semana 2'"
IFS= read -r -p "> " MSG_EXTRA || true

SUBJ="Sync desde Drive ($(basename "$INPUT_PATH")) $(date +%F)"
if [[ -n "$MSG_EXTRA" ]]; then
  git -C "$REPO" commit -m "$SUBJ" -m "$MSG_EXTRA"
else
  git -C "$REPO" commit -m "$SUBJ"
fi

git -C "$REPO" push origin "$BRANCH"
echo "==> Listo. Cambios enviados a '$BRANCH'."
