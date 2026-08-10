# EduPlay Refactor Audit Report - 2026-08-10

## 1. Resumen ejecutivo

### Estado inicial

- Proyecto Flutter con estructura principal valida en `lib/`, `android/`, `ios/`, `web/`, `assets/`, `functions/` y `test/`.
- Se detecto un scaffold Flutter completo anidado accidentalmente dentro de `ios/`: contenia subproyectos `android`, `ios`, `linux`, `macos`, `web`, `windows`, un `lib/main.dart`, `pubspec.yaml`, `pubspec.lock` y archivos de metadatos propios de otro proyecto.
- Existian placeholders `dummy.txt` dentro de carpetas de assets empaquetadas por Flutter.
- Habia carpetas vacias sin valor funcional: `lib/features/child_portal/pages` y `lib/features/games_catalog/pages`.
- El codigo compila estaticamente, pero presenta deuda arquitectonica relevante: paginas muy grandes, acceso directo a Firebase/Firestore desde vistas y servicios colocados dentro de features sin contratos de dominio.

### Estado final

- Se elimino el scaffold Flutter anidado bajo `ios/`, conservando el target iOS real del proyecto: `ios/Flutter`, `ios/Runner`, `ios/Runner.xcodeproj`, `ios/Runner.xcworkspace`, `ios/RunnerTests` y `ios/Podfile`.
- Se eliminaron placeholders de assets no referenciados.
- Se eliminaron directorios vacios y artefactos regenerables (`build`, `android/.gradle`).
- Se ejecuto `fvm flutter analyze` y el resultado fue: `No issues found`.
- No se movieron clases funcionales entre capas porque los cambios seguros detectados eran de limpieza estructural; mover vistas/servicios actuales requiere refactor funcional incremental y pruebas dedicadas.

## 2. Archivos y carpetas eliminadas

### Scaffolds Flutter anidados dentro de `ios/`

Motivo: estructura completa de otro proyecto Flutter creada accidentalmente dentro del target iOS. No estaba referenciada por `pubspec.yaml`, imports Dart, configuracion del proyecto raiz ni por la estructura normal de Flutter iOS.

- `ios/android/`
- `ios/ios/`
- `ios/lib/main.dart`
- `ios/linux/`
- `ios/macos/`
- `ios/web/`
- `ios/windows/`
- `ios/.gitignore`
- `ios/.metadata`
- `ios/analysis_options.yaml`
- `ios/README.md`
- `ios/pubspec.yaml`
- `ios/pubspec.lock`

Estos directorios representaban 125 archivos versionados eliminados, incluyendo manifests, Gradle files, CMake files, assets de iconos, workspaces Xcode duplicados y configuraciones de plataformas que no pertenecian al proyecto raiz.

### Assets placeholder eliminados

Motivo: placeholders vacios/no funcionales dentro de carpetas declaradas como assets. No habia referencias por nombre en el codigo.

- `assets/audio/dummy.txt`
- `assets/icons/dummy.txt`

### Directorios vacios eliminados

Motivo: carpetas sin archivos despues del escaneo y sin valor estructural actual.

- `lib/features/child_portal/`
- `lib/features/games_catalog/pages/`

### Artefactos locales regenerables limpiados

Motivo: caches/build outputs que no deben formar parte del codigo fuente.

- `build/`
- `android/.gradle/`
- `.dart_tool/` fue parcialmente limpiado inicialmente, pero `fvm flutter analyze` lo regenero. Debe permanecer ignorado por Git.
- Archivos iOS generados por Flutter durante el analyze y retirados al final:
  - `ios/Flutter/flutter_export_environment.sh`
  - `ios/Runner/GeneratedPluginRegistrant.h`
  - `ios/Runner/GeneratedPluginRegistrant.m`

## 3. Mejoras arquitectonicas aplicadas

- Reduccion de ruido estructural: se removio un proyecto Flutter anidado que podia confundir busquedas, analisis, conteo de lineas, tooling y mantenimiento.
- Reduccion del paquete de assets: se eliminaron placeholders empaquetables por estar bajo rutas declaradas en `pubspec.yaml`.
- Limpieza de directorios sin responsabilidad funcional.
- Validacion posterior con `fvm flutter analyze`: sin errores ni warnings.

No se aplicaron reorganizaciones de capas en codigo funcional porque la auditoria encontro acoplamientos que requieren extraccion progresiva y pruebas, no movimientos mecanicos seguros.

## 4. Deuda tecnica pendiente / Proximos pasos

### Archivos grandes a modularizar

- `lib/features/parents_dashboard/pages/parents_dashboard_page.dart` - 2876 lineas.
- `lib/features/student_dashboard/pages/student_dashboard_layout.dart` - 2538 lineas.
- `lib/features/parent_guide/pages/parent_guide_page.dart` - 2067 lineas.
- `lib/features/settings/pages/settings_page.dart` - 1949 lineas.
- `lib/features/games_catalog/widgets/catalog_filter_content.dart` - 1302 lineas.
- `lib/features/teacher_dashboard/pages/teacher_dashboard_layout.dart` - 1181 lineas.
- `lib/features/teacher_dashboard/pages/mis_clases_panel.dart` - 904 lineas.
- `lib/features/login/pages/login_layout.dart` - 892 lineas.

Recomendacion: extraer widgets privados a `widgets/`, mover orquestacion de estado a controllers/blocs y dejar las paginas como composicion de layout.

### Acoplamientos de Clean Architecture detectados

- Vistas con acceso directo a Firebase/Firestore/Auth:
  - `lib/features/admin/pages/admin_dashboard_page.dart`
  - `lib/features/parents_dashboard/pages/parents_dashboard_page.dart`
  - `lib/features/settings/pages/settings_page.dart`
  - `lib/features/teacher_registration/pages/teacher_registration_page.dart`
  - `lib/features/student_dashboard/pages/student_dashboard_page.dart`
  - `lib/features/practice_session/pages/session_entry_page.dart`
  - `lib/features/teacher_assignment/pages/browse_teachers_page.dart`
- Widgets compartidos con dependencia directa de auth:
  - `lib/shared/widgets/email_verification_banner.dart`
  - `lib/shared/widgets/edu_play_nav_bar.dart`
- Servicios de feature con singletons estaticos directos a Firebase:
  - `lib/features/parents_dashboard/services/child_profiles_service.dart`
  - `lib/features/practice_session/services/practice_sessions_service.dart`
  - `lib/features/teacher_dashboard/services/teacher_classes_service.dart`
  - `lib/features/teacher_dashboard/services/classroom_challenges_service.dart`
  - `lib/features/subscription/services/subscription_service.dart`

Recomendacion: introducir interfaces de dominio/repositorios por feature, inyectar dependencias con `get_it` y reservar Firebase/HTTP/SharedPreferences para datasources.

### Codigo potencialmente no alcanzable desde `lib/main.dart`

No se elimino automaticamente porque puede ser codigo planificado, usado por pruebas futuras o alcanzado por integracion dinamica. Requiere confirmacion funcional:

- `lib/features/login_main/login_page.dart`
- `lib/features/menu/widgets/menu_buttons.dart`
- `lib/features/math_adventure/models/question.dart`
- `lib/features/parents_dashboard/bloc/parents_dashboard_bloc.dart`
- `lib/features/register_child/widgets/register_child_form.dart`
- `lib/features/register_child/widgets/save_button.dart`
- `lib/features/register_parents/widgets/register_parents_button.dart`
- `lib/features/register_parents/widgets/register_parents_child.dart`
- `lib/features/register_parents/widgets/register_parents_child_form.dart`
- `lib/features/register_parents/widgets/register_parents_form.dart`
- `lib/features/student_dashboard/widgets/mission_banner.dart`
- `lib/features/student_dashboard/widgets/my_games_preview.dart`
- `lib/features/student_dashboard/widgets/stat_cards.dart`
- `lib/features/student_dashboard/widgets/sticker_album_card.dart`
- `lib/features/teacher_dashboard/widgets/assigned_challenges_card.dart`
- `lib/features/teacher_dashboard/widgets/students_list.dart`
- `lib/features/teacher_dashboard/widgets/subject_performance_card.dart`
- `lib/features/teacher_dashboard/widgets/teacher_stat_cards.dart`
- `lib/features/teacher_dashboard/widgets/weekly_progress_card.dart`
- `lib/shared/widgets/dashboard_shell.dart`
- `lib/shared/widgets/email_verification_banner.dart`
- `lib/shared/widgets/placeholder_section.dart`
- `lib/shared/widgets/simple_bar_chart.dart`
- `lib/core/audio/sound_manager.dart`
- `lib/features/parent_guide/services/external_resources_service.dart`

### Roadmap recomendado

1. Estabilizar contratos por feature: `domain/entities`, `domain/repositories`, `data/datasources`, `data/repositories`, `presentation`.
2. Refactorizar primero `parents_dashboard_page.dart` y `settings_page.dart`, porque concentran UI, persistencia y reglas de usuario.
3. Migrar accesos directos a Firebase desde paginas hacia servicios inyectables con interfaces testeables.
4. Agregar tests de widget para dashboards principales antes de fragmentar layouts grandes.
5. Revisar la lista de codigo potencialmente no alcanzable con criterios de producto y eliminar lo que no corresponda a una ruta activa.

## 5. Validacion

- Comando ejecutado: `fvm flutter analyze`
- Resultado: `No issues found`

