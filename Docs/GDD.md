# GDD: Arqueólogo de la Red Profunda (Shadow Salvage)

**Contexto:** Eres un operador independiente. Tu terminal no renderiza imágenes; tu mundo son los bytes. Reconstruyes fragmentos de memoria de la Internet Muerta buscando "objetos de valor" (credenciales, llaves privadas, secretos de estado).

## 1. El "Loot" (Cadenas de Datos)

El valor no está en el archivo completo, sino en las **cadenas legibles (Strings)** embebidas en el código hexadecimal.

|Tipo de Dato|Patrones a buscar (Mina de Oro)|El "Humo" (Ruido)|
|---|---|---|
|**Crypto-Leaks**|`SEED:`, `BIP39`, `WIF:`, `ETH_KEY`|`ERROR_LOG`, `NULL_PTR`, `DUMP_STACK`|
|**Bounty Dossiers**|`ID:`, `LOC:`, `NAME:`, `ALIAS:`|`CSS_CLASS`, `JS_VAR`, `MOCK_DATA`|
|**Bank Logs**|`IBAN:`, `PASS:`, `SWIFT:`, `USER:`|`COOKIES`, `SESSION_ID_EXPIRED`, `AD_BLOCKED`|

## 2. La Mecánica de "Olfato": Lectura de Hexadecimal

El jugador utiliza la ventana **"Hex-Decrypter"**. Esta ventana muestra una cuadrícula clásica de 16 columnas de bytes y una columna lateral con la interpretación ASCII.

### El Olfato Visual (Análisis Previo)

Antes de asignar recursos, el jugador ve un "Snapshot" estático:

- **80% de Certeza:** Si el bloque de bytes muestra caracteres ASCII que no son solo puntos (`.`) o basura (`!?@`), sino que hay letras mayúsculas seguidas (`USER`, `ROOT`), el olfato indica una oportunidad real.
    
- **El Ruido:** Bloques de `00` constantes o `FF` suelen indicar sectores vacíos o borrados.
    

## 3. Gameplay: Proceso de Reconstrucción Progresiva

La reconstrucción no es un simple temporizador; es una **limpieza visual**.

1. **Etapa 0-30% (Fase de Ruido):** El código hexadecimal es un caos total. Los caracteres ASCII cambian aleatoriamente.
    
2. **Etapa 40% (Revelación del Contexto):** El código se estabiliza. Empiezan a aparecer palabras clave incompletas (ej: `U _ E R :`). **Punto de Decisión:** Aquí el jugador decide si abortar o seguir.
    
3. **Etapa 60-80% (Claridad de Activo):** Los datos se vuelven legibles. El jugador puede ver el nombre del banco o el tipo de moneda.
    
4. **Etapa 100% (Extracción):** El sistema resalta el dato útil. El jugador hace clic para "cobrar".
    

## 4. Economía y Hardware: Configuración de la Estación

El jugador debe invertir sus créditos en mejorar su hardware físico para escalar sus operaciones.

### A. Memoria (RAM): Capacidad de Paralelismo

La RAM determina cuántas ventanas de descifrado pueden estar abiertas y activas simultáneamente.

- **8GB (Base):** 1 ventana activa.
    
- **16GB:** 2 ventanas en paralelo.
    
- **32GB/64GB:** 4+ ventanas. El multitasking aumenta drásticamente las ganancias, pero también el estrés y el riesgo de detección.
    

### B. GPU (Unidad de Procesamiento Gráfico): Velocidad de Estabilización

La potencia de la GPU acelera la "limpieza" del código hexadecimal.

- Una GPU potente reduce el tiempo que tarda el código en pasar de la **Fase de Ruido (0%)** a la **Claridad (80%)**.
    
- Es vital para leads de alta seguridad (Jackpots), donde el tiempo es oro antes de ser interceptado.
    

### C. Storage (Almacenamiento SSD): Capacidad de Leads

El disco determina cuántos "Leads" o Snapshots puede mantener el jugador en su bandeja de entrada antes de que expiren o se borren.

- **Almacenamiento bajo:** Los leads desaparecen rápido si no los procesas.
    
- **Almacenamiento alto:** Permite "guardar" leads que parecen prometedores para procesarlos más tarde cuando los recursos de RAM se liberen.
    

### D. CPU (Nodos de Archivo): Eficiencia Energética

La CPU controla el consumo de energía y el calor generado. Un procesador mejor permite que la GPU y la RAM trabajen al máximo sin disparar el **Trace Level** tan rápido por picos de consumo eléctrico sospechosos.

## 5. Economía: Recompensas Variables

- **Residuo (1-50 créditos):** Cuentas vacías.
    
- **Estándar (100-500 créditos):** Recompensas de nivel bajo.
    
- **Jackpot (1,000-10,000 créditos):** "Ballenas" de Bitcoin o cuentas suizas.
    

## 6. Riesgo: Intercepción de Logs (Trace)

A mayor cantidad de hardware trabajando en paralelo (muchas ventanas de RAM activas + GPU al 100%), más ruido eléctrico generas.

- El **Trace Level** sube por cada ventana activa.
    
- Extraer en paralelo es lucrativo pero extremadamente arriesgado. Si la policía te localiza, el hardware puede quedar "frito" (dañado permanentemente), obligándote a comprar piezas nuevas.