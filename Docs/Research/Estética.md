# Guía de Iconos 1-bit: Sygnal OS (Macintosh Style)

Esta guía define la estética visual de los iconos del escritorio, siguiendo los principios de diseño de 1984: simplicidad, alto contraste y metáforas claras.

## 1. Principios de Diseño (Susan Kare Style)

- **Cuadrícula:** Siempre 32x32 píxeles.
    
- **Color:** Solo Blanco y Negro (1-bit). El gris se logra mediante "Dithering" (patrones de puntos intercalados).
    
- **Sombra:** Una línea negra de 1px de grosor desplazada 1px a la derecha y 1px abajo para dar profundidad.
    
- **Bordes:** Bordes negros definidos para que el icono no se pierda en el fondo gris.
    

## 2. Catálogo de Iconos

### A. Mail (Postbox)

**Metáfora:** Un buzón de correos clásico con la bandera levantada.

- **Estado Leído:** Bandera abajo.
    
- **Estado Nuevo Lead:** Bandera arriba y un pequeño sobre asomando.
    
- **Detalle:** Usar líneas diagonales de 1px para el cuerpo del buzón.
    

### B. VoidMarket (The Boutique)

**Metáfora:** Una bolsa de compras de papel o un escaparate antiguo.

- **Diseño:** Una bolsa con asas arqueadas. En el centro, el símbolo `$` o un pequeño chip pixelado.
    
- **Detalle:** Un patrón de puntos (dithering) en el lateral de la bolsa para simular volumen.
    

### C. Hex-Decrypter (Bit-Salvage)

**Metáfora:** Un disquete con un martillo o una lupa.

- **Diseño:** El contorno de un disquete de 3.5". Encima, cruzado diagonalmente, un martillo de carpintero (representando el "salvamento" de datos).
    
- **Detalle:** El martillo debe tener un brillo blanco en la parte superior para separarlo del disquete negro.
    

### D. Hardware Monitor (System Stats)

**Metáfora:** Un pequeño ordenador Macintosh compacto.

- **Diseño:** El icónico perfil del Mac original: pantalla cuadrada, ranura de disquete abajo a la derecha.
    
- **Detalle:** En la "pantalla" del icono, dibujar una pequeña barra de progreso pixelada.
    

### E. Trash (Papelera)

**Metáfora:** Un cubo de basura metálico con tapa.

- **Estado Vacío:** Cubo normal.
    
- **Estado Lleno (Leads descartados):** El cubo se ve ligeramente deformado o "abultado" con papeles saliendo.
    

## 3. Representación en Píxeles (Ejemplo: Hex-Decrypter)

Aquí tienes una aproximación de cómo se vería la cuadrícula del disquete (32x32):

```
  ############################
  #                          #
  #   [      LABEL      ]    #
  #                          #
  #   ####################   #
  #   #                  #   #
  #   #     (DATO)       #   #
  #   #                  #   #
  #   ####################   #
  #                          #
  #            _______       #
  #           /       \      #
  #          | HAMMER  |     #
  #           \_______/      #
  ############################
```

## 4. Implementación en Love2D

Para manejar estos iconos en tu código, te recomiendo dos opciones:

1. **Spritesheet:** Crear una imagen `.png` de 1-bit con todos los iconos alineados y usar `love.graphics.newQuad` para seleccionarlos.
    
2. **Canvas de Dibujo:** Dibujarlos manualmente píxel a píxel si quieres que sean procedimentales (aunque es más lento).
    

### Tip técnico para el "Olfato":

Cuando el jugador pase el mouse sobre un lead en el Mail, puedes cambiar el cursor del sistema al icónico **"Dedo que señala"** de Macintosh:

```
-- Cursor estilo System 7
local classic_hand = love.mouse.newCursor("assets/cursors/mac_hand.png", 10, 0)
love.mouse.setCursor(classic_hand)
```

## 5. Paleta de Colores Sugerida (Platinum)

Aunque el arte sea 1-bit (Blanco/Negro), el fondo del escritorio debería usar estos valores para el look "Platinum":

- **Gris Base:** `{0.75, 0.75, 0.75}` (RGD 192, 192, 192)
    
- **Sombra Profunda:** `{0.5, 0.5, 0.5}`
    
- **Texto / Bordes:** `{0, 0, 0}`