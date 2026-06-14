import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:edu_play/features/landing/widgets/landing_section.dart';
import 'package:edu_play/utils/app_theme.dart';

/// A single entry in a [DashboardShell]'s side navigation.
class DashboardNavItem {
  const DashboardNavItem({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

/// Shared layout for the student and teacher dashboards: a fixed sidebar on
/// desktop (logo, navigation, footer) that collapses into a [Drawer] with a
/// top [AppBar] on smaller screens.
class DashboardShell extends StatelessWidget {
  const DashboardShell({
    super.key,
    required this.title,
    required this.items,
    required this.selectedIndex,
    required this.onSelect,
    required this.body,
    this.accentColor = AppTheme.primaryColor,
    this.headerSubtitle,
    this.footer,
  });

  final String title;
  final List<DashboardNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final Widget body;
  final Color accentColor;
  final String? headerSubtitle;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final desktop = isLandingDesktop(context);

    if (desktop) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: Row(
          children: [
            _Sidebar(
              title: title,
              subtitle: headerSubtitle,
              items: items,
              selectedIndex: selectedIndex,
              onSelect: onSelect,
              accentColor: accentColor,
              footer: footer,
            ),
            Expanded(
              child: SafeArea(
                left: false,
                child: body,
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          items[selectedIndex].label,
          style: GoogleFonts.fredoka(fontWeight: FontWeight.w700),
        ),
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
      ),
      drawer: Drawer(
        child: _Sidebar(
          title: title,
          subtitle: headerSubtitle,
          items: items,
          selectedIndex: selectedIndex,
          onSelect: (index) {
            Navigator.of(context).pop();
            onSelect(index);
          },
          accentColor: accentColor,
          footer: footer,
        ),
      ),
      body: SafeArea(child: body),
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.title,
    required this.subtitle,
    required this.items,
    required this.selectedIndex,
    required this.onSelect,
    required this.accentColor,
    required this.footer,
  });

  final String title;
  final String? subtitle;
  final List<DashboardNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final Color accentColor;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      color: Colors.white,
      child: SafeArea(
        right: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(Icons.school_rounded, color: accentColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.fredoka(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            color: AppTheme.textColor,
                          ),
                        ),
                        if (subtitle != null)
                          Text(
                            subtitle!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.nunito(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            for (var i = 0; i < items.length; i++)
              _NavTile(
                item: items[i],
                selected: i == selectedIndex,
                accentColor: accentColor,
                onTap: () => onSelect(i),
              ),
            const Spacer(),
            if (footer != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: footer!,
              ),
          ],
        ),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.item,
    required this.selected,
    required this.accentColor,
    required this.onTap,
  });

  final DashboardNavItem item;
  final bool selected;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color:
            selected ? accentColor.withValues(alpha: 0.12) : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(
                  item.icon,
                  size: 22,
                  color: selected ? accentColor : Colors.grey[600],
                ),
                const SizedBox(width: 14),
                Text(
                  item.label,
                  style: GoogleFonts.nunito(
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                    color: selected ? accentColor : Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
