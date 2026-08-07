# EduPlay — Project Context for Claude

EduPlay (`edu_play`) is a Flutter educational app for kids, with parent/teacher/admin
roles, ~15 mini-games, guest mode, subscriptions (Stripe), and a Firebase backend
(Auth, Firestore, Cloud Functions). Firebase project id: `eduplay-8792f`.

## Stack
- Flutter (SDK ^3.5.0), Provider + `get_it` for DI, `sqflite` for local storage.
- Firebase: `firebase_auth`, `cloud_firestore`, `cloud_functions`, `firebase_core`.
- Backend: `functions/` — Node Cloud Functions (`firebase-admin`, `firebase-functions`,
  `stripe`, `@sendgrid/mail`).
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
- `test/{models,services,utils}` on `main`/`develop`/`feature/store` — unit tests only,
  no widget/integration tests beyond a trivial smoke test. `feature/friends-system` adds
  `test/data` and `test/widgets` too (see "Branch state" below).

## Branch state (last analyzed 2026-08-07)

`main`/`develop` only have the stabilization work through `a8f3589`. Two feature
branches built on top of that, in parallel, and **neither is merged yet**:

- **`feature/friends-system`** — cross-role **Amigos (Friends)** feature for students,
  parents and teachers (`cb92793`), plus a security/fragility follow-up
  (`bcc4007`), plus test coverage (`bbe4e21`, merged in via PR #1 `7fa9a4b`), plus
  two nav fixes (`96bcca7`, `33aaa5e`). Gated behind
  `ReleaseFlags.studentExtraTabsEnabled` (currently `false`).
- **`feature/store`** — **Tienda (Store)** feature: students spend their gamification
  `points` on avatar cosmetics and exclusive stickers (`91523a9`, `e01b189`), plus a
  repo-hygiene fix (`7dcd012`, see below). Gated behind `ReleaseFlags.storeEnabled`
  (currently `false`). Branched from `develop` before the friends-system test coverage
  landed, so it does **not** have those test files yet.

Both tabs used to render `PlaceholderSection`
(`lib/shared/widgets/placeholder_section.dart`) — that's no longer true on their
respective branches, but still true on `main`/`develop` until one of them merges.

**Fixed on `feature/friends-system` (`33aaa5e`)**: mini-games routing their "Inicio"
button through `RouterPaths.childPortal` with a full stack reset instead of a plain
`Navigator.pop(context)` — this caused an infinite back-navigation loop on
`ChildPortalPage` and made completed-game points look like they hadn't saved (they
had; only the return navigation was broken). Affected
`sports_challenge`, `time_travel`, `math_adventure`, `magic_words`, `fun_english`.

## What's incomplete

**Unfinished features (functional gaps, not just polish):**
- Analytics is a no-op stub: `lib/core/analytics/analytics_service.dart:27,41` has TODOs
  to wire up real Firebase Analytics.
- `lib/features/fun_english/pages/fun_english_page.dart:25` uses a hardcoded
  `userName: 'Student'` placeholder instead of the real logged-in user.
- Missing illustration asset noted at
  `lib/features/register_parents/pages/register_parents_layout.dart:202`.
- `lib/data/repositories/mock_auth_repository.dart` is dead code (only referenced via a
  commented-out import in `lib/utils/injection_container.dart:6`) — safe to delete or
  wire up/remove.

**Test coverage improved but is uneven across branches.** `main`/`develop`/`feature/store`
still only have the original 4 files (`test/models/child_profile_test.dart`,
`test/services/subscription_logic_test.dart`, `test/utils/router_paths_test.dart`,
`test/widget_test.dart`). `feature/friends-system` has 5 more on top of those
(`test/data/subject_catalog_test.dart`, `test/models/practice_session_test.dart`,
`test/models/teacher_class_test.dart`,
`test/services/student_repository_gamification_test.dart`,
`test/widgets/placeholder_section_test.dart`) — these will need re-adding/rebasing
wherever `feature/store` and `feature/friends-system` eventually merge, since they
diverged from a common ancestor before either landed. **Zero tests** still exist for:
auth/login/register flows, teacher_dashboard, parents_dashboard, student_dashboard,
child_portal, and every mini-game's UI (the new gamification-math/practice-session
tests cover logic, not widgets). Given the CI gate runs `flutter test`, this is
currently more a coverage gap than a CI risk, but any regression in auth, dashboards,
or game UI would go undetected.

**Backend (`functions/`) looks complete for its current scope** — Stripe checkout +
webhook + post-payment Firestore update, no TODOs found. Worth double-checking whether
`@sendgrid/mail` (a listed dependency) is actually wired into any function, since it
isn't visibly used in the 3 exports.

**Stale doc**: `EDUPLAY_PROJECT_ANALYSIS.md` at repo root is an older audit and is
out of date — it claims no tests exist and no `firestore.rules` file exists; both are
now false. Treat it as historical, not current.

**Repo hygiene**: `.gitignore` was fixed on `feature/store` (`7dcd012`) — it had ~10,000
duplicate lines (present on `main`/`develop` too, still unfixed there) and `windows/`,
`linux/`, `macos/` were tracked despite the project being web-only; both are now
untracked and ignored on `feature/store`. `feature/friends-system` independently fixed
the same platform-folder issue plus untracked `pubspec.lock` (`95a9fed`) —
`feature/store` has **not** untracked `pubspec.lock`, so that inconsistency needs
resolving when the branches merge.

## Conventions
- `analysis_options.yaml`: standard `flutter_lints` plus `prefer_single_quotes`,
  `prefer_const_constructors`, `sort_constructors_first`; `avoid_print: false`.
- DI is centralized in `lib/utils/injection_container.dart` (get_it) — register new
  services/repositories there rather than instantiating inline.
- Config files (`firebase_options.dart`, `google-services.json`,
  `GoogleService-Info.plist`) are real, committed, generated FlutterFire config — not
  placeholders. `functions/.env.example` is a template; no real `.env` is committed.
