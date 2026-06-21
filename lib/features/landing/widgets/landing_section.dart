import 'package:flutter/material.dart';
import 'package:edu_play/utils/responsive.dart';

/// Breakpoint above which the landing page switches to its desktop layout.
/// Kept for backward compatibility — prefer [AppBreakpoints.md].
const double kLandingDesktopBreakpoint = AppBreakpoints.md;

/// Maximum width of the centered content inside each landing section.
const double kLandingMaxContentWidth = 1180;

/// Whether the current layout should use the desktop (wide) variant.
bool isLandingDesktop(BuildContext context) => ScreenSize.of(context).isDesktop;

/// Centers [child] within a max-width column and applies consistent
/// horizontal/vertical padding that adapts to screen size.
class LandingSection extends StatelessWidget {
  const LandingSection({
    super.key,
    required this.child,
    this.color,
    this.padding,
  });

  final Widget child;
  final Color? color;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final desktop = isLandingDesktop(context);
    return Container(
      width: double.infinity,
      color: color,
      padding: padding ??
          EdgeInsets.symmetric(
            horizontal: desktop ? 64 : 20,
            vertical: desktop ? 80 : 48,
          ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: kLandingMaxContentWidth),
          child: child,
        ),
      ),
    );
  }
}
