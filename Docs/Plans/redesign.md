 Plan: Rediseño Estético — De Terminal Verde a Macintosh System 7 / Platinum

 Resumen

 Transformar toda la estética visual del juego: abandonar el look verde terminal/hacker y adoptar el estilo Macintosh System 7 / Platinum (gris, blanco/negro, bordes biselados 3D, barras de título con rayas horizontales). El juego debe seguir siendo completamente jugable
  — solo cambia el renderizado visual, no la lógica.

 Decisiones de Diseño

 1. Barra inferior se mantiene pero restyled como "Control Strip" Platinum gris. Se agrega una barra de menú decorativa arriba (20px) con logo, menús decorativos y reloj.
 2. Íconos de escritorio: Diferido a futuro (no es reskin visual, es feature nuevo).
 3. Shader CRT: Se mantienen scanlines + vignette suavizados, se elimina tinte verde, flicker pasa a ser gris/blanco neutro.
 4. Íconos 32x32: Diferido — se implementará cuando se agreguen íconos al escritorio.
 5. Patrón dither del desktop: Pre-renderizado a canvas para performance.

 Archivos a Modificar (7 archivos, 1 nuevo)

 1. NUEVO: src/ui/theme.lua — Paleta central + helpers de dibujo

 - Paleta Platinum: gris base {0.75, 0.75, 0.75}, sombra {0.5, 0.5, 0.5}, texto {0, 0, 0}
 - Colores: ventanas blancas, bordes negros, botones grises con bevel 3D
 - Helpers: drawBeveledRect(), drawTitleBarStripes(), drawCloseBox(), drawDesktopPattern() (pre-renderizado a canvas)

 2. src/ui/button.lua — Botones Platinum 3D

 - Cambiar draw(): fondo gris {0.75}, highlight blanco arriba-izq, sombra oscura abajo-der, borde negro, texto negro centrado
 - Hover: gris más claro {0.82}

 3. src/ui/window.lua — Ventanas System 7

 - draw(): Fondo blanco, título gris con rayas horizontales (System 7), close box cuadrado a la izquierda (estilo Mac), sombra proyectada 2px, borde negro
 - isInCloseButton(): Mover close button de derecha a izquierda (posición Mac)

 4. src/ui/taskbar.lua — Control Strip Platinum

 - draw(): Fondo gris Platinum, borde biselado (línea blanca arriba, negra debajo), texto negro, trace bar con borde inset

 5. src/systems/hex_decrypter.lua — ResEdit style

 - draw(): Texto negro sobre fondo blanco (el fondo blanco lo da la ventana), revelación gris claro → gris medio → negro sólido, barra de progreso azul con borde inset

 6. main.lua — Desktop, menú, boot screen

 - love.load(): Background gris Platinum {0.75, 0.75, 0.75}
 - MenuState:draw(): Diálogo centrado "Welcome to Sygnal OS" estilo Mac (caja blanca con doble borde, texto negro)
 - GameState:draw(): Desktop gris con patrón dither (canvas), barra de menú decorativa arriba (20px), raid como alert box Mac
 - Shop content: Colores negros sobre blanco
 - Window spawn Y ajustado para no solapar menu bar (+20px)
 - Guard en mousepressed para ignorar clicks en menu bar

 7. assets/shaders/crt.glsl — Limpiar tinte verde

 - Scanlines: intensidad 0.04 → 0.015
 - Vignette: poder 0.25 → 0.3 (más suave)
 - Flicker: uniforme en RGB (gris, no verde)
 - Eliminar pixel.g += 0.01

 Orden de Implementación

 1. theme.lua (nuevo) — base para todo lo demás
 2. button.lua — componente más pequeño
 3. window.lua — cambio visual principal
 4. taskbar.lua — barra inferior
 5. crt.glsl — shader
 6. hex_decrypter.lua — gameplay visual
 7. main.lua — desktop, menú, shop, raid, posiciones

 Verificación

 - love . sin errores
 - Boot screen: caja blanca centrada con "Welcome to Sygnal OS"
 - Desktop: gris Platinum con barra de menú arriba y control strip abajo
 - Ventanas: título gris con rayas, fondo blanco, close box a la izquierda
 - Hex decrypter: texto negro sobre blanco, barra de progreso azul
 - Botones: 3D biselados grises
 - Sin tinte verde en shader
 - Juego completamente funcional (leads, extract, shop, trace, raid)
                                                                                                                                                                                                           "✳ Game Aesthetics and" 11:06 06-feb.-26w