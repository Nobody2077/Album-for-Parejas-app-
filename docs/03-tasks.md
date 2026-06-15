# Tasks - Our Journey (MVP)

> Desglose de implementación basado en [02-design.md](02-design.md).
> Orden pensado para que cada bloque deje algo verificable. Fecha: 2026-06-15.
>
> **Estado: PROPUESTA — pendiente de aprobación.** No se escribe código de
> implementación hasta aprobar estas tareas (regla de Spec Driven Development).
>
> Hive: se usa **`hive_ce`** (confirmado).

---

## Fase 0 — Setup del proyecto

- [ ] **0.1** Agregar dependencias al `pubspec.yaml`:
  `flutter_riverpod`, `go_router`, `hive_ce`, `hive_ce_flutter`, `path_provider`,
  `image_picker`, `uuid`, `intl`, `google_fonts`.
- [ ] **0.2** Agregar dev-dependencies: `hive_ce_generator`, `build_runner`.
- [ ] **0.3** Declarar `assets/catalog/` en la sección `flutter:` del `pubspec.yaml`.
- [ ] **0.4** Permisos de plataforma para `image_picker` (cámara/galería en
  `Info.plist` de iOS y `AndroidManifest.xml`).
- [ ] **0.5** `flutter pub get` y verificar que compila el proyecto base.

**Verificable:** el proyecto compila con las nuevas dependencias.

---

## Fase 1 — Tema y arranque

- [ ] **1.1** `app/theme/app_colors.dart` — paleta (crema, terracota, rosa polvo, dorado).
- [ ] **1.2** `app/theme/app_typography.dart` — tipografías con `google_fonts`
  (serif para títulos, sans para cuerpo).
- [ ] **1.3** `app/theme/app_theme.dart` — `ThemeData` warm/elegant.
- [ ] **1.4** `app/app.dart` — `MaterialApp.router` aplicando el tema.
- [ ] **1.5** `main.dart` — bootstrap mínimo con `ProviderScope` (Hive se conecta en Fase 4).

**Verificable:** la app arranca mostrando una pantalla con el tema aplicado.

---

## Fase 2 — Modelos del catálogo

- [ ] **2.1** `catalog/models/department.dart` — modelo inmutable + `fromJson`.
- [ ] **2.2** `catalog/models/experience.dart` — modelo inmutable + `fromJson`.
- [ ] **2.3** Modelo contenedor `Catalog` (lista de departamentos y de experiencias).

**Verificable:** tests unitarios de parseo `fromJson` pasan.

---

## Fase 3 — Catálogo curado (datos + carga)

- [ ] **3.1** Crear `assets/catalog/catalog.json` con un set inicial de los 9
  departamentos y unas experiencias por cada uno (contenido de producto).
- [ ] **3.2** `catalog/catalog_loader.dart` — leer y parsear el JSON desde assets.
- [ ] **3.3** `catalog/catalog_providers.dart` — `catalogProvider`,
  `departmentsProvider`, `experiencesByDeptProvider(id)`.

**Verificable:** un provider expone los departamentos leídos del JSON.

---

## Fase 4 — Persistencia (Hive)

- [ ] **4.1** `experience/models/experience_progress.dart` — modelo Hive
  (`@HiveType`) con los campos del Design.
- [ ] **4.2** Generar el adapter con `build_runner`.
- [ ] **4.3** `core/storage/hive_init.dart` — inicializar Hive, registrar adapter,
  abrir el box de progreso.
- [ ] **4.4** Conectar `hive_init` en `main.dart` antes de `runApp`.
- [ ] **4.5** `experience/data/progress_repository.dart` — CRUD sobre Hive
  (obtener, crear/actualizar, borrar progreso por `experienceId`).
- [ ] **4.6** `experience/experience_providers.dart` — `progressRepositoryProvider`,
  `progressProvider(expId)`, `overallProgressProvider`, `departmentProgressProvider(id)`.

**Verificable:** crear/leer/borrar un `ExperienceProgress` persiste tras reiniciar.

---

## Fase 5 — Almacenamiento de fotos

- [ ] **5.1** `core/services/image_storage_service.dart` — copiar foto elegida a
  `{appDocs}/photos/{experienceId}/{uuid}.jpg`, devolver nombre de archivo;
  resolver ruta de lectura; borrar archivo(s).
- [ ] **5.2** Integrar `image_picker` (cámara y galería) detrás del servicio.

**Verificable:** se selecciona una foto, se copia al directorio de la app y se
puede volver a mostrar desde su nombre de archivo.

---

## Fase 6 — Navegación

- [ ] **6.1** `app/router.dart` — `GoRouter` con las rutas:
  `/`, `/departments`, `/departments/:deptId`, `/experiences/:expId`.
- [ ] **6.2** Conectar el router en `app.dart`.

**Verificable:** se puede navegar entre pantallas placeholder de cada ruta.

---

## Fase 7 — Pantallas (UI)

- [ ] **7.1** `home/presentation/home_screen.dart` — dashboard con progreso global
  y acceso a departamentos.
- [ ] **7.2** `departments/presentation/departments_screen.dart` — grid de
  departamentos con su progreso (X/Y).
- [ ] **7.3** `departments/presentation/department_detail_screen.dart` — lista de
  experiencias del departamento con estado de completado.
- [ ] **7.4** `experience/presentation/experience_detail_screen.dart` — detalle:
  título, descripción y, si está completada, fecha + corazones + nota + galería.
- [ ] **7.5** `experience/presentation/edit_memory_sheet.dart` — marcar completada,
  fecha, corazones (1–5), nota, agregar/quitar fotos. Guarda vía repositorio.
- [ ] **7.6** Widgets compartidos (tarjeta de departamento, fila de experiencia,
  selector de corazones, galería tipo polaroid).

**Verificable:** flujo completo — abrir un departamento, completar una experiencia
con foto/nota/fecha/corazones, y ver reflejado el progreso en Home.

---

## Fase 8 — Pulido y cierre del MVP

- [ ] **8.1** Estados vacíos y de carga (catálogo cargando, sin recuerdos aún).
- [ ] **8.2** Confirmaciones al borrar (recuerdo / foto).
- [ ] **8.3** Formateo de fechas con `intl` (es_BO).
- [ ] **8.4** Íconos/splash de la app y nombre "Our Journey".
- [ ] **8.5** Revisión final de UI contra la dirección visual del Design.
- [ ] **8.6** Pruebas en Android e iOS.

**Verificable:** MVP funcional offline de punta a punta.

---

## Notas de ejecución

- Cada fase se commitea por separado para mantener la bitácora del README al día.
- El **contenido del catálogo** (Fase 3.1) es trabajo de producto: conviene ir
  llenándolo en paralelo; el código no depende de cuántas experiencias haya.
- Tras aprobar estas tareas, se empieza a implementar por la **Fase 0**.
