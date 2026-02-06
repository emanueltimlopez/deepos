Loop de Juego y Sistema de Progresión: Sygnal OS

Este documento define el ciclo principal del juego, enfocado en la eficiencia operativa, la estabilidad del hardware y el uso de documentación técnica.

1. El Inicio: Onboarding (Día 0)

Estado Inicial: Escritorio con Mail y Manual.txt.

El Primer Email:

Remitente: Admin_Sys

Asunto: Read The Manual First

Cuerpo: "Antes de tocar nada, lee el archivo Manual.txt. Contiene las firmas de datos básicos. Si procesas basura, quemarás tu CPU por nada. Memoriza los patrones."

Recompensa: 100 Créditos.

2. Mecánica del Inbox (El Cuello de Botella)

El flujo de trabajo depende de tu bandeja de entrada.

Capacidad Máxima: 10 correos no leídos.

Regla de Saturación: Si tienes 10 correos, dejan de llegar nuevos.

Acción del Jugador: Debe revisar rápido. La comparación con el Manual.txt es clave para borrar basura rápidamente sin gastar recursos en desencriptarla.

3. El Loop Principal (Core Loop)

Fase A: Recepción y Consulta (La Investigación)

Llega un email: "Asset: 0x99_dump".

El jugador abre el correo y ve el Snapshot Hexadecimal.

Mecánica de Referencia:

El jugador mantiene la ventana Manual.txt abierta en una esquina.

Busca similitudes visuales (ej: "¿Tiene muchas 'F' repetidas? El manual dice que 'FFFF' es un sector muerto").

Decisión:

Trash: Si coincide con un patrón de basura del manual.

Decrypt: Si coincide con un patrón de "Header Válido" o es desconocido (riesgo).

Fase B: Decodificación y Monitoreo

Al dar a "Decrypt", se abre Bit-Salvage.

Consumo: Ocupa RAM y CPU.

Verificación en Tiempo Real:

A medida que el código se limpia, pueden aparecer patrones que no eran visibles en el snapshot.

Ejemplo: El snapshot se veía bien, pero al 30% aparece la cadena TROJAN.V3.

El jugador debe consultar el manual rápidamente: "¿Qué hago con un troyano?". El manual dice: "ABORT IMMEDIATELY".

Acción de Abortar: Si el jugador reconoce el patrón maligno y aborta a tiempo, salva el hardware de un "System Crash" provocado por el virus.

Fase C: Resolución

Éxito: Código extraído y válido. Créditos transferidos.

Fracaso (Basura): Archivo vacío. Pérdida de tiempo.

Fracaso (Virus): Si no abortó a tiempo, el sistema se reinicia (Crash) y pierde leads del inbox.

4. La Dificultad: Estabilidad y Conocimiento

La dificultad escala en dos ejes: Hardware y Conocimiento.

Estabilidad del Sistema (System Stress)

Cada ventana activa añade carga.

Castigo: "System Freeze" o Bomba si superas la capacidad de CPU.

Complejidad de Patrones (Knowledge Gap)

A medida que avanzas, los archivos basura se vuelven más difíciles de distinguir de los buenos.

Early Game: Patrones obvios (todo ceros o todo Fs).

Mid Game: Los archivos basura imitan cabeceras válidas. El jugador necesita comprar "Páginas Avanzadas del Manual" en el VoidMarket para aprender las diferencias sutiles (ej: "El byte 0x4 debe ser 'A', no 'B'").

5. Progresión y Upgrades (VoidMarket)

A. Hardware (Fuerza Bruta)

RAM: Más ventanas paralelas.

CPU: Mayor estabilidad y velocidad.

Storage: Buffer de Inbox más grande.

B. Información (Knowledge Base)

Manual Pages (v2.0, v3.0): Actualiza el Manual.txt con nuevos patrones de virus y criptomonedas modernas. Es esencial para no ser engañado por los leads avanzados.

OCR Scanner: Software que resalta automáticamente en amarillo los patrones coincidentes con el manual (automatiza la fase de consulta).

6. Resumen del Balance

Early Game: El jugador mira constantemente el manual. Es lento y metódico. Aprende a identificar "Basura".

Mid Game: El jugador ha memorizado los patrones básicos y opera rápido. Compra la actualización del manual porque empiezan a aparecer "Falsos Positivos" que le hacen perder dinero.

Late Game: El jugador gestiona 5 ventanas y usa el "OCR Scanner" para filtrar. El reto es la velocidad de decisión antes de que el sistema colapse por estrés térmico.