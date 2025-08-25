
# Modelos de ML propuestos y datos mínimos

## 1) Clasificador de FCR (Tickets)
- **Target**: `FCR` ∈ {0,1}
- **Inputs mínimos**: `channel, priority, category, subcategory, created_at (hora/día), team, assignee_id, tags, backlog_at_creation*`
- **Texto (opcional)**: `subject, description` (TF-IDF)
- **Validación**: *time-based split* (8–10 semanas holdout)
- **Métrica**: F1 / AUC

## 2) Riesgo de incumplir SLA (Tickets)
- **Target**: `breach_resolution_sla` ∈ {0,1}
- **Inputs**: `priority, category, channel, created_at, team, workload*`
- **Modelo**: Gradient Boosting (LightGBM/XGBoost)
- **Validación**: *time-based* + calibración
- **Métrica**: AUC / Brier

## 3) Regresión de TTR (Tickets)
- **Target**: `TTR_horas = resolved_at - created_at`
- **Inputs**: idem (2) + texto opcional
- **Alternativa**: Survival Analysis si hay censura (tickets abiertos)
- **Métricas**: MAE, P50/P90 error

## 4) Forecast de volumen de tickets (Time Series)
- **Target**: `tickets_count_d` por día y categoría
- **Inputs**: series ≥ 12–24 meses (exógenas opc.)
- **Modelos**: SARIMAX/Prophet → GBM/Transformer si madura
- **Métricas**: MAPE/MASE

## 5) Auto-enrutamiento (NLP)
- **Target**: `group` o `category`
- **Inputs**: `subject, description`
- **Modelos**: TF-IDF + Linear SVM/LR → BERT/embeddings si volumen
- **Métrica**: Macro-F1

## 6) Anomalías en conciliaciones (Finanzas)
- **Target**: score (unsupervised) o `is_fraud` si existe
- **Inputs**: `bancos, polizas, pagos, cobros`
- **Modelos**: Isolation Forest / One-Class SVM / Autoencoder
- **Métrica**: precision@k (revisión humana)

## 7) Demora de cobro (AR)
- **Target**: `days_to_collect` o `late>30d`
- **Inputs**: `issue_date, due_date, terms, total, currency, customer_segment, historial_cliente`
- **Modelo**: LightGBM (tabular)
- **Validación**: time split por mes
- **Métrica**: MAE o AUC/PR

## 8) Forecast DSO / Cash-in
- **Target**: `DSO_mensual`, `cash_in`
- **Inputs**: series mensuales ≥ 24 meses
- **Modelos**: SARIMAX/Prophet
- **Métrica**: RMSE/MAE

## 9) Matching Factura–Pago (Entity Resolution)
- **Target**: match/no-match (par `invoice_id`, `payment_id`)
- **Inputs**: diferencias de `amount/date`, similitud de referencia/UUID, moneda
- **Modelo**: reglas + LogReg/GBM sobre *pair features*
- **Métrica**: precision@k, recall

## 10) Riesgo de atraso AP
- **Target**: `late_payment>threshold`
- **Inputs**: `request_date, approval_date, paid_date, amount, vendor_id (histórico), categoría_gasto`
- **Modelo**: GBM
- **Métrica**: AUC/PR

---

### Reglas anti-leakage (resumen)
- No usar `resolved_at` para predecir FCR/SLA; no usar `payment_date` para predecir demora de cobro.
- Cortes temporales consistentes para train/validation.
- Congelar catálogos por período.
