# Design - Our Journey

> Documento de diseño técnico del MVP. Basado en
> [00-context.md](00-context.md) y las decisiones en
> [01-decisions.md](01-decisions.md). Fecha: 2026-06-15.
>
> **Estado: APROBADO (2026-06-15).** Hive confirmado: `hive_ce`. Continúa en
> [03-tasks.md](03-tasks.md).

---

## 1. Principios de arquitectura

- **Feature-first**: el código se organiza por funcionalidad, no por tipo de archivo.
- **Separación catálogo / progreso**: dos fuentes de datos independientes unidas por `experienceId`.
- **Offline-first**: cero red. Todo vive en el dispositivo (assets + Hive + archivos locales).
- **Preparado para Firebase**: la capa de repositorios oculta la fuente de datos, de modo
  que mañana un `FirebaseProgressRepository` pueda reemplazar al de Hive sin tocar la UI.

---

## 2. Stack y dependencias propuestas

| Paquete | Uso |
|---------|-----|
| `flutter_riverpod` | Gestión de estado / inyección de dependencias |
| `go_router` | Navegación declarativa |
| `hive_ce` + `hive_ce_flutter` | Persistencia local del progreso *(ver nota)* |
| `path_provider` | Ubicar el directorio de documentos de la app (fotos) |
| `image_picker` | Tomar/seleccionar fotos |
| `uuid` | Nombres únicos de archivos de foto |
| `intl` | Formateo de fechas |
| `google_fonts` | Tipografías elegantes sin empaquetar fuentes |
| **dev:** `hive_ce_generator`, `build_runner` | Generar adapters de Hive |

> **Nota sobre Hive:** el paquete original `hive` está prácticamente sin mantenimiento.
> Se propone usar el fork comunitario **`hive_ce`** (Hive Community Edition), API casi
> idéntica y compatible. Si prefieres el `hive` clásico, se cambia sin afectar el diseño.

---

## 3. Modelo de datos

### 3.1 Catálogo (solo lectura — `assets/catalog/catalog.json`)

**Department**
| Campo | Tipo | Notas |
|-------|------|-------|
| `id` | String | ej. `"la_paz"` |
| `name` | String | "La Paz" |
| `description` | String? | breve descripción |
| `emoji` | String? | o ruta a imagen/ícono para la tarjeta |

**Experience**
| Campo | Tipo | Notas |
|-------|------|-------|
| `id` | String | ej. `"lp_telef"` (único en toda la app) |
| `departmentId` | String | a qué departamento pertenece |
| `title` | String | "Subir al Teleférico juntos" |
| `description` | String? | detalle / inspiración |
| `category` | String? | opcional: comida, paisaje, aventura… (para filtrar a futuro) |

Estos modelos son **inmutables** y se cargan una vez al iniciar.

### 3.2 Progreso del usuario (mutable — Hive)

**ExperienceProgress** (clave en Hive = `experienceId`)
| Campo | Tipo | Notas |
|-------|------|-------|
| `experienceId` | String | enlaza con el catálogo |
| `completed` | bool | marcado como completado |
| `completedDate` | DateTime? | fecha en que lo vivieron |
| `rating` | int? | **1–5 corazones** |
| `note` | String? | texto libre del recuerdo |
| `photoFileNames` | List\<String\> | **solo nombres de archivo**, no rutas absolutas (ver §4) |
| `createdAt` | DateTime | |
| `updatedAt` | DateTime | |

> Solo existe un `ExperienceProgress` para una experiencia **cuando el usuario interactúa**
> con ella (la completa o le agrega algo). Las no tocadas no ocupan espacio en Hive.

### 3.3 Por qué guardar nombres de archivo y no rutas completas

En **iOS** la ruta del directorio de documentos **cambia entre ejecuciones** (el contenedor
tiene un UUID que varía). Si guardamos rutas absolutas, las fotos "desaparecen" tras
reiniciar. Solución: guardamos solo el **nombre de archivo** y reconstruimos la ruta en
tiempo de lectura como `{appDocsDir}/photos/{experienceId}/{fileName}`.

---

## 4. Almacenamiento de fotos

Servicio `ImageStorageService` (en `core/`):

- Al agregar una foto: copiar el archivo elegido a
  `{appDocs}/photos/{experienceId}/{uuid}.jpg` y devolver el **nombre de archivo**.
- Al leer: resolver `{appDocs}/photos/{experienceId}/{fileName}`.
- Al borrar una foto o una experiencia: eliminar también los archivos físicos.
- **Nunca** se guardan los bytes de la imagen en Hive (solo referencias).

---

## 5. Estructura de carpetas (feature-first)

```
lib/
  main.dart                      # bootstrap: init Hive + runApp(ProviderScope)
  app/
    app.dart                     # MaterialApp.router
    router.dart                  # configuración de GoRouter
    theme/
      app_theme.dart
      app_colors.dart
      app_typography.dart
  core/
    storage/
      hive_init.dart             # apertura de boxes y registro de adapters
    services/
      image_storage_service.dart
    utils/
      date_formatter.dart
  catalog/                       # fuente de datos del catálogo (compartida)
    models/
      department.dart
      experience.dart
    catalog_loader.dart          # carga y parsea catalog.json
    catalog_providers.dart       # FutureProvider del catálogo
  features/
    home/                        # dashboard + progreso global
      presentation/
        home_screen.dart
        widgets/
        home_providers.dart
    departments/                 # lista de departamentos + detalle (sus experiencias)
      presentation/
        departments_screen.dart
        department_detail_screen.dart
        widgets/
    experience/                  # detalle de una experiencia + edición del recuerdo
      data/
        progress_repository.dart # CRUD sobre Hive
      models/
        experience_progress.dart # modelo Hive + adapter generado
      presentation/
        experience_detail_screen.dart
        edit_memory_sheet.dart   # fecha, rating, nota, fotos
        widgets/
      experience_providers.dart  # providers de progreso
assets/
  catalog/
    catalog.json
```

---

## 6. Capa de estado (Riverpod)

| Provider | Tipo | Responsabilidad |
|----------|------|-----------------|
| `catalogProvider` | `FutureProvider<Catalog>` | carga `catalog.json` una vez |
| `departmentsProvider` | `Provider<List<Department>>` | departamentos del catálogo |
| `experiencesByDeptProvider(id)` | `Provider.family` | experiencias de un departamento |
| `progressRepositoryProvider` | `Provider` | acceso a Hive (CRUD) |
| `progressProvider(expId)` | `Provider.family` | progreso de una experiencia |
| `overallProgressProvider` | `Provider` | estadísticas globales (X/Y completadas) |
| `departmentProgressProvider(id)` | `Provider.family` | progreso por departamento |

El **repositorio** es la única pieza que conoce Hive. La UI solo habla con providers.
Esto es lo que permite migrar a Firebase a futuro sin reescribir pantallas.

---

## 7. Navegación (GoRouter)

| Ruta | Pantalla | Descripción |
|------|----------|-------------|
| `/` | `HomeScreen` | dashboard: progreso global + acceso a departamentos |
| `/departments` | `DepartmentsScreen` | lista de departamentos |
| `/departments/:deptId` | `DepartmentDetailScreen` | experiencias de ese departamento |
| `/experiences/:expId` | `ExperienceDetailScreen` | detalle + editar recuerdo |

---

## 8. Pantallas del MVP

1. **Home / Dashboard** — saludo, progreso global (ej. "12 de 80 recuerdos creados"),
   accesos a departamentos, quizá últimos recuerdos.
2. **Departamentos** — grid/lista de los 9 departamentos con su progreso (ej. 3/10).
3. **Detalle de departamento** — lista de experiencias, marcando cuáles están completadas.
4. **Detalle de experiencia** — título, descripción, estado, y si está completada: fecha,
   corazones, nota y galería de fotos. Botón para crear/editar el recuerdo.
5. **Editar recuerdo** (bottom sheet o pantalla) — marcar completada, elegir fecha,
   poner corazones (1–5), escribir nota, agregar/quitar fotos.

---

## 9. Dirección de diseño visual (warm / romantic / elegant)

- **Paleta** (propuesta inicial): fondos crema/marfil, acentos en terracota/rosa polvo,
  detalles en dorado suave. Nada de colores chillones ni infantiles.
- **Tipografía**: una *serif* elegante para títulos (ej. Playfair Display) + una *sans*
  legible para el cuerpo (ej. Nunito Sans / Inter). Vía `google_fonts`.
- **Estética scrapbook**: tarjetas con sombras suaves, esquinas redondeadas, fotos tipo
  polaroid, microcopys cálidos.

> Esta sección es una dirección, no un sistema de diseño cerrado. Se afina al implementar.

---

## 10. Fuera de alcance del MVP (confirmado)

Autenticación · sincronización en la nube · funciones sociales · IA · backend online ·
crear experiencias propias.

---

## 11. Próximo paso

Si apruebas este Design, el siguiente entregable es **`03-tasks.md`**: el desglose de
tareas de implementación en orden (setup de dependencias → tema → modelos → catálogo →
Hive/repositorio → navegación → pantallas), respetando la regla de no codificar hasta
aprobar las tareas.
