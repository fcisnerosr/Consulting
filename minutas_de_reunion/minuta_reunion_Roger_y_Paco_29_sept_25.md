# Plan de acción — Niveles/Jerarquías del chatbot (Toastmasters)

## 1) Quién hizo qué (pasado)
- **Francisco**
  - Definió el concepto de **“niveles”** y acordó renombrarlo como **“jerarquías”** para restringir/permitir roles según progresión.
  - Mostró el Excel y explicó el **orden de dificultad de roles (1→6)**.
  - Propuso **pruebas end-to-end** (levantar dos servidores) y **envío de mensajes** a varios miembros.
  - Mantiene la **asignación manual** mientras madura el bot.
- **Roger**
  - Creó una **rama de pruebas** (“pruebas por Roger”) con **validación** para evitar que una persona sea propuesta para **dos roles en la misma ronda**.
  - Probó la rama localmente (funcionó) y **aún no abrió PR**.
  - Analizó **costos** de WhatsApp Business/Gupshup y sugirió **evitar encuestas masivas** por plantillas.

---

## 2) Qué va a hacer cada quien (próximos pasos)

### Francisco — acciones
- [ ] **Ejecutar pruebas**: levantar los dos servidores y correr el flujo end-to-end.
- [ ] **Configurar jerarquías** para el set de prueba (p. ej., Francisco=6, Roger=1, Sheila=1, etc.) y verificar que el bot respete las restricciones.
- [ ] **Contactar participantes** (Sheila, Marcos, Daniel, y/o su esposa para acelerar) y **enviar plantillas** con **ventana de respuesta corta** (≈1 h).
- [ ] **Integrar cambios de Roger**: hacer **merge** si está estable o **solicitar PR** y revisarlo.
- [ ] **Limitar roles en pruebas iniciales** (2–3) para validar lógica con pocos miembros.

### Roger — acciones
- [ ] **Abrir Pull Request** de su rama de pruebas con la validación **anti-duplicados por ronda**.
- [ ] **Responder con rapidez** durante la ventana de pruebas (no bloquear el flujo).
- [ ] **Explorar luego** “agregar usuario vía chatbot” (etapa posterior a las pruebas).
- [ ] **Optimizar estrategia de plantillas** para reducir costos (mensaje inicial + ventana <24 h).

---

## 3) Acuerdos y criterios operativos
- **“Niveles” ⇒ “Jerarquías”**: progresión de **qué roles** puede tomar un miembro; novatos empiezan con roles simples (p. ej., **control de tiempo**) y **ascienden** tras aceptar/desempeñar.
- **Miembros experimentados**: pueden ser seleccionados para **cualquier rol**.
- **Encuesta de asistencia**: **diferida** por costo de plantillas; se prioriza **invitación dirigida** con **tiempo de respuesta corto**.
- **Costos WhatsApp**: se paga la **plantilla inicial**; mensajes dentro de **24 h** posteriores **no se cobran**.
- **Validación activa (Roger)**: **no** proponer a la misma persona para **dos roles** en la **misma ronda**.
- **Pruebas**: iniciar con **pocos roles**; en operación real un club debe tener **≥ 10 miembros**.

---

## 4) Pendientes / decisiones abiertas
- [ ] **Mapa jerarquía → roles permitidos** (tabla de referencia).
- [ ] **Lista inicial de jerarquía** por miembro para el piloto.
- [ ] **PR de Roger** y **revisión/merge**.
- [ ] Decidir si habrá **edición manual de jerarquía** por administrador (por ahora **no necesaria**).
- [ ] Evaluar más adelante una **encuesta de disponibilidad** optimizada en costos.
