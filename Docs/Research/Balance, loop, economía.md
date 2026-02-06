# Análisis de Balance, Loop y Economía

Este documento define las curvas de dificultad, el sistema de recompensas aleatorias y cómo mantener la tensión constante.

## 1. El Loop de Juego (Gameplay Loop)

1. **Fase de Adquisición:** El jugador recibe notificaciones de "Leads". El Storage limita cuántos puede retener.
    
2. **Fase de Triaje (Olfato):** El jugador abre el Hex-Decrypter. Observa el "Snapshot" (80% de fidelidad).
    
3. **Fase de Procesamiento:** Asigna recursos. Aquí el tiempo se convierte en un riesgo (Trace Level).
    
4. **Fase de Decisión (40%):** La revelación parcial obliga a decidir: "¿Vale la pena este Lead?".
    
5. **Fase de Resolución:** Extracción exitosa o Aborto.
    
6. **Fase de Reinversión:** Compra de hardware para acelerar el ciclo.
    

## 2. Economía: Recompensas y Probabilidades

El sistema de pagos "De algo a mucho" se basa en una distribución de probabilidad de **larga cola** (Long Tail).

|   |   |   |   |
|---|---|---|---|
|**Rareza del Lead**|**Probabilidad**|**Rango de Créditos**|**Señal Hexadecimal**|
|**Basura (Junkyard)**|60%|1 - 50|Muchos ceros (`00`), caracteres repetidos sin sentido.|
|**Común (Standard)**|30%|100 - 500|Mezcla de texto ASCII legible y basura.|
|**Raro (High Value)**|8%|1,000 - 3,000|Bloques densos de datos, pocos huecos.|
|**Jackpot (Legendary)**|2%|5,000 - 15,000|Estructuras de datos muy complejas y densas.|

## 3. Balance de Hardware (Costos y Beneficios)

El balance debe evitar que el jugador se vuelva "invencible" demasiado pronto.

### Escalamiento de RAM

- **Coste:** Exponencial ($C = Base \times 2^n$).
    
- **Riesgo:** Tener 4 ventanas abiertas no solo consume RAM, sino que multiplica el **Trace Level** por 4. Esto crea una gestión de riesgo/recompensa: ganar más rápido vs. ser detectado más rápido.
    

### El Factor de Aborto

Para que el "Olfato" sea vital, la penalización por abortar debe doler pero ser preferible a perder el tiempo:

- **Recuperación Base:** 60%.
    
- **Mejora de Almacenamiento:** No afecta a la recuperación, pero permite "aparcar" leads sospechosos para analizarlos después.
    

## 4. Sistema de Riesgo: Trace Level (Detección)

El Trace Level es el "reloj" del juego.

- **Incremento Pasivo:** Sube un `0.1%` por segundo por cada ventana activa.
    
- **Incremento Activo:** Los Leads de tipo "Jackpot" tienen una seguridad que aumenta el Trace un `0.5%` por segundo.
    
- **Consecuencias:**
    
    - **70% Trace:** Distorsión visual en el monitor (flicker).
        
    - **90% Trace:** Las ventanas se cierran aleatoriamente.
        
    - **100% Trace:** Raid de la policía. Pérdida de hardware (reset de una pieza aleatoria a nivel 0) y multa de créditos.
        

## 5. Configuración del "Olfato" (80/20)

Para programar el 80% de certeza:

1. El sistema decide el valor real al generar el Lead.
    
2. Si el valor es **Alto**, hay un 80% de probabilidad de mostrar una señal hexadecimal "Limpia" y un 20% de mostrar una "Sucia".
    
3. Esto garantiza que el jugador confíe en su instinto, pero siempre mantenga una duda razonable que genera la adicción al riesgo.