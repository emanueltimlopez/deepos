# Plan: Implementar Loop & Progresión según Research Docs

## Context

El juego tiene las mecánicas básicas (leads, decrypter, trace, shop, raid) pero el loop es plano: todos los leads se sienten iguales, no hay decisión significativa antes de abrir un lead, no hay virus/peligro durante el decrypt, y no hay progresión de conocimiento. Los research docs definen un loop mucho más rico con triaje, riesgo de virus, Manual.txt como herramienta de referencia, y progresión por conocimiento.

## Cambios organizados en 6 bloques

### Bloque 1: Lead Generation con patrones hex significativos
**Archivo**: `src/systems/lead.lua`

- Generar hex data que refleje la rareza visualmente:
  - **Basura**: Bloques repetidos (`00 00 00`, `FF FF FF`), sectores muertos
  - **Standard**: Mix de ASCII legible y basura
  - **Rare**: Datos densos y variados, pocos huecos
  - **Jackpot**: Estructuras complejas, muy densas
- Añadir campo `lead.is_virus` (10% chance en basura, 5% en standard): el lead parece normal en snapshot pero contiene cadena maliciosa que aparece durante decrypt
- Añadir campo `lead.virus_pattern` (ej: "TROJAN.V3", "WORM.X1", "ROOTKIT")
- Implementar **sistema 80/20 "olfato"**: campo `lead.snapshot_fidelity` — 80% de las veces el snapshot visual corresponde al valor real, 20% de las veces un lead bueno parece malo o viceversa (se refleja en `hex_data` vs el valor real)
- Añadir campo `lead.hex_preview` — un subset pequeño (16 chars) para mostrar en inbox como snapshot

### Bloque 2: Inbox con Triaje (Trash + Preview)
**Archivo**: `src/ui/inbox_window.lua`

- Mostrar hex snapshot preview (16 chars del lead) en cada entrada del inbox
- Añadir botón **"Trash"** junto a "Open" — descarta el lead sin procesarlo (sin costo de recursos)
- Subir capacidad de inbox display (mostrar hasta 10 leads)
- Mostrar indicador visual de tipo: icono de peligro si snapshot tiene patrones sospechosos (para que el jugador use su "olfato")

### Bloque 3: Virus system en Hex Decrypter
**Archivo**: `src/systems/hex_decrypter.lua`

- Si `lead.is_virus == true`: a cierto % de progreso (25-35%), revelar la cadena del virus en el buffer (ej: `TROJAN.V3` aparece en los caracteres hex)
- Nuevo estado: `self.virus_revealed = true` cuando el patrón se muestra
- Si el jugador NO aborta antes del 60%, el virus se ejecuta:
  - **System Crash**: cerrar TODAS las ventanas, perder leads del inbox, penalización de créditos
  - Diferente del raid — es culpa del jugador por no leer el manual
- Actualizar `main.lua` `openDecrypterWindow` para manejar el caso virus (nuevo botón o el abort existente sirve)
- Hacer el botón Abort visible desde el inicio (no solo al 40%) para que el jugador pueda abortar en cualquier momento si detecta un virus

### Bloque 4: Manual.txt — Ventana de referencia
**Archivos**: `src/systems/manual.lua` (nuevo), `main.lua`

- Nuevo sistema `Manual` con niveles (v1, v2, v3):
  - **v1 (gratis)**: Patrones básicos de basura (`00 00`, `FF FF`, sectores muertos), patrones de virus conocidos (TROJAN, WORM)
  - **v2 (comprable)**: Patrones de falsos positivos, headers válidos avanzados
  - **v3 (comprable)**: Todas las firmas incluyendo jackpot markers
- Ventana Manual.txt: texto paginado con "Prev Page" / "Next Page"
- Desktop icon "Manual" en el escritorio
- El contenido son strings de referencia que el jugador compara visualmente con el hex decrypter

### Bloque 5: Trace system — Balance según research
**Archivo**: `src/systems/trace.lua`

- Cambiar rate a **0.1% por segundo por ventana** (actualmente ~2% * multiplier)
- Leads jackpot activos añaden **0.5% extra por segundo** al trace
- Actualizar consecuencias:
  - **70%**: Flicker visual (actualmente en 40%)
  - **90%**: Cerrar ventana aleatoria cada 3-5 segundos
  - **100%**: Raid (ya implementado)
- Implementar cierre aleatorio de ventanas en `main.lua` GameState:update cuando trace >= 90%
- Pasar info de leads activos (rareza) al trace para calcular bonus de jackpot

### Bloque 6: Shop — Knowledge upgrades
**Archivo**: `main.lua` (shop window), `src/systems/hardware.lua`

- Añadir upgrades de conocimiento al Hardware system (o al Manual system):
  - **Manual v2**: 500 CR — desbloquea página 2 del manual
  - **Manual v3**: 1500 CR — desbloquea página 3 del manual
  - **OCR Scanner**: 3000 CR — resalta automáticamente patrones conocidos en el hex decrypter (late game QoL)
- Mostrar estos upgrades en la shop como sección separada "Software"

## Archivos a modificar/crear

| Archivo | Acción |
|---|---|
| `src/systems/lead.lua` | Modificar: patrones hex por rareza, virus, snapshot, preview |
| `src/ui/inbox_window.lua` | Modificar: preview hex, botón Trash, capacidad |
| `src/systems/hex_decrypter.lua` | Modificar: virus reveal, abort temprano, crash |
| `src/systems/manual.lua` | **Nuevo**: sistema de manual con niveles y contenido |
| `src/systems/trace.lua` | Modificar: rates, consecuencias 70/90/100 |
| `src/systems/hardware.lua` | Modificar: añadir software upgrades |
| `main.lua` | Modificar: manual window, shop software section, trace window-close, virus crash handler, manual desktop icon |

## Orden de implementación

1. `lead.lua` — Base: patrones hex significativos + virus + preview
2. `manual.lua` — Nuevo: contenido de referencia por nivel
3. `hex_decrypter.lua` — Virus reveal + abort temprano
4. `trace.lua` — Nuevos rates y consecuencias
5. `inbox_window.lua` — Preview + Trash
6. `hardware.lua` — Software upgrades
7. `main.lua` — Integrar todo: manual window, shop software, virus crash, trace window-close, desktop icon

## Verificación

- Abrir el juego, ver leads con patrones hex distintos por rareza
- Abrir inbox, ver hex preview, poder hacer Trash a un lead
- Abrir Manual desde desktop icon, ver patrones de referencia
- Abrir un lead virus, ver patrón aparecer ~30%, abortar a tiempo
- No abortar virus → system crash (ventanas cerradas, leads perdidos)
- Trace sube 0.1%/s por ventana, a 70% flicker, a 90% ventanas se cierran solas
- Shop muestra sección Software con Manual v2/v3 y OCR Scanner
- Comprar Manual v2 → nueva página en Manual.txt
