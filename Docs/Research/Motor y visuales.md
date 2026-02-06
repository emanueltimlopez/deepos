# Investigación Técnica: Sygnal OS (Love2D/Lua)

Este documento detalla la implementación técnica de las mecánicas de "Arqueólogo de la Red Profunda" utilizando el framework Love2D.

## 1. Motor de Ventanas y Z-Order

Dado que Love2D no tiene un sistema de ventanas nativo, implementaremos uno personalizado que permita la estética de un sistema operativo "sucio" y retro.

### Arquitectura de Objetos (OOP en Lua)

- **Estructura de Ventana:** Cada ventana se maneja como una tabla:
    
    ```
    window = {
        id = "hex_decrypter_01",
        x = 100, y = 100, w = 400, h = 300,
        title = "ROOT_ARCHIVE_04",
        progress = 0,
        is_focused = true,
        data_buffer = {}, -- Almacena los bytes a mostrar
        resource_cost = 10 -- RAM bloqueada
    }
    ```
    
- **Z-Order (Profundidad):** Se mantiene una tabla global `ActiveWindows`. Al hacer clic en una ventana, se mueve al final de la tabla para que se dibuje última (encima de las demás).
    
- **Scissoring:** Crucial para el contenido interno. Usamos `love.graphics.setScissor(x, y, w, h)` para que el texto hexadecimal no se dibuje fuera de los bordes de la ventana al arrastrarla.
    

## 2. Efectos Visuales y Shaders

La atmósfera de "hacker" y "lost media" se apoya en el renderizado de texto y filtros de post-procesado.

### El Efecto Hexadecimal (Aclarado Progresivo)

El "olfato" se basa en ver cómo el código pasa de ruido aleatorio a datos legibles:

- **Lógica de Limpieza:**
    
    ```
    -- En cada actualización del progreso:
    for i = 1, #buffer do
        if math.random() < current_progress then
            buffer[i] = real_data[i] -- Carácter real (p.ej. 'U')
        else
            buffer[i] = string.char(love.math.random(33, 126)) -- Ruido ASCII
        end
    end
    ```
    

### Shaders de Monitor CRT (GLSL)

Utilizaremos un shader personalizado para añadir:

- **Scanlines:** Líneas horizontales negras sutiles que recorren la pantalla.
    
- **Vignette:** Oscurecimiento de las esquinas para dar sensación de tubo antiguo.
    
- **Flicker:** Pequeñas variaciones de brillo aleatorias cuando el `Trace Level` es alto.
    

## 3. Gestión de Hardware (Abstracción)

El hardware se gestiona como variables de estado globales que limitan la lógica de Love2D:

- **RAM:** Funciona como un contador de "slots". `if slots_usados + cost_nuevo > RAM_total then return error end`.
    
- **GPU:** Define la velocidad de actualización de las tablas de caracteres. A mayor GPU, mayor es el incremento de `progress` por segundo.
    
- **Storage:** Una tabla simple que guarda "Snapshots" (objetos Lead) recibidos por mail que aún no se han procesado.
    

## 4. Entrada y Colisiones

- **Mouse Interaction:** Se detecta el clic en la barra superior para iniciar el arrastre (`is_dragging`).
    
- **Prioridad de Clic:** Se recorre la lista de ventanas de atrás hacia adelante para detectar colisiones. La primera ventana encontrada (la que está más "arriba") captura el clic y detiene la propagación.
    

## 5. Librerías Recomendadas

- **Lume:** Para manipular tablas de ventanas de forma eficiente.
    
- **HUMP (Timer):** Para gestionar los tiempos de "limpieza" y los eventos de riesgo.
    
- **Cargo:** Para organizar los assets (fuentes monospaced, sonidos de estática).