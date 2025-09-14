# Sincronización desde Google Drive → `data_flow_consulting`

Script: `scripts/sync_from_drive.sh`  
Propósito: traer **archivos nuevos** (y opcionalmente también **modificados**) desde un ZIP o carpeta exportada de Google Drive hacia el repo local, **preservando historial** y con soporte para **Git LFS** en binarios comunes.

---

## ¿Qué hace?

- Alinea tu repo local con `origin/<BRANCH>` (por defecto `main`).
- Acepta como **entrada** un **ZIP** descargado de Drive **o** una **carpeta** ya descomprimida.
- Detecta automáticamente si el ZIP trae una carpeta raíz envolvente.
- **Copia solo archivos nuevos** por defecto (no sobrescribe).  
  - Con `MODE=update` copia **nuevos + modificados**.
- Ignora basura común (`~$*`, `*.tmp`, `.DS_Store`, etc.), **`.git/`**, **`scripts/`** y **el propio script**.
- Configura **Git LFS** (si está instalado) para `docx xlsx pptx pdf zip mp4`.
- Muestra un **resumen de archivos nuevos** y te pide un **mensaje adicional** para el commit.
- Hace `commit` + `push` **solo si hay cambios**.

> **Seguro por diseño:** no usa `--delete`, por lo que **no borra** nada de tu repo.

---

## Requisitos

- Linux / Bash
- `git`, `rsync`
- `unzip` (solo si pasas un **ZIP**)
- (Opcional) `git lfs`

Instalación de LFS (recomendado si manejas .docx/.xlsx/.pptx/.pdf/.mp4/.zip):

    sudo apt-get update
    sudo apt-get install -y git-lfs
    git lfs install

---

## Estructura recomendada

    ~/github/
      ├─ data_flow_consulting/                 # repo (este README vive aquí)
      │   └─ scripts/
      │       └─ sync_from_drive.sh            # el script
      └─ data_flow_consulting_drive_snapshot/  # carpeta temporal para descomprimir ZIPs

> El script **autodetecta** el root del repo a partir de su ubicación.  
> El snapshot por defecto va a `~/github/data_flow_consulting_drive_snapshot/` (puedes cambiarlo con `SNAP=`).

---

## Instalación

1) Copia el script a `data_flow_consulting/scripts/sync_from_drive.sh`.  
2) Dale permisos:

    chmod +x ~/github/data_flow_consulting/scripts/sync_from_drive.sh

---

## Uso rápido

### 1) Simulación (no escribe nada)

    DRY_RUN=1 ~/github/data_flow_consulting/scripts/sync_from_drive.sh ~/Descargas/Drive_export.zip

### 2) Ejecución real (solo **nuevos**)

    ~/github/data_flow_consulting/scripts/sync_from_drive.sh ~/Descargas/Drive_export.zip

### 3) Traer **nuevos + modificados** (sobrescribe los que cambiaron)

    MODE=update ~/github/data_flow_consulting/scripts/sync_from_drive.sh ~/Descargas/Drive_export.zip

### 4) Si ya tienes la **carpeta descomprimida**

    ~/github/data_flow_consulting/scripts/sync_from_drive.sh ~/Descargas/data_flow_consulting_drive_snapshot

Durante la ejecución verás un listado de **archivos nuevos** detectados y se te pedirá un **mensaje adicional** para el commit.  
El mensaje base incluye el nombre del ZIP/carpeta y la fecha (`YYYY-MM-DD`).

---

## Variables opcionales

- `BRANCH` — rama a sincronizar (por defecto `main`).
- `MODE` — `new` (solo nuevos, **por defecto**) | `update` (nuevos + modificados).
- `DRY_RUN` — `1` para simulación con `rsync --dry-run`.
- `SNAP` — carpeta donde se descomprime el ZIP (por defecto `~/github/data_flow_consulting_drive_snapshot`).
- `MAX_SHOW` — cuántos “nuevos” listar en pantalla (por defecto `30`).

Ejemplos:

    BRANCH=develop MODE=update \
      ~/github/data_flow_consulting/scripts/sync_from_drive.sh ~/Descargas/Drive_export.zip

    SNAP=/tmp/snap_dfc DRY_RUN=1 \
      ~/github/data_flow_consulting/scripts/sync_from_drive.sh ~/Descargas/Drive_export.zip

---

## ¿Qué archivos se ignoran?

El script excluye al copiar desde la fuente:

    ~$*  *.tmp  *.bak  .DS_Store  Thumbs.db  desktop.ini  .git/  scripts/  <este_script>

Además, el listado de “nuevos” también ignora `.git/` y `scripts/` para evitar falsos positivos.

---

## Notas sobre Git LFS

Si `git lfs` está disponible, el script asegura reglas en `.gitattributes` para:

    *.docx *.xlsx *.pptx *.pdf *.zip *.mp4

Esto evita inflar el repo con binarios pesados.  
Si no tienes LFS instalado, verás un aviso y se omite la configuración (puedes instalarlo luego).

---

## Consejos de operación

- **Primero ejecuta en `DRY_RUN=1`** para ver qué pasaría.
- El script **no borra** nada del repo. Si necesitas reflejar borrados de Drive, eso es otro flujo (no cubierto aquí a propósito).
- Si el ZIP de Drive trae una carpeta raíz (típico), el script la **detecta** y usa como fuente real.
- Puedes guardar tus ZIPs en `~/Descargas/` y pasar la ruta como argumento.

---

## Solución de problemas

- `ERROR: No existe el ZIP` → Revisa la ruta que pasaste como argumento.
- `ERROR: No parece un repo git` → Asegúrate de ejecutar el script **dentro** del repo (o que el repo tenga `.git/`).
- `ERROR: falta 'unzip'` → `sudo apt-get install -y unzip`.
- `Sin cambios que commitear` → No hubo nuevos/actualizados respecto a `HEAD`.
- `Permission denied` al ejecutar → `chmod +x scripts/sync_from_drive.sh`.
- `fatal: not a git repository` → Revisa la estructura: el script debe estar dentro de `data_flow_consulting/` y ese directorio debe ser un repo válido.

---

## Ejemplos de alias útiles (opcional)

En tu `~/.zshrc` o `~/.bashrc`:

    alias dfc-sync='~/github/data_flow_consulting/scripts/sync_from_drive.sh'
    alias dfc-sync-dry='DRY_RUN=1 ~/github/data_flow_consulting/scripts/sync_from_drive.sh'
    alias dfc-sync-update='MODE=update ~/github/data_flow_consulting/scripts/sync_from_drive.sh'

Uso:

    dfc-sync ~/Descargas/Drive_export.zip
    dfc-sync-dry ~/Descargas/Drive_export.zip
    dfc-sync-update ~/Descargas/Drive_export.zip

---

## Licencia

Uso interno del proyecto **Data & Flow Consulting**. Adáptalo libremente a tus necesidades.
