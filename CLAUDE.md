# CLAUDE.md — Our Journey

App Flutter **offline-first**: álbum de relación / scrapbook para parejas en Bolivia.
Las parejas completan experiencias curadas por departamento y las documentan con
fotos, notas, fecha y corazones (1–5).

## Metodología: Spec Driven Development

El orden es **Requirements → Design → Tasks → Implementación**, y NO se escribe
código de implementación hasta que la fase previa está aprobada. Ver `docs/`:

- `docs/00-context.md` — visión y reglas del proyecto.
- `docs/01-decisions.md` — decisiones de producto (requirements-lite).
- `docs/02-design.md` — diseño técnico (modelo de datos, arquitectura). **Aprobado.**
- `docs/03-tasks.md` — desglose de tareas por fases. **Aprobado.** Marca el avance aquí.

## Estado actual

**Implementación en curso. Fases 0–1 ✅ completas. Siguiente: Fase 2 (modelos del catálogo).**
Consulta siempre los checkboxes de `docs/03-tasks.md` y la bitácora del `README.md`
para el estado más reciente.

## Stack y decisiones clave

- Flutter · Dart · **`hive_ce`** (no el `hive` clásico) · Riverpod · GoRouter.
- Arquitectura **feature-first**, preparada para Firebase a futuro.
- **Dos mundos de datos**: catálogo curado inmutable en `assets/catalog/catalog.json`
  (solo lectura) ↔ progreso del usuario mutable en **Hive**. Se unen por `experienceId`.
- Fotos: se guardan en `{appDocs}/photos/{experienceId}/...`; en Hive solo el
  **nombre de archivo**, nunca la ruta absoluta (la ruta cambia en iOS entre arranques).
- Rating = **corazones 1–5**. Varias fotos por experiencia. El usuario solo completa
  experiencias curadas (no crea propias en el MVP).

## Convenciones de trabajo

- Idioma de conversación con el usuario: **español**.
- Un commit por fase; mantener la bitácora del `README.md` y los checkboxes de
  `docs/03-tasks.md` actualizados.
- Repo remoto: `origin` → https://github.com/Nobody2077/Album-for-Parejas-app-
- El `gh` CLI NO está instalado; usar `git` directo para push.
- La carpeta del proyecto necesitó permisos de escritura (ACL) para el usuario; ya resuelto.
