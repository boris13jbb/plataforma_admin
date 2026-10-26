# Checklist de revisión previa a publicación — Privacidad

**Política lista para publicar:** **NO**  
**Última actualización:** 2026-10-25 (respuestas parciales del propietario incorporadas).  
**Auditoría técnica:** `PRIVACY_TECHNICAL_AUDIT.md`

> Tener un documento rellenado **no** implica que la tarea esté completada ni aprobada.

---

## Bloqueos / pendientes (mínimo obligatorio)

| # | Pendiente | Estado actual | Criterio de OK |
|---|-----------|---------------|----------------|
| 1 | Confirmar identidad legal y datos de contacto a **publicar** | Nombre y correo aportados; pendiente revisión final | Propietario confirma texto exacto publicable |
| 2 | Decidir dirección de contacto apropiada y publicable | Solo país (Ecuador); domicilio **incompleto** | Dirección formal definida o decisión explícita de no publicarla (con criterio legal) |
| 3 | Definir plazos de conservación por categoría | Pendiente de determinar | Tabla de plazos aprobada |
| 4 | Documentar procedimiento real de eliminación (cuentas/datos) | “Manual” declarado; detalle **no** documentado ni verificado | SOP escrito: pasos, roles, ID check, sistemas, limitaciones |
| 5 | Determinar bases jurídicas aplicables | Pendientes de análisis | Confirmación jurídica del propietario/asesor |
| 6 | Confirmar servicios y proyectos externos | Propietario: “Firebase”; contraste con inventario **abierto** | Lista cerrada Auth/Functions/Firestore/productos + otros |
| 7 | Revisar alcance del perfil completo en lookup | Propietario mantiene alcance; revisión de necesidad **abierta** | Decisión de minimizar o justificar |
| 8 | URL HTTPS de la política | Pendiente | URL viva sin login |
| 9 | Revisión y aprobación del propietario | Designado como aprobador; **aún no aprobado** | Constancia de aprobación del borrador final |
| 10 | Preparar Google Play Data safety según flujos reales | No enviado | Borrador de casillas alineado a inventario |
| 11 | Evaluar requisitos de eliminación de cuentas en Google Play | Sin delete in-app; manual pendiente | Criterio Play + procedimiento |
| 12 | Verificar coherencia política publicada ↔ Data safety ↔ app distribuida | No aplicable hasta publicar | Checklist de consistencia firmado |

---

## Respuestas ya registradas (no = completado)

- Persona natural: Juan Gabriel Burbano Bonifaz  
- País: Ecuador  
- Correo: boris13jb@gmail.com  
- Alcance: operadores + usuarios de productos  
- Lookup perfil completo: se mantiene por ahora  
- Eliminación: manual (detalle pendiente)  
- Aprobación final: propietario  

---

## Riesgos operativos que requieren decisión

| ID | Riesgo / decisión |
|----|-------------------|
| P-01 | Minimizar o justificar lookup de perfil completo |
| P-03 | Bootstrap callable aún activa en backend |
| P-04 / R2 | Procedimiento de borrado manual verificable + Play |
| P-05 | `allowBackup` Android |
| Drift | Rules Firestore remotas vs locales |

---

## Verificaciones de configuración

- [ ] Rules Console = `firestore.rules`  
- [ ] Lista de proyectos Firebase / secrets (sin exponer valores)  
- [ ] Contratos/términos Google  
- [ ] Hosting de la política  
- [ ] Data safety + account deletion en Play  

---

## Prohibiciones vigentes

- No publicar ni alojar la política  
- No inventar URL  
- No enviar Data safety  
- No deploy Firebase/Functions/Hosting  
- No marcar política como aprobada  

---

## Referencias cruzadas

- Respuestas: `PRIVACY_OWNER_ANSWERS.md`  
- Borrador: `PRIVACY_POLICY_DRAFT.md` (**BORRADOR NO APROBADO — NO PUBLICAR**)  
- Inventario: `PRIVACY_DATA_INVENTORY.md`  
- Remediación: `PRIVACY_REMEDIATION_PLAN.md`  
