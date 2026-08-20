# Claude Code Skills useful for EduPlay

These are built-in Claude Code skills (invoke with `/name`) worth using regularly on
this project, given its stack (Flutter + Firebase + Stripe Cloud Functions) and its
current gaps (see `CLAUDE.md`: weak test coverage, Stripe/webhook backend, auth flows).

- **`/code-review`** — Run before merging any PR that touches `lib/features/auth`,
  `lib/features/login`, `lib/features/register*`, `lib/features/subscription`, or
  `functions/`. Use effort `high` on payment/auth-adjacent diffs since those are the
  areas with zero test coverage today, so review is the main safety net. Also worth
  running on `lib/core/auth/auth_gate.dart` specifically — it's the single auth guard
  for the whole app (see `CLAUDE.md`'s "Fixed this cycle" note on the retry/cache logic
  added there), so regressions there are high-blast-radius.

- **`/security-review`** — Run on any change to `functions/index.js`
  (`stripeWebhook`, `createStripeCheckoutSession`), `firestore.rules`, or auth code.
  This project handles payments (Stripe) and child-user data, so webhook signature
  verification, Firestore rule changes, and PII handling deserve an explicit pass.

- **`/run`** — Use to launch the Flutter app (web, or an emulator/device) and actually
  see a change before reporting it done, per this project's UI-change policy. Useful
  for verifying the Friends/Store tabs once they move past `PlaceholderSection`.

- **`init`** (already used) — Re-run if the codebase structure changes significantly
  (e.g. a new top-level module), to regenerate baseline docs.

- **`simplify`** — Good fit for the post-feature-push cleanup phase this project is
  currently in (recent commits are all analyzer/lint fixes) — use after landing a
  feature to tidy the diff before it merges.

## Not particularly relevant here
- `dataviz` — no charting/dashboard visualization work in this codebase currently.
- `claude-api` — only relevant if EduPlay ever integrates an LLM feature directly;
  not applicable to the current games/subscription scope.

## Suggested but not yet configured
- No skill currently covers **Flutter widget/integration testing conventions** for
  this repo (e.g. how to test a bloc, how to fake Firebase in tests). Given test
  coverage is the single biggest gap (see `CLAUDE.md`), consider using
  `skill-creator` to author a project-specific skill once a testing pattern is
  established (e.g. "eduplay-bloc-test" covering how to mock `get_it` services and
  Firebase for `features/*/bloc` tests) — that would make future test-writing dramatically faster
  and consistent across the ~15 mini-game features that currently have zero tests.
