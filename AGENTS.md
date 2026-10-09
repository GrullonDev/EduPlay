# AGENTS.md

Instrucciones para agentes que trabajan en este repositorio. Consultar README y configuración para el detalle; este archivo no autoriza publicación ni cambios fuera de la tarea.

## Propósito del proyecto

Plataforma educativa con minijuegos, cuentas de estudiantes/padres/docentes, progreso, paneles y tienda/suscripciones. El alcance visible se controla con ReleaseFlags; no dar por habilitada una experiencia porque tenga carpeta.

## Stack y plataformas

Provider/ChangeNotifier, GetIt, Firebase Auth/Firestore/Cloud Functions, sqflite_common_ffi, SharedPreferences y audio. Functions declara Node 20, firebase-admin/functions, Stripe y SendGrid; Flutter también contiene módulo Recurrente.

Requisito Dart declarado: `^3.5.0` en `pubspec.yaml`; los rangos de dependencias no prueban la versión resuelta. SDK mediante FVM: `stable` según `.fvmrc` (canal móvil, no versión fija).

Proyectos de plataforma presentes: android, ios, web. Esto no garantiza que todos los plugins funcionen en cada plataforma.

## Estructura del repositorio

`lib/features/` organiza juegos y roles con pages/bloc/services y, en módulos recientes, data/domain. `lib/core/` contiene auth/configuración compartida; `lib/data/` repositorios históricos; `lib/utils/injection_container.dart` registra DI. `functions/` contiene backend; `test/firestore-rules/` pruebas de reglas.

## Preparación y comandos

Requisitos: FVM y SDK de `.fvmrc`; ejecutar `fvm install` sin modificar el pin. Android necesita su toolchain/JDK de Gradle; iOS requiere macOS/Xcode y la gestión de dependencias del proyecto. Integraciones Firebase requieren configuración de desarrollo existente.

| Acción | Comando desde la raíz |
| --- | --- |
| Dependencias | `fvm flutter pub get` |
| Ejecutar | `fvm flutter run -d <dispositivo>` |
| Formato | `fvm dart format lib test` |
| Análisis | `fvm flutter analyze` |
| Pruebas | `fvm flutter test` |
| Build Android de comprobación | `fvm flutter build apk --debug` |

`fvm flutter gen-l10n` para ARB; `fvm flutter build web --release --no-tree-shake-icons` reproduce build CI. En `functions/`: `npm install`, `npm run lint`; `npm run build` está declarado pero requiere confirmar toolchain. Leer también `AGENTS/SKILLS.md` sin asumir herramientas exclusivas de Claude disponibles.

Los comandos fueron contrastados con dependencias, documentación/configuración y suites presentes; no ejecutados al redactar este archivo. Build de distribución requiere firma/configuración adicional; no sustituye despliegue.

## Arquitectura y convenciones

Los nombres Bloc no justifican introducir flutter_bloc: continuar Provider/ChangeNotifier y patrones del módulo. Acceso remoto mediante datasources/repositorios registrados en GetIt. Revisar AuthGate, permisos de rol y ReleaseFlags antes de cambiar navegación. Mantener la integración externa de recursos/RSS; no crear un CMS ni migración incidental. No asumir que el nombre de un rol garantiza autorización en servidor.

Conservar nombres y convenciones del módulo: Dart snake_case para archivos, UpperCamelCase para tipos y lowerCamelCase para miembros. No renombrar APIs/campos persistidos incidentalmente; respetar lints de analysis_options.yaml.

## Experiencia de usuario

Mantener estados claros de carga/vacío/error, recuperación de sesión y progreso del juego. Verificar ES/EN, sonido opcional, objetivos comprensibles y pantallas móviles/web. Flujos de pagos deben distinguir pendiente, confirmado y fallido; no conceder acceso por retorno del navegador únicamente.

En el flujo afectado, contemplar carga, vacío, éxito y error; dar feedback claro, conservar entradas/datos ante fallos y permitir recuperación. Reutilizar componentes visuales; revisar semántica, foco, contraste y escalado de texto.

## Seguridad y datos

No incluir secretos, credenciales ni datos personales en código, documentación o logs. Usar configuración de entorno existente, validar entradas y manejar fallos de servicios. Respetar autenticación, autorización y permisos. No ejecutar operaciones destructivas sobre datos sin autorización explícita.

Minimizar datos de menores y preservar acceso por familia/clase/rol en reglas backend. Secretos de pagos/correo solo en servidor. Validar firmas y repetición de webhooks; probar pagos en sandbox, nunca cobrar como prueba. No habilitar flags de experiencias incompletas sin tarea explícita.

## Pruebas y validación

Usar fake_cloud_firestore/firebase_auth_mocks. CI valida analyze y tests antes de build web. Para reglas: en `test/firestore-rules/`, `npm install` y `npm test` con Firebase CLI y Java/emulador. Probar auth por rol, recuperación, sesión educativa, progreso y checkout según cambio.

Ejecutar análisis y pruebas relevantes según el cambio; compilar solo plataformas afectadas. Un cambio exclusivamente documental requiere revisar rutas, comandos, alcance y diff, sin pruebas artificiales que repliquen el texto. No afirmar que una prueba pasó si no se ejecutó.

## Flujo de trabajo del agente

Leer también `AGENTS/CLAUDE.md`; conservar sus reglas válidas. Sus cifras/pendientes históricos se contrastan con código/configuración vigente. Leer instrucciones aplicables antes de modificar archivos, incluidas las de subdirectorios: su alcance local se respeta. Las instrucciones explícitas del usuario prevalecen.

1. Revisar estado del trabajo y comprender el flujo afectado antes de implementar.
2. Hacer cambios acotados al objetivo; respetar cambios existentes del usuario y evitar refactorizaciones ajenas.
3. Reutilizar componentes y dependencias disponibles; justificar dependencias nuevas.
4. Actualizar documentación si cambia comportamiento o configuración.
5. Ejecutar verificaciones pertinentes y comunicar resultados y pendientes con su motivo.
6. No hacer commits, push o despliegues salvo solicitud o autorización previa del usuario. Esta regla prevalece sobre recomendaciones de commit automático en guías antiguas.

No imponer una política nueva de ramas/commits; seguir documentación y CI existentes.

No activar workflows de publicación ni scripts de release como comprobación rutinaria.

## Criterios de finalización

La tarea cumple el comportamiento solicitado, contempla errores/estados relevantes, mantiene convenciones y pasa las verificaciones aplicables que puedan ejecutarse. Comunicar archivos modificados, resultados reales y cualquier validación pendiente con su motivo.

## Limitaciones y aspectos por confirmar

FVM usa `stable`. `functions/package.json` declara build=tsc pero no declara TypeScript entre dependencias: no afirmar que `npm run build` funciona. La coexistencia de Stripe/Recurrente exige confirmar el flujo activo antes de modificar pagos. Las guías históricas contienen estados que deben contrastarse con código.
