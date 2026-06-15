# Decisiones de Producto (Requirements-lite)

> Pasada corta de requisitos previa al Design. Solo recoge las decisiones que
> afectan directamente al modelo de datos y la arquitectura. Fecha: 2026-06-15.

| # | Decisión | Elección | Impacto |
|---|----------|----------|---------|
| 1 | Fotos por experiencia | **Varias** (galería) | `ExperienceProgress` guarda una **lista** de rutas de imagen |
| 2 | Experiencias del usuario | **Solo completar las curadas** (no crear propias en MVP) | El catálogo es de solo lectura; el usuario nunca lo modifica |
| 3 | Origen del catálogo | **JSON en `assets/`** (solo lectura) | Catálogo separado del progreso; fácil de versionar/actualizar |
| 4 | Valoración (rating) | **Corazones 1-5** | `rating: int` (1–5) en `ExperienceProgress`, UI de corazones |

## Consecuencia clave de diseño

Hay **dos mundos de datos separados**:

1. **Catálogo** (curado, inmutable) → `assets/catalog/catalog.json`, solo lectura.
2. **Progreso del usuario** (mutable) → **Hive**, persistido en el dispositivo.

Nunca se mezclan. El nexo entre ambos es el `experienceId`.
