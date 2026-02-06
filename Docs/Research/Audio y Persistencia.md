# Investigación Técnica: Audio y Persistencia (Love2D)

Este documento detalla cómo manejar la atmósfera sonora y el guardado de progreso en **Sygnal OS**.

## 1. Diseño Sonoro Adaptativo (Audio)

En un juego de interfaz, el sonido es el 50% de la inmersión. Love2D utiliza objetos `Source` para gestionar el audio.

### Estética "Analog Horror" / Dark Ambient

- **Drones de Fondo:** Se deben usar archivos `.ogg` en modo `stream` para no saturar la RAM. Un loop de baja frecuencia constante crea tensión.
    
- **Feedback Táctil:** Cada acción (clic, arrastrar, abrir ventana) debe tener un sonido corto y seco.
    
    - _Tip:_ Variar ligeramente el `pitch` (`source:setPitch(0.9 + math.random() * 0.2)`) en cada clic para que no suene robótico.
        

### Efectos de "Trace Level" (Audio Dinámico)

A medida que el nivel de rastreo sube, el audio debe degradarse:

- **Low-pass Filter:** Se puede simular bajando el volumen de las frecuencias altas o alternando entre dos pistas (una clara y una filtrada).
    
- **Glitches:** Disparar sonidos de estática aleatorios cuando el `Trace Level > 80%`.
    

## 2. Persistencia de Datos (Save System)

Love2D restringe el guardado al "Save Directory" de la aplicación mediante `love.filesystem`.

### Estructura del Savefile

Se recomienda guardar los datos en formato de tabla de Lua serializada o JSON.

- **Datos a persistir:**
    
    - Créditos totales.
        
    - Niveles de hardware (RAM, GPU, Storage).
        
    - Leads guardados en el Storage.
        
    - Opciones de configuración (volumen, shaders activos).
        

### Implementación con `love.filesystem`

```
local json = require("lib.json") -- Librería externa recomendada

function SaveGame()
    local data = {
        credits = player.credits,
        hardware = player.hardware,
        inventory = player.storage_leads
    }
    local serialized = json.encode(data)
    love.filesystem.write("savedata.json", serialized)
end

function LoadGame()
    if love.filesystem.getInfo("savedata.json") then
        local content = love.filesystem.read("savedata.json")
        local data = json.decode(content)
        -- Asignar datos de vuelta al estado del juego
    end
end
```

## 3. Gestión de Recursos de Audio

Para evitar retardos (lag) al disparar sonidos de UI:

- Cargar todos los efectos cortos como `static` en el `love.load`.
    
- Usar un sistema de "Sound Pool" si se planean disparar muchos sonidos hexadecimales simultáneos.
    

## 4. Checklist de Assets de Audio

- [ ] `ambience_drone_loop.ogg` (Bucle de fondo).
    
- [ ] `ui_click_low.wav` (Selección).
    
- [ ] `ui_window_open.wav` (Apertura de ventana).
    
- [ ] `hex_clean_beep.wav` (Sonido cuando un byte se aclara).
    
- [ ] `alarm_trace_detected.wav` (Alerta crítica).