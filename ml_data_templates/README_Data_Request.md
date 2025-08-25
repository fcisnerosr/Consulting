
# Data Request — Paquete mínimo de datos (Tickets y Finanzas)

**Propósito.** Acordar y entregar los **datasets mínimos** para selección de modelo, línea base y pilotos.

## 1) Entregables de datos (mínimo viable)
**Operación (Tickets)**
- `tickets.*` — eventos de tickets (histórico 6–12m)
- `users.*` — catálogo de agentes/equipos
- `satisfaction.*` — encuestas CSAT/NPS (si existe)
- `taxonomy.*` — catálogos de categorías/prioridades (opcional)

**Finanzas**
- `facturas.*` (AR) — facturas emitidas
- `cobros.*` (AR) — pagos recibidos por factura
- `pagos.*` (AP) — pagos a proveedores
- `proveedores.*` (AP) — catálogo de proveedores
- `bancos.*` — extractos bancarios
- `polizas.*` — pólizas contables (GL)
- `cat_cuentas.*` — catálogo de cuentas

> Formatos sugeridos: **CSV** o **Parquet**. Codificación **UTF-8**. Fechas en **ISO 8601**.

## 2) Esquemas mínimos (campos obligatorios)
Ver `data_dictionary.csv` para definiciones, tipos y ejemplos.

## 3) Definiciones operativas (para KPIs)
- **TTR (tickets)** = `resolved_at - created_at` (horas). *No usar `closed_at` para predicción.*
- **FCR** = resuelto sin escalamiento ni recontacto en 72h (ajustable).
- **SLA** = % dentro de la 1ª respuesta y resolución por prioridad/canal.
- **Lead time AR** = `payment_date - issue_date`; **Lead time AP** = `paid_date - request_date`.
- **DSO/DPO** = días promedio de cobro/pago.

## 4) Reglas anti-leakage (críticas)
- No incluir variables conocidas **solo después** del evento objetivo (p. ej., `resolved_at` para predecir FCR).
- Entrenar/validar con **cortes temporales**: *time-based split*.
- Congelar catálogos (category/priority) por período de entrenamiento.

## 5) Calidad y privacidad
- Unicidad por IDs (`ticket_id`, `invoice_id`, etc.).
- Sin duplicados. Campos obligatorios completos. Fechas válidas.
- **PII**: no enviar emails/teléfonos. Pseudonimizar `customer_id`/`vendor_id`.
- Entrega por canal seguro; registrar autorización de uso.

## 6) Línea base y ventanas
- Tickets: histórico **≥ 6–12 meses**.
- Finanzas: histórico **≥ 12–24 meses**.

## 7) Estructura sugerida del repo
```
data/
  raw/                 # archivos originales (solo lectura)
  interim/             # limpiezas parciales
  processed/           # datasets listos para modelar
docs/
  data_request/        # este README y dicionarios
models/
  baselines/           # notebooks/experimentos base
```

## 8) Checklist (copiar/pegar en la junta)
- [ ] Exportar archivos listados (histórico + muestra)
- [ ] Entregar `data_dictionary.csv`
- [ ] Confirmar definiciones TTR/FCR/SLA/Lead time/DSO/DPO
- [ ] Dueños de datos y frecuencia de actualización
- [ ] Autorización de privacidad/PII y canal de transferencia

---

**Contacto:** [Dueño de datos Tickets] / [Dueño de datos Finanzas] / [Seguridad/TI]
