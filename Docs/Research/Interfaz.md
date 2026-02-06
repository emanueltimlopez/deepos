Plan de Diseño de Interfaz: Sygnal OS (Macintosh Edition)

Este documento describe la estructura visual y funcional de la interfaz de usuario, inspirada en la estética clásica de System 7 / Platinum OS.

1. El Escritorio (The Finder)

El entorno base abandona el verde terminal por un estilo gris "Platinum" y tipografía pixelada.

Elementos Visuales:

Fondo de Pantalla: Patrón de píxeles grises (Dithered gray) o el clásico azul grisáceo #666699.

Barra de Menú Superior: Menú de "Manzana", File, Edit, Special, Help (que también abre el manual) y Reloj.

Iconos: Estilo pixel-art de 32x32.

Mail (Postbox): Bandeja de entrada.

VoidMarket (The Mall): Tienda de mejoras.

Hex-Decrypter (Bit-Salvage): Herramienta de trabajo.

Manual.txt (Pattern_DB): Base de conocimiento.

NetLedger (Banking): NUEVO. Icono de una calculadora sobre una hoja de cálculo.

TunePlayer (Music): NUEVO. Icono de una nota musical doble (corcheas) o un pequeño CD.

Trash (Papelera): Para descartar leads.

2. Aplicación: Manual.txt (Pattern_DB)

Es la base de conocimiento del juego. Una herramienta pasiva pero vital.

Interfaz:

Estilo Visual: Ventana simple de procesador de textos (tipo TeachText o SimpleText). Fondo blanco, texto negro, fuente Geneva.

Contenido:

Lista de "Known Bad Signatures" (Patrones de Basura): Ejemplos visuales de bloques hexadecimales que significan "Archivo Vacío" o "Virus".

Lista de "High Value Markers" (Marcadores de Valor): Cadenas específicas a buscar (ej: 0x4A Header).

Navegación: No tiene scroll infinito, sino botones de "Página Anterior" / "Página Siguiente" en la parte inferior.

3. Aplicación: Mail (Classic Inbox)

Inspirado en clientes como Eudora.

Snapshot Hexadecimal: Enmarcado en una caja con relieve. El jugador comparará visualmente este snapshot con la ventana abierta de Manual.txt.

4. Aplicación: VoidMarket (Boutique de Hardware)

Catálogo estilo revista de informática de 1992.

Listado de Productos: Fotos pixeladas de hardware y Actualizaciones del Manual (nuevas páginas con patrones de virus más modernos).

5. Aplicación: Hex-Decrypter (Bit-Salvage)

Ventana de gameplay principal (estilo ResEdit).

Visuales: Fondo blanco, texto monospaced en negro.

Progresión: Los caracteres se limpian. El jugador debe estar atento a si aparecen patrones listados en el manual como "Peligrosos" para abortar.

6. Aplicación: NetLedger (Banking - Read Only)

Herramienta de gestión financiera personal, estilo Quicken de los 90.

Interfaz:

Encabezado: Muestra el "Current Balance" (Saldo Actual) en fuente grande y negrita (Chicago).

Tabla de Transacciones: Una hoja de cálculo simple con columnas:

Date: Fecha ficticia del sistema.

Description: Origen (ej: "Payout: Asset #44", "Purchase: RAM 8MB").

Amount: Valor en verde (+) o rojo (-).

Status: "Cleared" o "Pending" (solo decorativo).

Funcionalidad:

Es estrictamente Read-Only. No se pueden hacer transferencias.

Sirve para que el jugador vea su historial de progreso y cuánto ha gastado en upgrades vs cuánto ha ganado en trabajos.

7. Aplicación: TunePlayer (Music)

Reproductor de medios minimalista, estilo CD Player de Windows 95 o AppleCD Audio Player.

Interfaz:

Controles: Botones con relieve 3D marcados (Play, Stop, Prev, Next). Un slider horizontal para el volumen.

Display LCD: Un pequeño recuadro negro con letras verdes (o LCD gris) que muestra:

TRACK 01: 00:45 (Tiempo transcurrido).

Title: Nombre de la pista (ej: "Silicon Dreams.mod", "Heuristic Vibe.mid").

Playlist: Una lista pequeña debajo de los controles donde se pueden seleccionar diferentes melodías en estilo 8-bit / Chiptune relajante (Lo-Fi).

Comportamiento: La música persiste aunque se cierre la ventana (la app queda corriendo en "segundo plano" o minimizada).

8. Flujo de Navegación "Classic Mac"

Notificación: Suena un "Eep!". Icono del Mail parpadea.

Referencia: El jugador abre Manual.txt y lo coloca a un lado de la pantalla.

Comparación: Abre el Mail. Compara el snapshot del lead con los ejemplos del manual.

Acción: Si coincide con un patrón bueno, arrastra al Hex-Decrypter.

Riesgo: Si el sistema está estresado (muchas ventanas), el puntero se vuelve un reloj de arena.