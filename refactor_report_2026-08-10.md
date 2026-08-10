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


## Fase 2 - Refactorizacion parents_dashboard (2026-08-10)

### Cambios aplicados
- Se desacoplo `parents_dashboard_page.dart` de acceso directo a Firebase/Auth para el flujo principal de perfiles, controles rapidos y desafios mediante repositorios/datasources ya registrados en `get_it`.
- Se extrajeron widgets autocontenidos desde `parents_dashboard_page.dart` hacia `lib/features/parents_dashboard/widgets/`:
  - `parent_quick_controls_card.dart`
  - `parent_challenges_card.dart`
  - `parent_weekly_summary_card.dart`
  - `parent_active_sessions_card.dart`
  - `parent_session_history_card.dart`
- Se encapsularon dependencias visuales y de formato (`intl`, estados de streams de sesiones, controles rapidos y desafios) dentro de widgets especializados.

### Estado de calidad
- `parents_dashboard_page.dart` se redujo progresivamente hasta 2242 lineas.
- `fvm flutter analyze` ejecutado despues de los cambios: sin issues.
- No quedan referencias a `FirebaseFirestore` ni `FirebaseAuth` en `parents_dashboard_page.dart` ni en los widgets extraidos del dashboard de padres.

### Deuda pendiente recomendada
- Extraer `_ChildProfilesGrid`, `_ChildCard`, `_AddProfileDialog` y `_ChildActivitySheet` en widgets/controladores dedicados.
- Desacoplar `PracticeSessionsService` detras de repositorios/datasources para sesiones activas, historial y actividad por hijo.
- Repetir el mismo patron en `student_dashboard_layout.dart`, `parent_guide_page.dart` y `settings_page.dart`.

## Fase 3 - Desacoplamiento practice_session (2026-08-10)

### Cambios aplicados
- Se creo el contrato `PracticeSessionsRepository` en `lib/features/practice_session/domain/repositories/`.
- Se creo `PracticeSessionsDatasource` y `FirestorePracticeSessionsDatasource` en `lib/features/practice_session/data/datasources/` para aislar Firestore/Auth.
- Se creo `FirestorePracticeSessionsRepository` en `lib/features/practice_session/data/repositories/`.
- Se registro `PracticeSessionsDatasource` y `PracticeSessionsRepository` en `lib/utils/injection_container.dart`.
- `PracticeSessionsService` quedo como fachada de compatibilidad que delega al repositorio inyectado, sin imports directos de Firebase.

### Estado de calidad
- `fvm flutter analyze` ejecutado despues del cambio: sin issues.
- Firebase/Auth para sesiones queda localizado en la capa `data/datasources`.

### Deuda pendiente recomendada
- Migrar consumidores de `PracticeSessionsService` a `PracticeSessionsRepository` inyectado por feature/controlador.
- Extraer `_ChildActivitySheet` para eliminar el ultimo uso de sesiones dentro de `parents_dashboard_page.dart`.

## Fase 4 - Modularizacion avanzada parents_dashboard (2026-08-10)

### Cambios aplicados
- Se extrajo `ParentChildActivitySheet` a `lib/features/parents_dashboard/widgets/parent_child_activity_sheet.dart`.
- Se migro el sheet de actividad infantil a `PracticeSessionsRepository` inyectado, eliminando el uso de `PracticeSessionsService` desde `parents_dashboard_page.dart`.
- Se extrajo `ParentChildProfilesGrid` a `lib/features/parents_dashboard/widgets/parent_child_profiles_grid.dart`, junto con el card de perfil, acciones, dialogo PIN y helpers visuales asociados.
- Se elimino `_AddProfileDialog` y helpers relacionados como codigo muerto privado: el flujo activo de alta de perfil navega a `RouterPaths.createExplorer`.

### Estado de calidad
- `parents_dashboard_page.dart` quedo en 905 lineas.
- `fvm flutter analyze` ejecutado despues de los cambios: sin issues.
- No quedan referencias a `FirebaseFirestore`, `FirebaseAuth` ni `PracticeSessionsService` en `parents_dashboard_page.dart`.

### Deuda pendiente recomendada
- Extraer `_AchievementCard`, `_TierBadge` y `_RecommendationsCard` para cerrar la modularizacion del dashboard de padres.
- Continuar con `settings_page.dart` y `student_dashboard_layout.dart`, que siguen siendo los siguientes archivos monoliticos de mayor riesgo.


## Fase 5 - Desacoplamiento subscription y cierre de modularizacion parents_dashboard (2026-08-10)

### Cambios aplicados
- Se creo `SubscriptionRepository` en `lib/features/subscription/domain/repositories/`.
- Se creo `SubscriptionDatasource` y `FirestoreSubscriptionDatasource` en `lib/features/subscription/data/datasources/` para aislar Firestore/Auth.
- Se creo `FirestoreSubscriptionRepository` en `lib/features/subscription/data/repositories/`.
- Se registro `SubscriptionDatasource` y `SubscriptionRepository` en `lib/utils/injection_container.dart`.
- `SubscriptionService` quedo como fachada de compatibilidad que delega al repositorio inyectado, sin imports directos de Firebase.
- Se extrajeron widgets adicionales desde `parents_dashboard_page.dart` hacia `lib/features/parents_dashboard/widgets/`:
  - `parent_tier_badge.dart`
  - `parent_achievement_card.dart`
  - `parent_empty_profiles.dart`
  - `parent_recommendations_card.dart`

### Estado de calidad
- `parents_dashboard_page.dart` quedo en 427 lineas.
- `fvm flutter analyze` ejecutado despues de los cambios: sin issues.
- Firebase/Auth para suscripciones queda localizado en `lib/features/subscription/data/datasources/subscription_datasource.dart`.
- `parents_dashboard_page.dart` no contiene referencias a `FirebaseFirestore`, `FirebaseAuth`, `PracticeSessionsService` ni `SubscriptionService`.

### Deuda pendiente recomendada
- Migrar consumidores legacy de `SubscriptionService` a `SubscriptionRepository` inyectado: `auth_datasource.dart`, `create_explorer_page.dart`, `create_session_page.dart` y `settings_page.dart`.
- Evaluar si `ProgressRecommendationsService` debe convertirse en repositorio/caso de uso propio; actualmente no toca Firebase directamente, pero sigue siendo una fachada estatica.
- Continuar con `settings_page.dart` como siguiente monolito con acoplamiento directo a Firebase/Auth.

## Fase 6 - Correccion GetIt y refactorizacion inicial settings/subscription (2026-08-10)

### Error corregido
- Se resolvio el fallo runtime: `Object/factory with type SubscriptionRepository is not registered inside GetIt`.
- `lib/utils/injection_container.dart` ahora registra dependencias de forma idempotente usando `sl.isRegistered<T>()`, evitando fallos por reinicializaciones parciales o reconstrucciones en web/hot restart.
- `ParentTierBadge` ya no resuelve `SubscriptionRepository` durante la construccion del widget; lo resuelve en `build()` tras asegurar `init()`.

### Cambios aplicados
- Se migro `_SubscriptionSection` en `settings_page.dart` de `SubscriptionService` a `SubscriptionRepository` inyectado.
- Se creo una capa inicial para settings:
  - `lib/features/settings/domain/entities/parent_settings_profile.dart`
  - `lib/features/settings/domain/entities/notification_preferences.dart`
  - `lib/features/settings/domain/repositories/settings_repository.dart`
  - `lib/features/settings/data/datasources/settings_datasource.dart`
  - `lib/features/settings/data/repositories/firestore_settings_repository.dart`
- Se registro `SettingsDatasource` y `SettingsRepository` en `get_it`.
- Se migro lectura/guardado de perfil del padre desde `settings_page.dart` hacia `SettingsRepository`.
- Se migro lectura/guardado de preferencias de notificacion desde `settings_page.dart` hacia `SettingsRepository`.
- Se migraron consumidores simples de suscripcion en:
  - `lib/features/create_explorer/pages/create_explorer_page.dart`
  - `lib/features/practice_session/pages/create_session_page.dart`
- `create_session_page.dart` ahora usa `PracticeSessionsRepository` para crear sesiones, eliminando dependencia directa de `PracticeSessionsService`.
- `auth_datasource.dart` dejo de depender de `SubscriptionService`; siembra el documento `subscriptions/{uid}` desde infraestructura al registrar un padre.

### Estado de calidad
- `fvm flutter analyze` ejecutado despues de los cambios: sin issues.
- `SubscriptionService` ya no tiene consumidores en `lib`; queda como fachada legacy disponible.
- `settings_page.dart` conserva acceso directo a Firebase/Auth solo en flujos sensibles pendientes: cambio de password, cierre de sesion y borrado de cuenta.

### Deuda pendiente recomendada
- Crear un `AccountSecurityRepository`/datasource para cambio de password, cierre de sesion y borrado de cuenta.
- Extraer secciones de `settings_page.dart` a widgets dedicados para reducir el archivo monolitico.
- Separar borrado de cuenta en un caso de uso transaccional o cloud function para evitar inconsistencias entre Auth y Firestore.

## Fase 7 - Dashboard estudiante: navegacion, Logros y modularizacion (2026-08-10)

### Bugs corregidos
- Se elimino la duplicacion visual de opciones en desktop: la navegacion principal queda en el sidebar y el top bar queda como encabezado de estado/perfil.
- Se corrigio la pantalla vacia de `Logros`: `StickerAlbumGrid` ahora soporta uso embebido con `shrinkWrap` y `physics`, evitando problemas al renderizar un `GridView` dentro de un `CustomScrollView`.

### Cambios aplicados
- Se extrajo la navegacion del dashboard estudiante a `lib/features/student_dashboard/widgets/student_dashboard_navigation.dart`:
  - `StudentTopNavBar`
  - `StudentSidebar`
  - `StudentPointsBadge`
- Se extrajo la vista de logros a `lib/features/student_dashboard/widgets/student_achievements_view.dart`.
- `student_dashboard_layout.dart` queda enfocado en composicion de tabs y seleccion de contenido.
- `StickerAlbumGrid` conserva comportamiento standalone y ahora tambien permite render no-scroll embebido desde secciones internas.

### Estado de calidad
- `student_dashboard_layout.dart` se redujo a 2279 lineas.
- `fvm flutter analyze` ejecutado despues de los cambios: sin issues.

### Deuda pendiente recomendada
- Continuar extrayendo del dashboard estudiante: Home, Mis Juegos, sesiones/recomendaciones y tarjetas de album.
- Migrar `PracticeSessionsService`, `ProgressRecommendationsService` y `ClassroomChallengesService` restantes en el bloc/layout hacia repositorios/casos de uso inyectados.
- Agregar test/widget smoke para las tabs `Panel de Control`, `Mis Juegos` y `Logros`, validando que cada una renderiza contenido visible.

## Fase 8 - Modularizacion profunda student_dashboard (2026-08-10)

### Cambios aplicados
- Se extrajo el hub completo de juegos a `lib/features/student_dashboard/widgets/student_games_hub_view.dart`.
- Se extrajo la seccion de juegos del home y preview de album a `lib/features/student_dashboard/widgets/student_home_games_section.dart`.
- Se extrajeron recomendaciones y sesiones activas a `lib/features/student_dashboard/widgets/student_practice_sections.dart`.
- `StudentPracticeSessionsSection` ahora usa `PracticeSessionsRepository` inyectado, eliminando el consumo de `PracticeSessionsService` desde el layout del estudiante.
- Se extrajeron banner de mision y tarjetas de estadisticas a `lib/features/student_dashboard/widgets/student_home_overview_widgets.dart`.

### Estado de calidad
- `student_dashboard_layout.dart` quedo en 649 lineas.
- `fvm flutter analyze` ejecutado despues de los cambios: sin issues.
- El layout principal queda orientado a composicion de tabs y coordinacion de estado local minima.

### Deuda pendiente recomendada
- Extraer `HomeView` y `AmigosEnLineaCard` para cerrar la modularizacion del dashboard estudiante.
- Desacoplar `ClassroomChallengesService` y `ProgressRecommendationsService` del `StudentDashboardBloc` mediante repositorios/casos de uso inyectados.
- Agregar smoke tests de tabs para asegurar que `Panel de Control`, `Mis Juegos` y `Logros` renderizan contenido visible despues de la extraccion.

## Fase 9 - Cierre de modularizacion student_dashboard y desacoplamiento de recomendaciones (2026-08-10)

### Cambios aplicados
- Se extrajo `StudentHomeView` a `lib/features/student_dashboard/widgets/student_home_view.dart`.
- Se movio la tarjeta social/challenges interna del home junto con sus helpers de titulo/enlace, dejando `student_dashboard_layout.dart` como orquestador de tabs y navegacion.
- `student_dashboard_layout.dart` quedo en 239 lineas.
- `ProgressRecommendationsService` dejo de depender de `PracticeSessionsService`; ahora resuelve `PracticeSessionsRepository` desde `get_it` manteniendo su API publica actual.

### Estado de calidad
- `fvm flutter analyze` ejecutado despues de los cambios: sin issues.
- `student_dashboard_layout.dart` ya no contiene widgets privados grandes del home, juegos, logros, navegacion, recomendaciones ni sesiones.

### Deuda pendiente recomendada
- Convertir `ProgressRecommendationsService` en un caso de uso/repositorio inyectable para eliminar la fachada estatica restante.
- Desacoplar `ClassroomChallengesService` del `StudentDashboardBloc` y del dashboard docente mediante contratos de dominio.
- Continuar con `settings_page.dart` como siguiente monolito complejo.

## Fase 10 - Modularizacion y seguridad de settings (2026-08-10)

### Cambios aplicados
- Se creo la capa de seguridad de cuenta:
  - `lib/features/settings/domain/entities/account_security_info.dart`
  - `lib/features/settings/domain/repositories/account_security_repository.dart`
  - `lib/features/settings/data/datasources/account_security_datasource.dart`
  - `lib/features/settings/data/repositories/firebase_account_security_repository.dart`
- Se registro `AccountSecurityDatasource` y `AccountSecurityRepository` en `get_it`.
- `settings_page.dart` dejo de acceder directamente a `FirebaseAuth`, `FirebaseFirestore` y `EmailAuthProvider`.
- Se extrajeron widgets/secciones:
  - `settings_section_card.dart`
  - `settings_profile_section.dart`
  - `settings_subscription_section.dart`
  - `settings_notifications_section.dart`
  - `settings_security_section.dart`
- Se corrigio un fallo de analisis en el modulo nuevo `number_ninja` agregando `number_ninja_page.dart`, ya que el modulo importaba una pagina inexistente.

### Estado de calidad
- `settings_page.dart` quedo en 335 lineas.
- `fvm flutter analyze` ejecutado despues de los cambios: sin issues.
- Firebase/Auth en settings queda localizado en `data/datasources`.

### Deuda pendiente recomendada
- Mover logout del sidebar a un controlador/presenter de settings si se desea eliminar toda resolucion `sl` desde widgets.
- Evaluar mover borrado de cuenta a Cloud Function/transaccion backend para mayor robustez ante eliminaciones parciales.
- Continuar con `ClassroomChallengesService` como siguiente bloque de desacoplamiento transversal estudiante/docente.

## Fase 11 - Correccion de retorno desde juegos y preservacion de sesion infantil (2026-08-10)

### Cambios aplicados
- Se creo `lib/features/student_dashboard/services/student_session_navigation_service.dart` para centralizar el retorno desde juegos.
- El flujo de game-over ahora preserva el PIN infantil cacheado y vuelve a `studentDashboard` cuando existe contexto del nino.
- Si no hay PIN recordado, el retorno cae en `gamesCatalog`, que redirige al dashboard estudiante en la pestana `Mis Juegos` sin forzar cierre de sesion.
- La entrada manual por PIN (`child_pin_page.dart`) ahora guarda el PIN validado usando el mismo servicio compartido.
- Se reemplazaron navegaciones directas a `RouterPaths.studentDashboard` en los juegos legacy y en el dialogo compartido:
  - `math_adventure_bloc.dart`
  - `magic_words_bloc.dart`
  - `fun_english_bloc.dart`
  - `time_travel_page.dart`
  - `sports_challenge_page.dart`
  - `games/core/widgets/game_over_dialog.dart`

### Estado de calidad
- `fvm dart format` ejecutado sobre los archivos modificados.
- `fvm flutter analyze` ejecutado despues de los cambios: sin issues.

### Deuda pendiente recomendada
- Unificar tambien las pantallas de pausa/salida voluntaria de todos los juegos bajo `StudentSessionNavigationService`.
- Agregar widget tests para el flujo: PIN -> juego -> game-over -> retorno al dashboard del mismo nino.
- Definir una pantalla explicita para padres/adultos cuando un menor intenta continuar sin PIN ni perfil registrado, en vez de depender solo del fallback de registro.

## Fase 12 - Catalogo efectivo de juegos y desacoplamiento de ClassroomChallengesService (2026-08-10)

### Cambios aplicados
- Se creo `lib/features/games_catalog/models/catalog_game_registry_adapter.dart` para combinar el catalogo enriquecido existente con los juegos registrados en `GameRegistry`.
- `StudentGamesHubView` ahora consume `effectiveCatalogGames`, evitando que los juegos nuevos queden fuera de `Mis Juegos` cuando solo se registran como modulos del motor.
- Recomendaciones y secciones de practica tambien resuelven juegos contra `effectiveCatalogGames`.
- Se extrajo `ClassroomChallenge` a `lib/features/teacher_dashboard/domain/entities/classroom_challenge.dart`.
- Se creo el contrato `ClassroomChallengesRepository` en `domain/repositories`.
- Se creo `ClassroomChallengesDatasource` con implementacion Firestore en `data/datasources`.
- Se creo `FirestoreClassroomChallengesRepository` en `data/repositories`.
- `ClassroomChallengesService` quedo como fachada de compatibilidad y ya no accede directamente a Firestore.
- Se registraron `ClassroomChallengesDatasource` y `ClassroomChallengesRepository` en `get_it`.

### Estado de calidad
- `fvm dart format` ejecutado sobre los archivos modificados.
- `fvm flutter analyze` ejecutado despues de los cambios: sin issues.
- No hace falta `flutter clean` para que aparezcan los juegos; basta hot restart/recarga completa si el servidor web ya estaba levantado. `flutter analyze` resolvio dependencias durante la ejecucion.

### Deuda pendiente recomendada
- Mover `TeacherClassesService` a su propio datasource/repositorio para eliminar la dependencia estatica restante dentro de `FirestoreClassroomChallengesRepository`.
- Enriquecer `GameMetadata` con descripcion, nivel, etiqueta destacada y progreso inicial para eliminar duplicacion manual en `CatalogGame`.
- Revisar la UX de filtros de edad: si el nino tiene 12+ anos, juegos nuevos clasificados como 6-8 no se muestran hasta activar ese filtro.

## Fase 13 - Migracion completa de TeacherClassesService y cierre de fachadas docentes (2026-08-10)

### Cambios aplicados
- Se extrajeron entidades de dominio:
  - `lib/features/teacher_dashboard/domain/entities/teacher_class.dart`
  - `lib/features/teacher_dashboard/domain/entities/class_member.dart`
- Se creo el contrato `TeacherClassesRepository` en `domain/repositories`.
- Se creo `TeacherClassesDatasource` con implementacion `FirestoreTeacherClassesDatasource` en `data/datasources`.
- Se creo `FirestoreTeacherClassesRepository` en `data/repositories`.
- Se registraron `TeacherClassesDatasource` y `TeacherClassesRepository` en `get_it`.
- `FirestoreClassroomChallengesRepository` ahora depende de `TeacherClassesRepository` para consultar inscripciones, eliminando el acoplamiento estatico a `TeacherClassesService`.
- Se migraron consumidores a repositorios inyectados:
  - `teacher_dashboard_bloc.dart`
  - `student_dashboard_bloc.dart` para challenges
  - `mis_clases_panel.dart`
  - `browse_teachers_page.dart`
  - `join_class_page.dart`
- Se eliminaron las fachadas temporales:
  - `lib/features/teacher_dashboard/services/teacher_classes_service.dart`
  - `lib/features/teacher_dashboard/services/classroom_challenges_service.dart`
- Se removio acceso directo a `FirebaseAuth` en `browse_teachers_page.dart` y `join_class_page.dart`, usando `AuthRepository.getCurrentUser()`.
- Se agregaron a `.gitignore` los generados de iOS que aparecian como untracked:
  - `ios/Flutter/flutter_export_environment.sh`
  - `ios/Runner/GeneratedPluginRegistrant.h`
  - `ios/Runner/GeneratedPluginRegistrant.m`

### Estado de calidad
- `fvm dart format` ejecutado sobre los archivos modificados.
- `fvm flutter analyze` ejecutado despues de los cambios: sin issues.
- `rg "TeacherClassesService|ClassroomChallengesService" lib -n` ya no reporta consumidores; solo los archivos eliminados figuraban antes de borrar.
- Los generados de iOS ya no aparecen en `git status --short --untracked-files=all`.

### Accesos Firebase directos restantes detectados
- Vistas/widgets compartidos con auth directo: `email_verification_banner.dart`, `edu_play_nav_bar.dart`, `email_verification_gate_page.dart`, `teacher_dashboard_layout.dart`.
- Paginas con Firebase directo pendiente: `admin_dashboard_page.dart`, `teacher_registration_page.dart`, `session_entry_page.dart`, `student_dashboard_page.dart`, `onboarding_wizard.dart`, `login_layout.dart`.
- Servicios infra aceptables por ahora: datasources de parents, practice_session, settings, subscription, teacher_dashboard.
- `stripe_service.dart` sigue usando `FirebaseFunctions` directamente y debe migrarse a datasource/repositorio si se quiere cerrar subscription al 100%.

### Deuda pendiente recomendada
- Crear `EmailVerificationRepository` o ampliar `AuthRepository` para mover reload/send verification/signOut fuera de widgets compartidos y gates.
- Extraer `AdminDashboardRepository` para sacar Firestore de `admin_dashboard_page.dart`.
- Migrar `teacher_registration_page.dart` a datasource/repositorio de registro docente.
- Revisar si `StudentDashboardPage._ensureAnonymousAuth()` debe vivir en un `StudentSessionRepository` para completar el desacoplamiento de Auth en estudiante.
