# EduPlay — Project Context for Claude

EduPlay (`edu_play`) is a Flutter educational app for kids, with parent/teacher/admin
roles, ~15 mini-games, guest mode, subscriptions (Stripe), and a Firebase backend
(Auth, Firestore, Cloud Functions). Firebase project id: `eduplay-8792f`.

## Stack
- Flutter (SDK ^3.5.0), Provider + `get_it` for DI, `sqflite` for local storage.
- Firebase: `firebase_auth`, `cloud_firestore`, `cloud_functions`, `firebase_core`.
- Backend: `functions/` — Node Cloud Functions (`firebase-admin`, `firebase-functions`,
  `stripe`, `@sendgrid/mail`).
- Test dev deps: `fake_cloud_firestore` + `firebase_auth_mocks` (added this cycle) for
  testing Firebase-dependent widgets/services without hitting a real project — see
  `test/core/auth/auth_gate_test.dart` for the pattern. No `mockito`/`build_runner` yet.
- CI: `.github/workflows/firebase_hosting.yml` — on push/PR to main/master runs
  `flutter analyze --no-fatal-infos` + `flutter test --no-pub`; on push to main/master
  also builds web and deploys to Firebase Hosting. No Android/iOS CI build/test.

## Structure
- `lib/features/<feature>/{pages,bloc,models,services,widgets}` — one folder per
  feature/screen (~30 features: auth, login, register*, student_dashboard,
  parents_dashboard, teacher_dashboard, admin, subscription, games_catalog, and one
  folder per mini-game: math_adventure, magic_words, fun_english, nature_explorers,
  sports_challenge, time_travel, treasure_map, color_concert, artists_in_action,
  sticker_album, etc.)
- `lib/core`, `lib/data`, `lib/shared`, `lib/utils` — cross-cutting code
  (`injection_container.dart` wires DI via `get_it`).
- `functions/index.js` — 3 Cloud Functions: `createStripeCheckoutSession`,
  `stripeWebhook`, `onSessionComplete` (Firestore trigger).
- `firestore.rules`, `firestore.indexes.json` at repo root.
- `test/{models,services,utils}` — unit tests only, no widget/integration tests beyond
  a trivial smoke test.

## What's incomplete (last analyzed 2026-08-07)

**Fixed this cycle (v1-stabilization pass, all on `develop`, already committed):**
- Parent dashboard ("Inicio"/"Progreso") showed 0 points/0 games/no streak despite the
  child actually playing — root cause was reading from `practice_sessions` (kiosk/PIN
  flow only) instead of the real `students/{id}` + `students/{id}/scores` data the
  normal game flow writes. Fixed via new
  `lib/features/parents_dashboard/services/parent_child_stats_service.dart`
  (commit `565c193`).
- Parent session silently signed out on navigation (e.g. opening "Progreso") and
  reappeared "logged in" on returning to "Inicio" — `AuthGate._resolveRole` treated any
  Firestore error identically to "no role found" and called `signOut()`. Fixed with
  error/success separation, retry+backoff, and a positive-result role cache in
  `lib/core/auth/auth_gate.dart` (commit `959305d`).
- "Mamá" hardcoded default shown instead of the real parent name on Recursos/other
  parent tabs — fixed by loading the parent name asynchronously and threading it
  through parent nav bars (commit `388ca47`).
- `LocaleDataException` on first `DateFormat(..., 'es')` call — fixed by calling
  `initializeDateFormatting('es')` in `lib/main.dart` before `runApp`
  (bundled in `959305d`).
- Missing Firestore index for `scores.date` (COLLECTION scope) causing the query behind
  the fix above to silently return nothing — added and deployed to production
  (commit `b452f58`).
- `flutter analyze --no-fatal-infos` and `flutter test --no-pub` are both clean on
  `develop` as of this analysis.

**Unfinished features (functional gaps, not just polish):**
- Student dashboard **"Amigos" (Friends)** and **"Tienda" (Store)** tabs/sidebar items
  are gated off in `develop` via `ReleaseFlags.studentExtraTabsEnabled = false`
  (`lib/core/config/release_flags.dart`) — this is the mechanism that keeps
  in-development features out of the v1 build; the tabs render
  `PlaceholderSection` when the flag is on, but on `develop` they don't render at all
  (`lib/features/student_dashboard/pages/student_dashboard_layout.dart:335-338`). Real
  Friends/Store implementations live unmerged on `feature/friends-system` and
  `feature/store`. Same pattern for the teacher experience via
  `ReleaseFlags.teacherExperienceEnabled = false`.
- Analytics is a no-op stub: `lib/core/analytics/analytics_service.dart:27,41` has TODOs
  to wire up real Firebase Analytics. Not launch-blocking — routes/events already log to
  console in debug, no crash risk.
- `math_adventure` and `fun_english` accept a `userName` all the way down to their
  blocs (`MathAdventureBloc.userName`, `FunEnglishBloc.userName`), but neither layout
  ever renders it — confirmed no `Hola, {name}`-style greeting exists in either game's
  UI. `FunEnglishPage` even hardcodes `userName: 'Student'` when constructing its bloc.
  `magic_words` and `nature_explorers` don't have a `userName` field at all. **Net
  effect: no game currently shows the child's name, so this is dead/unused plumbing,
  not a user-visible bug** — nothing to fix unless a future design adds an in-game
  greeting, at which point `MenuProvider.username` (`lib/features/menu/bloc/menu_bloc.dart`)
  already holds the real name but its `onTap` handlers don't forward it via
  `Navigator.pushNamed(..., arguments: ...)` — that's the one gap to close if this
  feature is ever added.
- ~~`lib/data/repositories/mock_auth_repository.dart` dead code~~ — deleted; the
  commented-out import in `lib/utils/injection_container.dart` was removed too.
- The "Illustration placeholder" comment at
  `lib/features/register_parents/pages/register_parents_layout.dart:227` is misleading —
  it's actually a fully designed gradient/icon composition, not a missing asset. Not a
  real gap; the comment should just be reworded or removed.

**Test coverage is the biggest gap**, though two areas were seeded this cycle:
- `test/services/parent_child_stats_test.dart` — pure-logic coverage of
  `ChildGameplayStats`/`StudentRepository.levelForPoints`/`xpProgress`, i.e. the model
  behind the real-progress dashboard fix.
- `test/core/auth/auth_gate_test.dart` — covers `AuthGate._resolveRole`'s role
  lookup/caching directly, via a `@visibleForTesting resolveRoleForTest` wrapper, using
  `fake_cloud_firestore` + `firebase_auth_mocks` (added as dev dependencies this cycle).
  `AuthGate` itself was refactored to accept injectable `FirebaseAuth`/
  `FirebaseFirestore` (constructor params defaulting to `.instance`) to make this
  possible — `MyApp` now does `home: AuthGate()` (no longer `const`). Note: the
  "Firestore error propagates instead of being swallowed" behavior (the actual bug that
  was fixed) is *not* covered by an executable test — `fake_cloud_firestore`'s
  `mock_exceptions` integration is keyed by `DocumentReference` object identity, and
  `.collection(x).doc(id)` returns a fresh instance on every call, so a stub set on a
  test-held reference never fires for `AuthGate`'s own internal `.doc(uid).get()` call.
  Simulating that would need either `securityRules` on `FakeFirebaseFirestore` (untried)
  or refactoring `_resolveRole` to accept an injected `DocumentReference`. Verified by
  code inspection instead: `_resolveRole` has no try/catch, so exceptions always
  propagate to `FutureBuilder.hasError` by construction.

Still **zero tests** for: login/register flows, teacher_dashboard, parents_dashboard UI,
student_dashboard, child_portal, and every mini-game feature. Given the CI gate runs
`flutter test`, this is currently more a coverage gap than a CI risk, but any regression
in the untested areas would go undetected.

**Backend (`functions/`) looks complete for its current scope** — Stripe checkout +
webhook + post-payment Firestore update, no TODOs found. Worth double-checking whether
`@sendgrid/mail` (a listed dependency) is actually wired into any function, since it
isn't visibly used in the 3 exports.

**Stale doc**: `EDUPLAY_PROJECT_ANALYSIS.md` at repo root is an older audit and is
out of date — it claims no tests exist and no `firestore.rules` file exists; both are
now false. Treat it as historical, not current.

**Signal from git history**: `develop` is 9 commits ahead of `main` (`main` has nothing
`develop` doesn't), and the most recent commits are exactly the v1-stabilization fixes
listed above (real parent gameplay stats, auth-gate retry/cache, parent name loading,
Firestore index, locale init), preceded by a `chore` pass removing local desktop
platform folders and untracking `pubspec.lock`. `feature/friends-system`,
`feature/store`, `feature/test-coverage`, and `fix/child-pin-visibility` exist as
separate unmerged branches — none of that in-progress work leaks into `develop`. Given
analyze/test are clean and the four originally-reported live bugs are fixed and
committed, the two clearest remaining items before calling v1 "complete" are: (1) the
personalization/dead-code polish items above, and (2) adding test coverage for the
untested feature areas below — neither is currently a known crash/data-loss bug.

## Conventions
- `analysis_options.yaml`: standard `flutter_lints` plus `prefer_single_quotes`,
  `prefer_const_constructors`, `sort_constructors_first`; `avoid_print: false`.
- DI is centralized in `lib/utils/injection_container.dart` (get_it) — register new
  services/repositories there rather than instantiating inline.
- Config files (`firebase_options.dart`, `google-services.json`,
  `GoogleService-Info.plist`) are real, committed, generated FlutterFire config — not
  placeholders. `functions/.env.example` is a template; no real `.env` is committed.
