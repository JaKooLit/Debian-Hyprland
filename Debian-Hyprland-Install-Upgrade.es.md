# Guía de Instalación y Actualización de Debian-Hyprland

Esta guía cubre los flujos de instalación y actualización mejorados para el proyecto Debian-Hyprland de KooL, incluyendo nuevas funciones de automatización, gestión centralizada de versiones y capacidades de dry-run.

## Tabla de Contenidos

1. [Resumen](#resumen)
2. [Nuevas Funciones](#nuevas-funciones)
3. [Gestión Central de Versiones](#gestión-central-de-versiones)
4. [Métodos de Instalación](#métodos-de-instalación)
5. [Flujos de Actualización](#flujos-de-actualización)
6. [Pruebas con Dry-Run](#pruebas-con-dry-run)
7. [Gestión de Logs](#gestión-de-logs)
8. [Uso Avanzado](#uso-avanzado)
9. [Solución de Problemas](#solución-de-problemas)

## Resumen

El proyecto Debian-Hyprland ahora incluye herramientas de automatización y gestión mejoradas, manteniendo la compatibilidad con el script original install.sh. Las principales adiciones son:

- **Gestión centralizada de versiones** mediante `hypr-tags.env`
- **Orden automático de dependencias** para los requisitos de Hyprland 0.51.x
- **Pruebas de compilación con dry-run** sin modificar el sistema
- **Actualizaciones selectivas de componentes** con `update-hyprland.sh`
- **Obtención automática de últimas versiones** desde GitHub

## Nuevas Funciones

### install.sh mejorado
El script original ahora:

- **Unifica versiones**: Lee `hypr-tags.env` y exporta variables de versión a todos los módulos
- **wayland-protocols automático**: Instala wayland-protocols desde el código fuente (≥1.45) antes de Hyprland
- **Orden robusto de dependencias**: Garantiza la secuencia correcta de requisitos

### Nuevos Scripts

#### update-hyprland.sh
Herramienta enfocada para gestionar y compilar solo el stack de Hyprland:
```bash
chmod +x ./update-hyprland.sh
./update-hyprland.sh --help  # Ver todas las opciones
```

#### dry-run-build.sh
Herramienta de pruebas que compila componentes sin instalarlos:
```bash
chmod +x ./dry-run-build.sh
./dry-run-build.sh --help  # Ver todas las opciones
```

#### wayland-protocols-src.sh
Módulo que compila wayland-protocols desde el origen para satisfacer los requisitos de Hyprland 0.51.x.

## Gestión Central de Versiones

### hypr-tags.env
Archivo con etiquetas de versión para todos los componentes de Hyprland:

```bash
# Versiones actuales (ejemplo)
HYPRLAND_TAG=v0.51.1
AQUAMARINE_TAG=v0.9.3
HYPRUTILS_TAG=v0.8.2
HYPRLANG_TAG=v0.6.4
HYPRGRAPHICS_TAG=v0.1.5
HYPRWAYLAND_SCANNER_TAG=v0.4.5
HYPRLAND_PROTOCOLS_TAG=v0.6.4
HYPRLAND_QT_SUPPORT_TAG=v0.1.0
HYPRLAND_QTUTILS_TAG=v0.1.4
WAYLAND_PROTOCOLS_TAG=1.45
```

### Prioridad de Sobrescritura de Versiones
1. Variables de entorno (exportadas)
2. Valores en el archivo `hypr-tags.env`
3. Valores por defecto en cada módulo

## Métodos de Instalación

### Método 1: Instalación Completa Original
```bash
# Instalación estándar con todos los componentes
chmod +x install.sh
./install.sh
```

Ahora, este método automáticamente:
- Carga versiones desde `hypr-tags.env`
- Instala wayland-protocols desde el origen antes de Hyprland
- Mantiene el orden correcto de dependencias

### Método 2: Solo el Stack de Hyprland
```bash
# Instala solo Hyprland y componentes esenciales
./update-hyprland.sh --install
```

### Método 3: Instalación Nueva con Últimas Versiones
```bash
# Obtiene últimas versiones de GitHub e instala
./update-hyprland.sh --fetch-latest --install
```

### Método 4: Instalación con Preset
```bash
# Usa un preset para elecciones automáticas
./install.sh --preset ./preset.sh
```

## Flujos de Actualización

Enlace rápido: [Actualización 0.49/0.50.x → 0.51.1](#actualización-049050x--0511)

### Actualizar a la Última Versión de Hyprland

#### Opción A: Descubrimiento Automático
```bash
# Obtiene las últimas etiquetas e instala
./update-hyprland.sh --fetch-latest --install
```

#### Opción B: Versión Específica
```bash
# Establece una versión específica de Hyprland
./update-hyprland.sh --set HYPRLAND=v0.51.1 --install
```

#### Opción C: Probar Antes de Instalar
```bash
# Prueba la compilación primero, luego instala si es exitoso
./update-hyprland.sh --fetch-latest --dry-run
# Si es exitoso:
./update-hyprland.sh --install
```

### Actualizar Componentes Individuales

```bash
# Actualiza solo librerías núcleo (a menudo necesario para nuevas versiones de Hyprland)
./update-hyprland.sh --fetch-latest --install --only hyprutils,hyprlang

# Actualiza aquamarine específicamente
./update-hyprland.sh --set AQUAMARINE=v0.9.3 --install --only aquamarine
```

### Actualizaciones Selectivas

```bash
# Instalar todo excepto los componentes Qt
./update-hyprland.sh --install --skip hyprland-qt-support,hyprland-qtutils

# Instalar solo componentes específicos
./update-hyprland.sh --install --only hyprland,aquamarine
```

### Actualización: 0.49/0.50.x ➜ 0.51.1

Si actualmente estás en Hyprland 0.49 o 0.50.x, puedes actualizar directamente a 0.51.1 sin una reinstalación completa.

Ruta recomendada:
```bash
# Asegura que hypr-tags.env apunte a la versión objetivo (omitir si ya es v0.51.1)
./update-hyprland.sh --set HYPRLAND=v0.51.1

# Actualiza Hyprland (los prerrequisitos se incluyen y ordenan automáticamente)
./update-hyprland.sh --install --only hyprland
```

Notas:
- El comando garantiza y ejecuta, según sea necesario: wayland-protocols-src, hyprland-protocols, hyprutils, hyprlang, aquamarine y luego hyprland.
- No es necesario usar install.sh para esta actualización, a menos que también quieras instalar/actualizar módulos opcionales (p. ej., SDDM, Bluetooth, Thunar, AGS, dotfiles) o estés recuperándote de una instalación fallida/parcial.
- Opcional: agrega --with-deps para reinstalar dependencias primero:
```bash
./update-hyprland.sh --with-deps --install --only hyprland
```
- Puedes hacer un dry-run primero para validar:
```bash
./update-hyprland.sh --dry-run --only hyprland
```

## Pruebas con Dry-Run

### ¿Por qué usar Dry-Run?
- Probar compatibilidad de compilación antes de instalar
- Validar combinaciones de versiones
- Depurar problemas de compilación sin cambios en el sistema
- Integración en CI/CD

### Uso Básico de Dry-Run

```bash
# Probar la configuración actual de versiones
./update-hyprland.sh --dry-run

# Probar con últimas versiones de GitHub
./update-hyprland.sh --fetch-latest --dry-run

# Probar una versión específica
./update-hyprland.sh --set HYPRLAND=v0.51.1 --dry-run
```

### Pruebas Avanzadas con Dry-Run

```bash
# Formato alternativo de resumen
./update-hyprland.sh --via-helper

# Probar con instalación de dependencias
./dry-run-build.sh --with-deps

# Probar solo componentes específicos
./dry-run-build.sh --only hyprland,aquamarine
```

### Limitaciones de Dry-Run
- **Las dependencias se instalan**: apt se ejecuta para asegurar la compilación
- **Requisitos de pkg-config**: Algunos componentes necesitan requisitos instalados en el sistema
- **Sin cambios en el sistema**: No instala archivos en /usr/local o /usr

## Gestión de Logs

### Ubicación de Logs
Todas las actividades de construcción generan logs con sello de tiempo en:
```
Install-Logs/
├── 01-Hyprland-Install-Scripts-YYYY-MM-DD-HHMMSS.log  # Log principal de instalación
├── install-DD-HHMMSS_module-name.log                   # Logs por módulo
├── build-dry-run-YYYY-MM-DD-HHMMSS.log                # Resumen de dry-run
└── update-hypr-YYYY-MM-DD-HHMMSS.log                  # Resumen de actualización
```

### Análisis de Logs
```bash
# Ver el log de instalación más reciente
ls -t Install-Logs/*.log | head -1 | xargs less

# Buscar errores en un módulo específico
grep -i error Install-Logs/install-*hyprland*.log

# Ver resumen de dry-run
cat Install-Logs/build-dry-run-*.log
```

### Retención de Logs
- Los logs se acumulan con el tiempo para referencia histórica
- Se recomienda limpieza manual periódica:
```bash
# Mantener solo logs de los últimos 30 días
find Install-Logs/ -name "*.log" -mtime +30 -delete
```

## Uso Avanzado

### Gestión de Versiones

#### Copia de Seguridad y Restauración
```bash
# Las etiquetas se respaldan automáticamente cuando cambian
# Restaurar la copia más reciente
./update-hyprland.sh --restore --dry-run
```

#### Múltiples Conjuntos de Versiones
```bash
# Guardar configuración actual
cp hypr-tags.env hypr-tags-stable.env

# Probar versiones experimentales
./update-hyprland.sh --fetch-latest --dry-run

# Restaurar estable si es necesario
cp hypr-tags-stable.env hypr-tags.env
```

### Integración con el Entorno

#### PKG_CONFIG_PATH personalizado
```bash
# Asegurar que /usr/local tenga prioridad
export PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:/usr/local/share/pkgconfig:${PKG_CONFIG_PATH:-}"
./update-hyprland.sh --install
```

#### Compilaciones en Paralelo
```bash
# Controlar el paralelismo (por defecto: todos los núcleos)
export MAKEFLAGS="-j4"
./update-hyprland.sh --install
```

### Flujo de Trabajo de Desarrollo

#### Probar Nuevos Lanzamientos
```bash
# 1. Crear entorno de pruebas
cp hypr-tags.env hypr-tags.backup

# 2. Probar nueva versión
./update-hyprland.sh --set HYPRLAND=v0.52.0 --dry-run

# 3. Instalar si es exitoso
./update-hyprland.sh --install

# 4. Revertir si hay problemas
./update-hyprland.sh --restore --install
```

#### Desarrollo de Componentes
```bash
# Solo instalar dependencias
./update-hyprland.sh --with-deps --dry-run

# Pruebas manuales de módulo
DRY_RUN=1 ./install-scripts/hyprland.sh

# Ver logs de un módulo específico
tail -f Install-Logs/install-*hyprland*.log
```

## Solución de Problemas

### Problemas Comunes

#### Falla de Configuración con CMake
**Síntomas**: "Package dependency requirement not satisfied"

**Soluciones**:
```bash
# Instalar requisitos faltantes
./update-hyprland.sh --install --only wayland-protocols-src,hyprutils,hyprlang

# Limpiar caché de compilación
rm -rf hyprland aquamarine hyprutils hyprlang

# Reintentar instalación
./update-hyprland.sh --install --only hyprland
```

#### Errores de Compilación
**Síntomas**: "too many errors emitted"

**Soluciones**:
```bash
# Actualizar dependencias núcleo primero
./update-hyprland.sh --fetch-latest --install --only hyprutils,hyprlang

# Revisar incompatibilidades de API en logs
grep -A5 -B5 "error:" Install-Logs/install-*hyprland*.log
```

#### Etiqueta No Encontrada
**Síntomas**: "Remote branch X not found"

**Soluciones**:
```bash
# Ver etiquetas disponibles
git ls-remote --tags https://github.com/hyprwm/Hyprland

# Usar etiqueta confirmada
./update-hyprland.sh --set HYPRLAND=v0.50.1 --install
```

### Pasos de Depuración

1. **Verificar compatibilidad del sistema**:
   ```bash
   # Verificar versión de Debian
   cat /etc/os-release
   
   # Asegurar deb-src habilitado
   grep -E "^deb-src" /etc/apt/sources.list
   ```

2. **Verificar entorno**:
   ```bash
   # Ver etiquetas actuales
   cat hypr-tags.env
   
   # Probar dry-run primero
   ./update-hyprland.sh --dry-run --only hyprland
   ```

3. **Analizar logs**:
   ```bash
   # Errores más recientes
   grep -i "error\|fail" Install-Logs/*.log | tail -20
   
   # Problemas por módulo
   ls -la Install-Logs/install-*[component]*.log
   ```

### Obtener Ayuda

1. **Revisar logs**: Consulte siempre Install-Logs/ para detalles
2. **Probar dry-run**: Valide antes de instalar
3. **Soporte de la comunidad**: Envíe issues con extractos de logs
4. **Documentación**: Consulte README.md del proyecto para requisitos base

## Migración desde Versiones Previas

### Instalaciones Existentes
Las nuevas herramientas funcionan junto a instalaciones existentes:

```bash
# Actualizar instalación existente
./update-hyprland.sh --install

# Probar sin afectar el sistema actual
./update-hyprland.sh --dry-run
```

### Convertir a Gestión por Etiquetas
```bash
# Las versiones actuales se guardan en hypr-tags.env automáticamente
# Verificar con:
cat hypr-tags.env

# Modificar versiones según necesidad:
./update-hyprland.sh --set HYPRLAND=v0.51.1
```

El flujo mejorado ofrece mayor control, capacidad de prueba y automatización, manteniendo la compatibilidad total con el proceso de instalación original.
