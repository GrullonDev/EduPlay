import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Breakpoints
// ─────────────────────────────────────────────────────────────────────────────
//
//  xs  → < 480   (small phone)
//  sm  → 480–599 (phone)
//  md  → 600–899 (large phone / tablet portrait)
//  lg  → 900–1199 (tablet landscape / small desktop)
//  xl  → ≥ 1200  (desktop / wide screen)
//
//  Convenience aliases used throughout the app:
//    isMobile  → width < 600  (xs + sm)
//    isTablet  → 600 ≤ width < 900  (md)
//    isDesktop → width ≥ 900  (lg + xl)
// ─────────────────────────────────────────────────────────────────────────────

class AppBreakpoints {
  AppBreakpoints._();

  static const double xs = 480;
  static const double sm = 600;
  static const double md = 900;
  static const double lg = 1200;

  /// Maximum width of centred content columns.
  static const double maxContentWidth = 1280;

  /// Legacy alias used by the landing page.
  static const double landing = md;
}

// ─────────────────────────────────────────────────────────────────────────────
// Screen-size helpers
// ─────────────────────────────────────────────────────────────────────────────

class ScreenSize {
  const ScreenSize._(this.width);

  /// Build from the nearest [MediaQueryData].
  factory ScreenSize.of(BuildContext context) =>
      ScreenSize._(MediaQuery.of(context).size.width);

  /// Build from a [BoxConstraints] (use inside [LayoutBuilder]).
  factory ScreenSize.fromConstraints(BoxConstraints c) =>
      ScreenSize._(c.maxWidth);

  final double width;

  bool get isXs => width < AppBreakpoints.xs;
  bool get isMobile => width < AppBreakpoints.sm; // < 600
  bool get isTablet =>
      width >= AppBreakpoints.sm && width < AppBreakpoints.md; // 600–899
  bool get isDesktop => width >= AppBreakpoints.md; // ≥ 900
  bool get isWide => width >= AppBreakpoints.lg; // ≥ 1200

  /// Returns [mobile], [tablet], or [desktop] based on current width.
  T when<T>({required T mobile, required T tablet, required T desktop}) {
    if (isDesktop) return desktop;
    if (isTablet) return tablet;
    return mobile;
  }

  /// Like [when] but falls back: desktop → tablet → mobile.
  T whenOrElse<T>({T? desktop, T? tablet, required T mobile}) {
    if (isDesktop && desktop != null) return desktop;
    if ((isDesktop || isTablet) && tablet != null) return tablet;
    return mobile;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Responsive widget (LayoutBuilder-based, preferred over MediaQuery in trees)
// ─────────────────────────────────────────────────────────────────────────────

class Responsive extends StatelessWidget {
  const Responsive({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final s = ScreenSize.fromConstraints(constraints);
        if (s.isDesktop && desktop != null) return desktop!;
        if ((s.isDesktop || s.isTablet) && tablet != null) return tablet!;
        return mobile;
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Responsive padding helper
// ─────────────────────────────────────────────────────────────────────────────

EdgeInsets responsivePadding(
  ScreenSize s, {
  double mobile = 16,
  double tablet = 20,
  double desktop = 28,
}) {
  final h = s.when(mobile: mobile, tablet: tablet, desktop: desktop);
  return EdgeInsets.symmetric(horizontal: h, vertical: h);
}

EdgeInsets responsiveHPadding(
  ScreenSize s, {
  double mobile = 16,
  double tablet = 20,
  double desktop = 28,
}) {
  final h = s.when(mobile: mobile, tablet: tablet, desktop: desktop);
  return EdgeInsets.symmetric(horizontal: h);
}

// ─────────────────────────────────────────────────────────────────────────────
// Grid column count helper
// ─────────────────────────────────────────────────────────────────────────────

int gridCols(ScreenSize s, {int mobile = 1, int tablet = 2, int desktop = 3}) =>
    s.when(mobile: mobile, tablet: tablet, desktop: desktop);

// ─────────────────────────────────────────────────────────────────────────────
// Max-width centre wrapper
// ─────────────────────────────────────────────────────────────────────────────

class MaxWidthBox extends StatelessWidget {
  const MaxWidthBox({
    super.key,
    required this.child,
    this.maxWidth = AppBreakpoints.maxContentWidth,
    this.alignment = Alignment.topCenter,
  });

  final Widget child;
  final double maxWidth;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Font-size helper
// ─────────────────────────────────────────────────────────────────────────────

double responsiveFontSize(
  ScreenSize s, {
  required double mobile,
  double? tablet,
  required double desktop,
}) =>
    s.when(
      mobile: mobile,
      tablet: tablet ?? (mobile + desktop) / 2,
      desktop: desktop,
    );
