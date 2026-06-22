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
| Tasks | ✅ Aprobado | [docs/03-tasks.md](docs/03-tasks.md) |
| Implementación | 🟡 Fases 0–7 ✅ · Fase 8 (pulido) en curso (8.1–8.4 ✅) | [docs/03-tasks.md](docs/03-tasks.md) |

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
- **2026-06-15** — Tasks aprobadas. **Fase 0 (setup) completa**: dependencias agregadas,
  assets y permisos configurados, `flutter analyze` sin issues.
- **2026-06-15** — **Fase 1 (tema y arranque) completa**: paleta cálida, tipografías
  (Playfair Display + Nunito Sans), `ThemeData` M3, `MaterialApp.router` con pantalla
  de bienvenida. `flutter analyze` sin issues y smoke test del arranque en verde.
- **2026-06-15** — **Fase 2 (modelos del catálogo) completa**: `Department`, `Experience`
  y `Catalog` inmutables con `fromJson` estricto, igualdad por `id` y helpers. 11 tests
  unitarios en verde.
- **2026-06-15** — **Fase 3 (catálogo curado) completa**: `catalog.json` con 9
  departamentos y 38 experiencias, `CatalogLoader` y providers de Riverpod
  (`catalogProvider`, `departmentsProvider`, `experiencesByDeptProvider`). 19 tests en verde.
- **2026-06-15** — **Fase 4 (persistencia Hive) completa**: modelo `ExperienceProgress`
  (`@HiveType`), adapter generado, `initHive()`, `ProgressRepository` y providers
  reactivos (`progressControllerProvider`, `overallProgressProvider`, etc.). El progreso
  persiste tras reiniciar. 25 tests en verde.
- **2026-06-15** — **Fase 5 (almacenamiento de fotos) completa**: `ImageStorageService`
  (copiar/resolver/borrar, solo nombres de archivo) e `ImagePickerService` (cámara/galería).
  30 tests en verde.
- **2026-06-15** — **Fase 6 (navegación) completa**: `GoRouter` (`appRouter`) con las
  4 rutas y placeholders navegables; reemplaza al router placeholder de la Fase 1.
  Test de navegación de punta a punta. 30 tests en verde.
- **2026-06-15** — **Fase 7 (1/4)**: widgets compartidos base (`HeartRating`,
  `PolaroidPhoto`, `ProgressRing`).
- **2026-06-15** — **Fase 7 (2/4)**: `HomeScreen` (dashboard con progreso global y
  últimos recuerdos) e interfaz del repositorio de progreso.
- **2026-06-17** — **Fase 7 (3/4)**: pantallas de departamentos (`DepartmentsScreen`
  grid con progreso X/Y y `DepartmentDetailScreen` lista de experiencias) + widgets
  `DepartmentCard` y `ExperienceRow`. Router enlaza ambas rutas reales. 43 tests en verde.
- **2026-06-17** — **Fase 7 (4/4) completa**: `ExperienceDetailScreen` (detalle con
  fecha, corazones, nota y galería) y `EditMemorySheet` (completar/editar: fecha,
  corazones, nota y fotos, difiriendo la copia a disco hasta guardar). Router con sus
  4 pantallas reales. Helper `formatMemoryDate`. **Fase 7 (pantallas) completa**.
  48 tests en verde.
- **2026-06-22** — **Fase 8 (8.1–8.3)**: pulido — estados vacíos/carga en todas las
  pantallas (incl. departamento sin experiencias); confirmaciones al borrar
  (diálogo `confirmDestructive`, "Borrar recuerdo" y quitar foto); fechas con `intl`
  (`DateFormat` es). 49 tests en verde. Pendiente: 8.4 (íconos/splash), 8.5 (revisión
  visual) y 8.6 (pruebas en dispositivo).
- **2026-06-22** — **Fase 8 (8.4)**: identidad visual — ícono propio (corazón terracota
  + camino punteado dorado, generado por `tool/generate_icon.py`) aplicado a Android
  (adaptive), iOS y web vía `flutter_launcher_icons`; splash de arranque con
  `flutter_native_splash` (fondo crema + corazón); nombre **"Our Journey"** en las tres
  plataformas. Pendiente: 8.5 (revisión visual) y 8.6 (pruebas en dispositivo).
- **2026-06-22** — **Fase 8 (8.5, en curso)**: arreglo de navegación — la Home abría
  Departamentos con `context.go` (reemplaza el stack), dejando esa pantalla sin flecha
  de "atrás". Cambiado a `context.push` para que el flujo Home → Departamentos →
  Detalle → Experiencia quede apilado y cada pantalla tenga su botón de regreso.

---

## 🚀 Cómo correr (próximamente)

Aún no hay implementación. Una vez aprobadas las tareas:

```bash
flutter pub get
flutter run
```
