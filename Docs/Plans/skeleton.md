# Plan: Esqueleto del Juego "DEEP" (Shadow Salvage / Sygnal OS)

## Resumen
Crear la estructura base del juego en Love2D: módulos con interfaces definidas, sistemas interconectados y un flujo jugable mínimo. El esqueleto debe **compilar y ejecutarse**, mostrando una ventana con la estética de OS, el taskbar, y un flujo básico de lead → hex decrypter → extracción.

## Estructura de Archivos

```
DEEP/
├── main.lua                    -- Entry point (love.load/update/draw/input)
├── conf.lua                    -- Love2D config (resolución, título)
├── src/
│   ├── state_manager.lua       -- Máquina de estados (menu, game, shop)
│   ├── ui/
│   │   ├── window.lua          -- Clase Window (drag, focus, scissor, render)
│   │   ├── window_manager.lua  -- Z-order, foco, propagación de clicks
│   │   ├── taskbar.lua         -- Barra inferior (créditos, trace, leads activos)
│   │   └── button.lua          -- Componente botón reutilizable
│   ├── systems/
│   │   ├── hex_decrypter.lua   -- Lógica de limpieza hex progresiva
│   │   ├── lead.lua            -- Generación de leads (rareza, datos, señales)
│   │   ├── hardware.lua        -- Estado hardware (RAM/GPU/SSD/CPU) y upgrades
│   │   ├── economy.lua         -- Créditos, tienda, costos
│   │   ├── trace.lua           -- Trace level (incremento, consecuencias)
│   │   └── save.lua            -- Persistencia con love.filesystem
│   └── audio/
│       └── audio_manager.lua   -- Gestión de sonido (placeholder, sin assets)
├── assets/
│   ├── fonts/                  -- (vacío, se usará fuente monospace por defecto)
│   ├── sounds/                 -- (vacío, placeholders)
│   └── shaders/
│       └── crt.glsl            -- Shader CRT básico (scanlines + vignette)
└── lib/
    └── json.lua                -- rxi/json.lua para serialización
```

## Módulos y Responsabilidades

### 1. `conf.lua`
- Resolución 1280x720, título "DEEP - Sygnal OS", vsync on

### 2. `main.lua`
- `love.load`: Inicializa state_manager, carga fuente monospace
- `love.update(dt)`: Delega al estado activo
- `love.draw`: Delega al estado activo, aplica shader CRT
- `love.mousepressed/mousereleased/keypressed`: Delega al estado activo

### 3. `src/state_manager.lua`
- Estados: `menu`, `game`
- Interfaz: `switch(state_name)`, `update(dt)`, `draw()`, `mousepressed(x,y,btn)`

### 4. `src/ui/window.lua` (Clase Window)
- Propiedades: id, x, y, w, h, title, is_dragging, offset_x/y, content_draw_fn
- Métodos: `draw()`, `update(dt)`, `mousepress(x,y)`, `mouserelease()`, `isInside(x,y)`, `isInTitleBar(x,y)`
- Renderizado: Barra de título oscura, borde pixelado, scissor para contenido

### 5. `src/ui/window_manager.lua`
- Tabla `windows` ordenada por z-order
- `addWindow(win)`, `removeWindow(id)`, `bringToFront(win)`
- Propagación de clicks: recorre de atrás→adelante, la primera que captura detiene propagación
- `update(dt)`: Actualiza ventana en drag
- `draw()`: Dibuja todas en orden

### 6. `src/ui/taskbar.lua`
- Barra fija en la parte inferior (siempre encima de todo)
- Muestra: Créditos | Trace Level (barra) | Leads activos | Botón Tienda
- Se dibuja después de todas las ventanas

### 7. `src/ui/button.lua`
- Propiedades: x, y, w, h, label, onClick, hover state
- Métodos: `draw()`, `isInside(x,y)`, `click()`

### 8. `src/systems/lead.lua`
- Genera leads con rareza (60% basura, 30% estándar, 8% raro, 2% jackpot)
- Cada lead: `{ id, rarity, real_data, reward_range, signal_hint, security_level }`
- `generateLead()`: Crea un lead con datos hex aleatorios y valor real
- `generateHexData(rarity)`: Genera el buffer de bytes según rareza

### 9. `src/systems/hex_decrypter.lua`
- Recibe un lead y gestiona su procesamiento
- `progress`: 0 → 1.0
- `buffer[]`: Array de caracteres mostrados (mezcla ruido + dato real según progress)
- `update(dt, gpu_speed)`: Incrementa progreso, actualiza buffer
- `draw(x, y, w, h)`: Renderiza cuadrícula hex 16 columnas + ASCII lateral
- Fases: 0-30% ruido, 40% revelación parcial, 60-80% claridad, 100% extracción
- `abort()`: Devuelve 60% del costo invertido
- `extract()`: Calcula recompensa del lead

### 10. `src/systems/hardware.lua`
- Estado: `{ ram={level=0, slots=1}, gpu={level=0, speed=1}, ssd={level=0, capacity=3}, cpu={level=0, efficiency=1} }`
- `getMaxWindows()`: Basado en nivel de RAM
- `getDecryptSpeed()`: Basado en nivel de GPU
- `getMaxLeads()`: Basado en nivel de SSD
- `getTraceMultiplier()`: Basado en nivel de CPU
- `getUpgradeCost(component)`: Costo exponencial (base * 2^level)
- `upgrade(component)`: Incrementa nivel si hay créditos

### 11. `src/systems/economy.lua`
- `credits`: Entero
- `addCredits(n)`, `spendCredits(n)`: Transacciones
- `canAfford(n)`: Check

### 12. `src/systems/trace.lua`
- `level`: 0.0 → 1.0
- `update(dt, active_windows, hardware)`: Incrementa según ventanas activas y eficiencia CPU
- `getConsequences()`: Retorna nivel de alerta (none, flicker, close_windows, raid)
- `reset()`: Baja gradualmente cuando no hay ventanas activas
- `onRaid()`: Penalización (daña hardware, multa créditos)

### 13. `src/systems/save.lua`
- `save(game_state)`: Serializa a JSON y guarda con love.filesystem
- `load()`: Lee JSON y deserializa
- Usa `lib/json.lua` (rxi/json.lua) para encode/decode

### 14. `src/audio/audio_manager.lua`
- Interfaz placeholder: `playClick()`, `playAlarm()`, `playAmbience()`
- No requiere assets reales; los métodos serán no-op hasta agregar sonidos

### 15. `assets/shaders/crt.glsl`
- Shader GLSL básico: scanlines horizontales + vignette en esquinas
- Parámetro `trace_intensity` para aumentar flicker con trace alto

## Flujo del Esqueleto (lo que se puede hacer al ejecutar)

1. El juego arranca en estado `menu` con texto "PRESS ENTER TO BOOT SYGNAL OS"
2. Al presionar Enter, cambia a estado `game`
3. En `game`: se ve el desktop vacío con taskbar abajo (créditos: 500, trace: 0%)
4. Cada ~5 segundos llega un nuevo lead (notificación en taskbar)
5. Click en lead del taskbar → abre ventana Hex-Decrypter con contenido hex animándose
6. El progreso avanza automáticamente según GPU speed
7. A 40% aparece opción "ABORT" visible
8. A 100% aparece botón "EXTRACT" → suma créditos
9. Trace level sube mientras hay ventanas abiertas
10. Ctrl+S abre ventana de tienda con upgrades de hardware
11. Si trace llega a 100% → raid → penalización

## Verificación
- `cd DEEP && love .` debe ejecutar sin errores
- Se debe ver el menú, la transición al desktop, y poder procesar al menos un lead completo
- El trace debe subir y bajar correctamente
- La tienda debe permitir comprar un upgrade
