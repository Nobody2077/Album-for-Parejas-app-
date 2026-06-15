# Our Journey ❤️

Álbum de relación y *scrapbook* digital para parejas en Bolivia. En vez de contar los
días juntos, **Our Journey** invita a coleccionar experiencias reales: las parejas
completan actividades y citas curadas por departamento, y las documentan con fotos,
notas, fecha y una valoración en corazones.

> App **offline-first** hecha en Flutter. MVP sin cuentas, sin nube, sin backend.

---

## 📍 Estado del proyecto

**Fase actual: Spec Driven Development → Tasks (propuesta, pendiente de aprobación).**

| Fase | Estado | Documento |
|------|--------|-----------|
| Contexto / Visión | ✅ Listo | [docs/00-context.md](docs/00-context.md) |
| Requirements (lite) | ✅ Listo | [docs/01-decisions.md](docs/01-decisions.md) |
| Design | ✅ Aprobado | [docs/02-design.md](docs/02-design.md) |
| Tasks | 🟡 En revisión | [docs/03-tasks.md](docs/03-tasks.md) |
| Implementación | ⬜ Pendiente | — |

---

## 🧱 Stack

Flutter · Dart · Hive (hive_ce) · Riverpod · GoRouter — arquitectura **feature-first**,
preparada para una futura integración con Firebase.

## 🎯 Alcance del MVP

Explorar departamentos → explorar experiencias → marcarlas como completadas → agregar
fotos, notas, fecha y corazones → ver el progreso. Todo **100% offline**.

## 🗂️ Decisiones clave

- Varias fotos por experiencia (galería).
- El usuario solo completa experiencias **curadas** (no crea propias en el MVP).
- Catálogo en **JSON de assets** (solo lectura); progreso del usuario en **Hive**.
- Valoración con **corazones del 1 al 5**.

## 📒 Bitácora

- **2026-06-15** — Inicializado git. Definidas decisiones de producto y documento de
  Design. Documentación del proyecto creada en `docs/`.
- **2026-06-15** — Design aprobado (Hive = `hive_ce`). Desglose de tareas creado en
  `docs/03-tasks.md`.

---

## 🚀 Cómo correr (próximamente)

Aún no hay implementación. Una vez aprobadas las tareas:

```bash
flutter pub get
flutter run
```
