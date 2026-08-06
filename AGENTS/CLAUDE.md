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
- `test/{models,services,utils}` — unit tests only, no widget/integration tests beyond
  a trivial smoke test.

## What's incomplete (last analyzed 2026-08-06)

**Unfinished features (functional gaps, not just polish):**
- Student dashboard **"Amigos" (Friends)** and **"Tienda" (Store)** tabs render
  `PlaceholderSection` (`lib/shared/widgets/placeholder_section.dart`) — UI-scaffolded,
  no real functionality. See `lib/features/student_dashboard/pages/student_dashboard_layout.dart:47,53`.
- Analytics is a no-op stub: `lib/core/analytics/analytics_service.dart:27,41` has TODOs
  to wire up real Firebase Analytics.
- `lib/features/fun_english/pages/fun_english_page.dart:25` uses a hardcoded
  `userName: 'Student'` placeholder instead of the real logged-in user.
- Missing illustration asset noted at
  `lib/features/register_parents/pages/register_parents_layout.dart:202`.
- `lib/data/repositories/mock_auth_repository.dart` is dead code (only referenced via a
  commented-out import in `lib/utils/injection_container.dart:6`) — safe to delete or
  wire up/remove.

**Test coverage is the biggest gap.** Only 4 real test files exist:
`test/models/child_profile_test.dart`, `test/services/subscription_logic_test.dart`,
`test/utils/router_paths_test.dart`, and a trivial `test/widget_test.dart`. **Zero
tests** exist for: auth/login/register flows, teacher_dashboard, parents_dashboard,
student_dashboard, child_portal, and every single mini-game feature. Given the CI gate
runs `flutter test`, this is currently more a coverage gap than a CI risk, but any
regression in auth, dashboards, or games would go undetected.

**Backend (`functions/`) looks complete for its current scope** — Stripe checkout +
webhook + post-payment Firestore update, no TODOs found. Worth double-checking whether
`@sendgrid/mail` (a listed dependency) is actually wired into any function, since it
isn't visibly used in the 3 exports.

**Stale doc**: `EDUPLAY_PROJECT_ANALYSIS.md` at repo root is an older audit and is
out of date — it claims no tests exist and no `firestore.rules` file exists; both are
now false. Treat it as historical, not current.

**Signal from git history**: the last 3 commits before this analysis were pure
stabilization (`fix: resolve teacher dashboard analyzer issues`,
`fix: clean async guards and analyzer warnings`, `chore: fix analyzer config and web
dependency`), after a long run of feature commits (auth, subscription/Stripe, teacher
dashboard, admin, onboarding, guest flow, parent-guide, legal pages). The project is in
a post-feature-push stabilization phase — the two clearest remaining blockers to calling
it "complete" are: (1) building out Friends/Store, and (2) adding test coverage for the
untested feature areas above.

## Conventions
- `analysis_options.yaml`: standard `flutter_lints` plus `prefer_single_quotes`,
  `prefer_const_constructors`, `sort_constructors_first`; `avoid_print: false`.
- DI is centralized in `lib/utils/injection_container.dart` (get_it) — register new
  services/repositories there rather than instantiating inline.
- Config files (`firebase_options.dart`, `google-services.json`,
  `GoogleService-Info.plist`) are real, committed, generated FlutterFire config — not
  placeholders. `functions/.env.example` is a template; no real `.env` is committed.
