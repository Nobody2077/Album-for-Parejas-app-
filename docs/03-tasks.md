# Tasks - Our Journey (MVP)

> Desglose de implementación basado en [02-design.md](02-design.md).
> Orden pensado para que cada bloque deje algo verificable. Fecha: 2026-06-15.
>
> **Estado: PROPUESTA — pendiente de aprobación.** No se escribe código de
> implementación hasta aprobar estas tareas (regla de Spec Driven Development).
>
> Hive: se usa **`hive_ce`** (confirmado).

---

## Fase 0 — Setup del proyecto ✅

- [x] **0.1** Agregar dependencias al `pubspec.yaml`:
  `flutter_riverpod`, `go_router`, `hive_ce`, `hive_ce_flutter`, `path_provider`,
  `image_picker`, `uuid`, `intl`, `google_fonts`.
- [x] **0.2** Agregar dev-dependencies: `hive_ce_generator`, `build_runner`.
- [x] **0.3** Declarar `assets/catalog/` en la sección `flutter:` del `pubspec.yaml`
  (con `catalog.json` placeholder hasta la Fase 3).
- [x] **0.4** Permisos de plataforma para `image_picker`: descripciones de cámara y
  galería en `Info.plist` de iOS. Android moderno usa el *photo picker* y no
  requiere permisos en el manifest.
- [x] **0.5** `flutter pub get` y `flutter analyze` → *No issues found!*

**Verificable:** ✅ el proyecto compila con las nuevas dependencias.

---

## Fase 1 — Tema y arranque ✅

- [x] **1.1** `app/theme/app_colors.dart` — paleta (crema, terracota, rosa polvo, dorado).
- [x] **1.2** `app/theme/app_typography.dart` — tipografías con `google_fonts`
  (serif para títulos, sans para cuerpo).
- [x] **1.3** `app/theme/app_theme.dart` — `ThemeData` warm/elegant.
- [x] **1.4** `app/app.dart` — `MaterialApp.router` aplicando el tema
  (con router placeholder de una ruta `/`; el router real llega en Fase 6).
- [x] **1.5** `main.dart` — bootstrap mínimo con `ProviderScope` (Hive se conecta en Fase 4).

**Verificable:** ✅ la app arranca mostrando una pantalla de bienvenida con el tema
aplicado. `flutter analyze` sin issues y smoke test del arranque pasa.

---

## Fase 2 — Modelos del catálogo ✅

- [x] **2.1** `catalog/models/department.dart` — modelo inmutable + `fromJson`
  (igualdad por `id`, parseo estricto).
- [x] **2.2** `catalog/models/experience.dart` — modelo inmutable + `fromJson`
  (igualdad por `id`, parseo estricto).
- [x] **2.3** Modelo contenedor `Catalog` (listas + helpers `experiencesFor(deptId)`
  y `departmentById(id)`). Helper de parseo en `catalog/models/json_utils.dart`.

**Verificable:** ✅ 11 tests de parseo `fromJson`, igualdad y helpers pasan
(`test/catalog/catalog_models_test.dart`).

---

## Fase 3 — Catálogo curado (datos + carga) ✅

- [x] **3.1** `assets/catalog/catalog.json` con los 9 departamentos y 38 experiencias
  iniciales (contenido de producto, editable). Cada experiencia tiene `category`.
- [x] **3.2** `catalog/catalog_loader.dart` — lee y parsea el JSON desde assets.
- [x] **3.3** `catalog/catalog_providers.dart` — `catalogLoaderProvider`,
  `catalogProvider`, `departmentsProvider`, `experiencesByDeptProvider(id)`.

**Verificable:** ✅ `departmentsProvider` expone los departamentos del JSON;
tests de integridad del catálogo real + wiring de providers en verde.

---

## Fase 4 — Persistencia (Hive) ✅

- [x] **4.1** `experience/models/experience_progress.dart` — modelo Hive
  (`@HiveType(typeId: 0)`) con los campos del Design + `copyWith` y factory `create`.
- [x] **4.2** Adapter generado con `build_runner` (`experience_progress.g.dart`
  + `hive_registrar.g.dart`).
- [x] **4.3** `core/storage/hive_init.dart` — `initHive()` (init + registrar + abrir box).
- [x] **4.4** `main.dart` llama `initHive()` antes de `runApp`.
- [x] **4.5** `experience/data/progress_repository.dart` — CRUD (upsert con timestamps
  automáticos, delete del registro completo).
- [x] **4.6** `experience/experience_providers.dart` — `progressRepositoryProvider`,
  `progressControllerProvider` (Notifier reactivo), `progressProvider(expId)`,
  `overallProgressProvider`, `departmentProgressProvider(id)` + `ProgressStats`.

**Verificable:** ✅ crear/leer/borrar un `ExperienceProgress` persiste tras reabrir
el box (test de "reinicio"); providers derivados reaccionan a los cambios. 25 tests.

---

## Fase 5 — Almacenamiento de fotos ✅

- [x] **5.1** `core/services/image_storage_service.dart` — `savePhoto` copia a
  `{appDocs}/photos/{experienceId}/{uuid}.ext` y devuelve el nombre; `resolveFile`
  reconstruye la ruta; `deletePhoto`/`deleteExperiencePhotos` borran. Directorio
  base inyectable (`appDocsDirProvider`, sobreescrito en `main`).
- [x] **5.2** `core/services/image_picker_service.dart` — wrapper de `image_picker`
  (cámara y galería, `maxWidth: 1920`, `imageQuality: 85`).

**Verificable:** ✅ tests de `ImageStorageService` (copiar, resolver, nombre único,
borrar foto/carpeta) en verde. El flujo con `image_picker` se prueba en la app (Fase 7).

---

## Fase 6 — Navegación ✅

- [x] **6.1** `app/router.dart` — `GoRouter` (instancia simple `appRouter`) con las
  rutas `/`, `/departments`, `/departments/:deptId`, `/experiences/:expId` y
  placeholders navegables (se reemplazan por las pantallas reales en Fase 7).
- [x] **6.2** `app.dart` usa `appRouter` (se quitó el router placeholder de Fase 1).

**Verificable:** ✅ test de navegación recorre las 4 rutas (incl. path params)
de punta a punta.

---

## Fase 7 — Pantallas (UI) ✅

- [x] **7.1** `home/presentation/home_screen.dart` — dashboard con progreso global
  y acceso a departamentos.
- [x] **7.2** `departments/presentation/departments_screen.dart` — grid de
  departamentos con su progreso (X/Y).
- [x] **7.3** `departments/presentation/department_detail_screen.dart` — lista de
  experiencias del departamento con estado de completado.
- [x] **7.4** `experience/presentation/experience_detail_screen.dart` — detalle:
  título, descripción y, si está completada, fecha + corazones + nota + galería.
- [x] **7.5** `experience/presentation/edit_memory_sheet.dart` — marcar completada,
  fecha, corazones (1–5), nota, agregar/quitar fotos. Guarda vía repositorio.
- [x] **7.6** Widgets compartidos (tarjeta de departamento, fila de experiencia,
  selector de corazones, galería tipo polaroid).

**Verificable:** flujo completo — abrir un departamento, completar una experiencia
con foto/nota/fecha/corazones, y ver reflejado el progreso en Home.

---

## Fase 8 — Pulido y cierre del MVP

- [x] **8.1** Estados vacíos y de carga (catálogo cargando, sin recuerdos aún).
  Home (loading/error/sin recuerdos), Departamentos (loading/error), Detalle de
  experiencia (loading/no encontrada/no completada) y Detalle de departamento
  (loading + sin experiencias).
- [x] **8.2** Confirmaciones al borrar (recuerdo / foto). Diálogo reutilizable
  `confirmDestructive`; "Borrar recuerdo" (borra registro + fotos) y confirmación
  al quitar una foto en la hoja de edición.
- [x] **8.3** Formateo de fechas con `intl` (es_BO). `formatMemoryDate` usa
  `DateFormat("d 'de' MMMM 'de' y", 'es')` con init perezosa de los símbolos.
- [x] **8.4** Íconos/splash de la app y nombre "Our Journey". Ícono generado por
  `tool/generate_icon.py` (corazón terracota + camino punteado dorado, paleta del
  tema); `flutter_launcher_icons` (Android adaptive + iOS + web) y
  `flutter_native_splash` (fondo crema + corazón). Nombre "Our Journey" en
  AndroidManifest, Info.plist (display name) y web (manifest + index).
- [ ] **8.5** Revisión final de UI contra la dirección visual del Design.
- [ ] **8.6** Pruebas en Android e iOS.

**Verificable:** MVP funcional offline de punta a punta.

---

## Fase 9 — Momentos (hitos de pareja)

> Segundo mundo de contenido, paralelo a los departamentos: momentos típicos de
> pareja (primera cita, cumpleaños, primer viaje…) que el usuario llena con
> foto/nota/fecha/corazones. **Reutiliza el motor de recuerdos** (`ExperienceProgress`),
> indexado por el `id` del momento con prefijo `m_`. Decisiones aprobadas:
> curados **+ personalizados**, vista **timeline** por categoría, acceso por
> **tarjeta aparte** en Home con contador propio (no entra al anillo global).

- [x] **9.1** Modelo `Moment` (curado, inmutable: `id`, `title`, `description?`,
  `category`, `icon?`) + lista `moments` en `catalog.json` (32 momentos curados).
  `Catalog.moments` + `momentById` (parseo tolerante si falta la lista).
- [x] **9.2** Modelo Hive `CustomMoment` (`@HiveType typeId: 1`: `id`, `title`,
  `category`, `createdAt`) para personalizados; adapter (`build_runner`);
  registrar y abrir box en `hive_init`.
- [x] **9.3** `MomentsRepository` (+ `HiveMomentsRepository`) + providers:
  `curatedMomentsProvider`, `customMomentsControllerProvider`, tipo unificado
  `MomentItem`, `momentGroupsProvider` (agrupado por categoría en orden fijo) y
  `momentsProgressProvider` (X/Y) para el contador.
- [x] **9.4** `MomentsScreen` — timeline vertical por categoría con contador.
- [x] **9.5** Llenar/editar el momento reutilizando `EditMemorySheet`; vista de
  recuerdo compartida (`MemoryView`/`MemoryInvitation` extraídas del detalle de
  experiencia) + `MomentDetailScreen` ligera.
- [x] **9.6** "Agregar momento personalizado" (título + categoría) → persiste en
  `MomentsRepository`; confirmación al borrar uno personalizado (en su detalle).
- [x] **9.7** Home: segunda tarjeta "Nuestros momentos" con contador propio +
  rutas `/moments` y `/moments/:momentId`.

**Hecho:** 61 tests en verde, `flutter analyze` sin issues.

**Categorías (orden):** Primeras veces · Celebraciones · Aventuras y viajes ·
Hitos de la relación · Personalizados.

**Verificable:** abrir Momentos, llenar uno con foto/nota/fecha/corazones, crear
un momento personalizado y ver el contador propio en Home.

---

## Notas de ejecución

- Cada fase se commitea por separado para mantener la bitácora del README al día.
- El **contenido del catálogo** (Fase 3.1) es trabajo de producto: conviene ir
  llenándolo en paralelo; el código no depende de cuántas experiencias haya.
- Tras aprobar estas tareas, se empieza a implementar por la **Fase 0**.
