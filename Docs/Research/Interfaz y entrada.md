# Investigación Técnica: Interfaz y Entrada Avanzada

Para que **Sygnal OS** se sienta como un sistema operativo real en Love2D, la interacción debe ser fluida y lógica.

## 1. Interacciones de Mouse Complejas

### Arrastrar y Soltar (Drag & Drop)

Para mover ventanas o archivos, necesitamos un estado de "captura":

- **Lógica:**
    
    1. En `love.mousepressed`, detectamos si el clic fue en la barra de título.
        
    2. Si es así, marcamos esa ventana como `is_dragging = true` y guardamos el `offset` (distancia del mouse al borde de la ventana).
        
    3. En `love.update`, si `is_dragging`, actualizamos `window.x = mouse_x - offset_x`.
        
    4. En `love.mousereleased`, reseteamos `is_dragging = false`.
        

### El Sistema de Foco (Top-Level Window)

Cuando hay múltiples ventanas solapadas:

- Solo la ventana con el `zIndex` más alto debe procesar clics internos.
    
- Al hacer clic en cualquier parte de una ventana, esta debe saltar al final de la lista de dibujado para quedar "arriba".
    

## 2. Entrada de Teclado y Comandos

Incluso siendo un juego de ventanas, el teclado añade profundidad (atajos de hacker).

### Atajos de Teclado (Hotkeys)

- `Tab`: Cambiar de ventana activa rápidamente.
    
- `Esc`: Abortar el lead actual (si la ventana tiene foco).
    
- `Ctrl + S`: Acceso rápido a la tienda (Deep Web Store).
    

### Captura de Texto (`love.textinput`)

Si implementamos un mini-juego de "Brute Force", usaremos `love.textinput(text)` en lugar de `love.keypressed`. Esto maneja correctamente caracteres especiales y repetición de teclas.

## 3. Optimización del Renderizado de Ventanas

Dibujar cientos de caracteres hexadecimales en cada frame puede ser costoso si no se hace bien.

### Uso de Canvas (Off-screen Rendering)

En lugar de redibujar todo el texto de la ventana cada frame:

1. Crear un `love.graphics.newCanvas(w, h)` para cada ventana de descifrado.
    
2. Dibujar el texto hexadecimal en el Canvas solo cuando el contenido cambie (ej: cada 0.1 segundos).
    
3. En `love.draw`, simplemente dibujar el Canvas de la ventana. Esto reduce drásticamente las llamadas a la GPU.
    

## 4. Cursor Dinámico

Cambiar el cursor del mouse según el contexto mejora la UI:

- **Default:** Puntero clásico.
    
- **Hand:** Al pasar sobre un byte que se puede extraer o un botón de "Abortar".
    
- **Wait:** Cuando la GPU está al 100% procesando un lead pesado.
    

```
local cursor_pointer = love.mouse.getSystemCursor("arrow")
local cursor_hand = love.mouse.getSystemCursor("hand")

function love.update(dt)
    if is_hovering_button then
        love.mouse.setCursor(cursor_hand)
    else
        love.mouse.setCursor(cursor_pointer)
    end
end
```

## 5. Menú de Inicio y Barra de Tareas

La barra de tareas debe actuar como un contenedor estático:

- No se ve afectada por el Z-Order de las ventanas (siempre está en el `zIndex` máximo o mínimo).
    
- Muestra iconos con el estado de progreso de cada lead activo, permitiendo al jugador monitorear el "olfato" sin tener la ventana al frente.