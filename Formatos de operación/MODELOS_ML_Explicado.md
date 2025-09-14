# Modelos de ML propuestos y datos mínimos — versión “sin jerga” con comentarios

> En cada línea donde aparezca una sigla, agrego un **comentario** `<!-- ... -->` explicando el término.

## 1) ¿Se resolverá en el primer contacto? (Clasificador de FCR)
- **Target:** `FCR` ∈ {0,1} <!-- FCR: First Contact Resolution = Resolución al primer contacto (Sí/No) -->
- **Datos mínimos de entrada:** canal, prioridad, categoría/subcategoría, fecha/hora de creación, equipo, agente asignado, etiquetas, carga inicial del equipo (**backlog_at_creation**) <!-- backlog_at_creation: cantidad de tickets abiertos en el equipo cuando nace el ticket -->
- **Texto (opcional):** asunto y descripción convertidos con **TF-IDF** <!-- TF-IDF: técnica simple para representar texto en números; destaca palabras características y reduce peso de palabras muy comunes -->
- **Validación:** **time-based split** (entrenar con pasado, probar con semanas recientes) <!-- time-based split: corte temporal; simula uso real evitando mezclar futuro en entrenamiento -->
- **Métrica:** **F1** y **AUC** <!-- F1: balance entre precisión y recall; AUC: capacidad de ordenar positivos sobre negativos (0.5=azar, 1.0=perfecto) -->

## 2) ¿Riesgo de romper el SLA de resolución? (Clasificación) <!-- SLA: Service Level Agreement = compromiso de tiempos de respuesta/resolución -->
- **Target:** `breach_resolution_sla` ∈ {0,1} <!-- SLA: Service Level Agreement = compromiso de tiempos de respuesta/resolución -->
- **Datos de entrada:** prioridad, categoría, canal, fecha/hora de creación, equipo, carga de trabajo (**workload**) <!-- workload: tickets en curso por equipo/agente -->
- **Modelo recomendado:** **GBM** (p. ej., **LightGBM** / **XGBoost**) <!-- GBM: Gradient Boosting Machines (árboles potentes); LightGBM/XGBoost: implementaciones rápidas/efectivas -->
- **Validación:** por **tiempo** + **calibración** de probabilidades <!-- calibración: ajustar probabilidades para que “70%” signifique ~70 de cada 100 en la realidad -->
- **Métricas:** **AUC** y **Brier score** <!-- Brier score: error cuadrático medio de probabilidades; más bajo es mejor -->

## 3) ¿Cuántas horas tomará resolver? (Regresión de TTR)
- **Target:** `TTR_horas = resolved_at - created_at` <!-- TTR: Time To Resolution = Tiempo hasta la resolución (en horas) -->
- **Datos de entrada:** iguales al modelo 2; texto opcional con **TF-IDF** <!-- TF-IDF: representación numérica del texto para usarlo como variable -->
- **Alternativa:** **Survival analysis** si hay tickets aún abiertos (censura) <!-- Survival analysis: modela tiempo hasta evento aunque no todos hayan ocurrido -->
- **Métricas:** **MAE**, **P50/P90 error** <!-- MAE: error absoluto medio (en horas); P50/P90: error mediano y error en casos difíciles (percentil 90) -->

## 4) ¿Cuántos tickets llegarán? (Pronóstico de volumen)
- **Target:** `tickets_count_d` por día y categoría <!-- Conteo diario de tickets; útil para staffing y planeación -->
- **Datos de entrada:** series de 12–24 meses; variables externas opcionales (calendario, campañas) <!-- Series largas ayudan a capturar estacionalidad/tendencias -->
- **Modelos:** **SARIMAX** / **Prophet** → **GBM** / **Transformer** si hace falta <!-- SARIMAX: ARIMA con estacionalidad y variables exógenas; Prophet: librería de Facebook para series; Transformer: arquitectura de deep learning para secuencias -->
- **Métricas:** **MAPE** / **MASE** <!-- MAPE: error porcentual medio absoluto; MASE: error escalado para comparar contra un pronóstico ingenuo -->

## 5) ¿A qué equipo/categoría lo mandamos? (Auto-enrutamiento por texto)
- **Target:** `group` o `category` (multiclase) <!-- Multiclase: varias categorías posibles -->
- **Datos de entrada:** asunto y descripción (texto) <!-- Texto crudo a procesar -->
- **Modelos:** **TF-IDF** + **Linear SVM** / **LR** → **BERT** / **embeddings** si hay volumen <!-- SVM: Support Vector Machine; LR: Logistic Regression; BERT: modelo avanzado de lenguaje; embeddings: vectores que capturan significado del texto -->
- **Métrica:** **Macro-F1** <!-- Macro-F1: promedio de F1 por clase, cada clase pesa igual (útil si hay clases minoritarias) -->

## 6) ¿Hay movimientos financieros extraños? (Anomalías en conciliaciones)
- **Target:** puntaje de rareza (sin etiquetas) o `is_fraud` si existe <!-- Unsupervised: sin etiqueta; detecta outliers -->
- **Datos de entrada:** bancos, pólizas, pagos, cobros (campos de fecha, referencia, descripción, monto) <!-- Integra fuentes financieras para ver inconsistencias -->
- **Modelos:** **Isolation Forest** / **One-Class SVM** / **Autoencoder** <!-- Isolation Forest/One-Class SVM: detectores de anomalías; Autoencoder: red neuronal que aprende “lo normal” -->
- **Métrica:** **precision@k** con revisión humana <!-- precision@k: de las k alertas principales, qué proporción es realmente anómala -->

## 7) ¿Cuándo cobramos esta factura? (Demora de cobro AR)
- **Target:** `days_to_collect` o `late>30d` <!-- AR: Accounts Receivable = Cuentas por cobrar; late>30d: cobro tardío respecto al umbral -->
- **Datos:** issue_date, due_date, terms, total, currency, segmento de cliente, historial de pagos <!-- Variables que explican el comportamiento de cobro -->
- **Modelo:** **LightGBM** (tabular) <!-- LightGBM: implementación GBM eficiente para datos tabulares -->
- **Validación:** **time split** por mes de emisión <!-- time split: separar por mes para simular futuro -->
- **Métrica:** **MAE** o **AUC/PR** <!-- PR: Precision-Recall; útil cuando la clase “tarde” es minoritaria -->

## 8) ¿Cómo evolucionará el DSO / cash-in? (Pronóstico financiero)
- **Target:** `DSO_mensual`, `cash_in` <!-- DSO: Days Sales Outstanding = Días promedio de cobro; cash-in: entradas de efectivo -->
- **Datos:** series **mensuales** ≥ 24 meses <!-- Periodicidad mensual para estabilidad -->
- **Modelos:** **SARIMAX** / **Prophet** <!-- Modelos clásicos de series de tiempo con estacionalidad -->
- **Métricas:** **RMSE** / **MAE** <!-- RMSE: raíz del error cuadrático medio (penaliza más grandes); MAE: error absoluto medio -->

## 9) ¿Qué pago corresponde a qué factura? (Vinculación de registros)
- **Target:** `match/no-match` para el par (`invoice_id`, `payment_id`) <!-- Entity Resolution: decidir si dos registros se refieren a la misma entidad -->
- **Datos:** diferencias de monto/fecha, similitud de referencias/UUID, moneda, cliente <!-- UUID: identificador único universal; similitud: comparación flexible de cadenas -->
- **Modelo:** **reglas +** modelo simple (**LogReg**/**GBM**) sobre características del par <!-- LogReg: Regresión Logística; GBM: árboles potenciados -->
- **Métricas:** **precision@k** y **recall** <!-- recall: de todos los matches reales, qué porcentaje encuentro -->

## 10) ¿Riesgo de pagar tarde al proveedor? (AP)
- **Target:** `late_payment>threshold` (Sí/No) <!-- AP: Accounts Payable = Cuentas por pagar; threshold: umbral de atraso -->
- **Datos:** request_date, approval_date, paid_date, amount, vendor_id (histórico), categoría de gasto, calendario de cierre <!-- Variables operativas y de calendario -->
- **Modelo:** **GBM** (árboles potenciados) <!-- GBM: potente para relaciones no lineales y variables mixtas -->
- **Métrica:** **AUC/PR** <!-- AUC: ranking global; PR: precisión/recobrado útil si pocos atrasos -->

---

### Reglas anti-fuga de información (imprescindibles)
- No usar campos **posteriores** al evento objetivo (p. ej., `resolved_at` para predecir FCR/SLA; `payment_date` para demora de cobro) <!-- Leakage: usar información del futuro produce métricas irreales -->
- Siempre validar con **cortes temporales** consistentes <!-- Evita aprender tendencias del futuro -->
- Congelar catálogos (prioridades/categorías) según el período de entrenamiento <!-- Asegura consistencia en definiciones -->

