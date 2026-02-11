# CÓMO: Instalar controladores NVIDIA en Debian 13+/testing/unstable

Esta guía explica cómo instalar y mantener los controladores de GPU NVIDIA en Debian 13 (trixie), testing y unstable usando `install-scripts/nvidia.sh`.

Alcance compatible

- Debian 13 (trixie), Debian testing, Debian unstable.
- Las GPU NVIDIA de generación actual funcionan mejor con el repositorio de NVIDIA (cuda-drivers o nvidia-open). Evita `nvidia-driver` de Debian para tarjetas nuevas.

Inicio rápido

```bash
# Interactivo (recomendado en la primera ejecución). Predeterminado = Módulos de kernel abiertos (nvidia-open)
install-scripts/nvidia.sh

# Instalar desde el repo CUDA de NVIDIA (módulos abiertos) — PREDETERMINADO
install-scripts/nvidia.sh --mode=open

# Instalar desde el repo CUDA de NVIDIA (propietario)
install-scripts/nvidia.sh --mode=nvidia

# Instalar los controladores empaquetados por Debian (más antiguos; adecuado para GPU muy viejas < serie 2000)
install-scripts/nvidia.sh --mode=debian
```

## Qué hace el script

- Detecta tu GPU (prefiere `nvidia-smi`, recurre a `lspci`).
- Ofrece tres rutas de instalación (ver más abajo).
- Para las rutas del repo de NVIDIA:
    - Garantiza que el repo/llavero APT de CUDA para Debian 13 esté configurado (idempotente).
    - Instala el meta‑paquete seleccionado: `cuda-drivers` (propietario) o `nvidia-open` (módulos de kernel abiertos).
- Añade parámetros de kernel para bloquear nouveau y habilitar DRM KMS, actualiza GRUB y actualiza initramfs.
- Ejecuta una verificación posterior a la instalación (origen del driver, módulo cargado, resumen `nvidia-smi`/OpenGL).
- Imprime un resumen de cambios al finalizar.

## Opciones y cuándo usarlas

- Repo CUDA de NVIDIA — módulos de kernel abiertos (`--mode=open`) [Predeterminado]
    - Instala `nvidia-open` desde el repo APT de NVIDIA. Recomendado para Wayland/Hyprland, actualizaciones de kernel más fluidas y GPU serie RTX 5000+ (requerido).
- Repo CUDA de NVIDIA — propietario (`--mode=nvidia`)
    - Instala `cuda-drivers` desde el repo APT de NVIDIA. Módulos cerrados “probados en batalla”; válido para muchas configuraciones de series 2000/3000/4000; puede implicar reconstrucciones DKMS en actualizaciones de kernel.
- Repo de Debian — empaquetado por Debian (`--mode=debian`)
    - Instala `nvidia-driver` y paquetes relacionados desde Debian. Más antiguo pero adecuado para GPU muy viejas (< serie 2000).

### Abierto vs. Propietario: Comparativa de funciones

| Función | Propietario (Cerrado) | Módulos de kernel abiertos |
| --- | --- | --- |
| Actualizaciones de kernel | Mayor riesgo de fallos DKMS | Más fluido, sensación más “nativa” |
| Wayland/Hyprland | Alto rendimiento, “probado en batalla” | Mejor preparación a futuro, uso de GSP |
| CUDA / Docker | Estándar de oro | Idéntico (el espacio de usuario es el mismo) |

Notas:
- “Idéntico” se refiere a la pila de espacio de usuario de CUDA; los módulos de kernel son distintos.
- Ambos caminos soportan CUDA, contenedores y compositores modernos; los módulos abiertos reducen fricción con DKMS.

### Por qué el predeterminado es Abierto en testing/SID

- En Debian testing/unstable el kernel cambia con frecuencia; los módulos abiertos siguen mejor las interfaces del kernel y evitan roturas DKMS.
- Mejor soporte a largo plazo para flujos de trabajo en Wayland/Hyprland.
- Mantiene idéntico el espacio de usuario al del camino propietario para CUDA/Docker.

### Guía rápida de decisión

- Serie RTX 5000 y más nuevas: elige Open (`--mode=open`).
- GPU muy viejas (< serie 2000): elige Debian (`--mode=debian`).
- Resto (series 2000–4000): Open recomendado; Proprietary también es viable.

## Advertencias importantes que muestra el script

Al ejecutarse de forma interactiva, el script muestra este aviso:

```
[INFO] La instalación predeterminada usa el repo CUDA de NVIDIA — nvidia-open (módulos de kernel abiertos).
[INFO] Guía:
  - Serie RTX 5000 y más nuevas: usa Open (requerido).
  - < serie 2000 (tarjetas muy viejas): prefiere el driver del repo de Debian.
  - Otras (2000–4000): Open recomendado; Proprietary también disponible.
[ACCIÓN] Elige la fuente de instalación:
  [O] Repo CUDA de NVIDIA — nvidia-open (módulos de kernel abiertos) [predeterminado]
  [N] Repo CUDA de NVIDIA — cuda-drivers (propietario)
  [D] Repo de Debian — nvidia-driver (empaquetado)
Selecciona [O/n/d]: _
```

## Opciones no interactivas

- `--mode=debian|nvidia|open` Selecciona la ruta de instalación.
- `--switch` Cambia desde tu variante actual al modo objetivo (elimina meta‑paquetes en conflicto).
- `--force` No salir temprano si ya está configurado; re‑ejecuta instalaciones.
- `-n, --dry-run` Simula acciones (usa `apt-get -s`, imprime cambios sin aplicarlos).
- `-h, --help` Muestra ayuda, opciones y ejemplos.

Ejemplos

```bash
# Cambiar de driver empaquetado por Debian al driver propietario del repo CUDA
install-scripts/nvidia.sh --mode=nvidia --switch

# Re‑ejecutar la ruta Debian aunque ya esté configurada
install-scripts/nvidia.sh --mode=debian --force

# Simular el flujo de módulos abiertos sin realizar cambios
install-scripts/nvidia.sh --mode=open --dry-run
```

## Salidas de ejemplo

Detección de GPU

```
[INFO] Detectando GPU NVIDIA...
[OK] Detectado (nvidia-smi): NVIDIA GeForce RTX 3050, 590.48.01
```

(Si los controladores aún no están cargados, recurre a la salida de `lspci`.)

Verificación posterior a la instalación

```
[INFO] Verificando la instalación de NVIDIA...
[OK] Origen del driver detectado: propietario (repo CUDA de NVIDIA)
[INFO] Módulo de kernel cargado: sí
[OK] nvidia-smi: NVIDIA GeForce RTX 3050, 590.48.01
[INFO] Resumen OpenGL:
OpenGL vendor string: NVIDIA Corporation
OpenGL renderer string: NVIDIA GeForce RTX 3050/PCIe/SSE2
OpenGL core profile version string: 4.6.0 NVIDIA 590.48.01
```

Resumen al finalizar

```
[OK] No se realizaron cambios.
```

O, cuando hubo cambios:

```
[OK] Cambios aplicados:
 - configured NVIDIA CUDA repo (debian13)
 - apt install: cuda-drivers
 - updated GRUB_CMDLINE_LINUX in /etc/default/grub
 - update-grub
 - update-initramfs -u
```

Salida temprana al reejecutar

```
[OK] NVIDIA ya está configurado para el modo: nvidia
[INFO] Usa --force para re‑ejecutar instalaciones, o --switch para cambiar de variante.
```

## Qué cambia en tu sistema

- APT: Añade/usa el repo CUDA de NVIDIA (ruta Debian 13) mediante `cuda-keyring` (solo si falta).
- GRUB: Añade `rd.driver.blacklist=nouveau modprobe.blacklist=nouveau nvidia-drm.modeset=1 rcutree.rcu_idle_gp_delay=1` a `GRUB_CMDLINE_LINUX` y ejecuta `update-grub`.
- Módulos: Garantiza que `nvidia nvidia_modeset nvidia_uvm nvidia_drm` estén en `/etc/initramfs-tools/modules`, luego ejecuta `update-initramfs -u`.

Todos los cambios son idempotentes; re‑ejecutar no duplicará entradas. El script imprime un resumen claro de lo que cambió o no cambió.

## Solución de problemas

- Requiere reinicio: Tras instalar los drivers, a menudo se necesita reiniciar para que el módulo `nvidia` se cargue.
- Falta `nvidia-smi`: Si no aparece de inmediato, asegúrate de que la instalación terminó y reinicia.
- Cambio de variantes: Usa `--switch` con `--mode=...` para alternar entre Debian, propietario CUDA y módulos abiertos; el script purga meta‑paquetes en conflicto primero.

## Notas de desinstalación/cambio

Los meta‑paquetes son mutuamente excluyentes por variante:

- Debian: `nvidia-driver`
- CUDA propietario: `cuda-drivers`
- Módulos abiertos: `nvidia-open`

Al cambiar, el script purga los meta‑paquetes en conflicto y ejecuta `apt autoremove` antes de instalar el objetivo.

---

Si prefieres instalar los drivers manualmente (fuera del script), hazlo primero, luego vuelve a ejecutar el instalador de Debian Hyprland y responde `No` a instalar NVIDIA para continuar con el resto de la configuración.
