import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:edu_play/features/parents_dashboard/models/child_profile.dart';
import 'package:edu_play/features/parents_dashboard/services/child_profiles_service.dart';
import 'package:edu_play/features/practice_session/models/game_info.dart';
import 'package:edu_play/features/practice_session/models/practice_session.dart';
import 'package:edu_play/features/practice_session/services/practice_sessions_service.dart';
import 'package:edu_play/shared/widgets/edu_play_nav_bar.dart';
import 'package:edu_play/utils/routes/router_paths.dart';

// ── Constants ─────────────────────────────────────────────────────────────────

const _kNavy = Color(0xFF1E1B6A);
const _kNavyDark = Color(0xFF14125A);
const _kCoral = Color(0xFFFF6E6C);
const _kBg = Color(0xFFF8F7FF);
const _kLavender = Color(0xFFEEEDF8);

// ─────────────────────────────────────────────────────────────────────────────

class CreateSessionPage extends StatefulWidget {
  const CreateSessionPage({super.key});

  @override
  State<CreateSessionPage> createState() => _CreateSessionPageState();
}

class _CreateSessionPageState extends State<CreateSessionPage> {
  List<ChildProfile> _profiles = [];
  ChildProfile? _selectedProfile;
  final Set<String> _selectedGameIds = {};
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    final profiles = await ChildProfilesService.getProfiles();
    setState(() {
      _profiles = profiles;
      if (profiles.isNotEmpty) _selectedProfile = profiles.first;
    });
  }

  Future<void> _createSession() async {
    final profile = _selectedProfile;
    if (profile == null || _selectedGameIds.isEmpty) return;
    setState(() => _loading = true);
    try {
      final session = await PracticeSessionsService.createSession(
        childProfileId: profile.id,
        childName: profile.name,
        assignedGameIds: _selectedGameIds.toList(),
      );
      if (!mounted) return;
      _showSessionCreated(session);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showSessionCreated(PracticeSession session) {
    final url = session.sessionUrl(
      Uri.base.origin.isEmpty ? 'http://localhost:8080' : Uri.base.origin,
    );
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _SessionCreatedDialog(session: session, url: url),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width >= 900;
    return Scaffold(
      backgroundColor: _kBg,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: EduPlayNavBar.parent(
          activeParentTab: ParentTab.inicio,
          parentName: '',
        ),
      ),
      body: _profiles.isEmpty
          ? _emptyProfiles()
          : SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: wide ? 64 : 20,
                vertical: 32,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _header(),
                      const SizedBox(height: 32),
                      if (wide)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 2, child: _gamePickerCard()),
                            const SizedBox(width: 24),
                            Expanded(flex: 1, child: _sidePanel()),
                          ],
                        )
                      else ...[
                        _sidePanel(),
                        const SizedBox(height: 20),
                        _gamePickerCard(),
                      ],
                      const SizedBox(height: 32),
                      _createButton(),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _emptyProfiles() => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.person_add_alt_1_rounded,
                size: 64, color: Color(0xFFBBB9E0)),
            const SizedBox(height: 16),
            Text('No child profiles yet',
                style: GoogleFonts.fredoka(
                    fontSize: 22, color: _kNavy, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text('Create an explorer first in the dashboard',
                style: GoogleFonts.nunito(color: Colors.grey.shade600)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, RouterPaths.parentsDashboard),
              style: ElevatedButton.styleFrom(backgroundColor: _kCoral),
              child: Text('Go to Dashboard',
                  style: GoogleFonts.nunito(
                      color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      );

  Widget _header() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Start a Practice Session',
              style: GoogleFonts.fredoka(
                  fontSize: 30,
                  color: _kNavy,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5)),
          const SizedBox(height: 6),
          Text(
            'Pick a child and select the games you want them to practice. '
            'A shareable link and PIN will be generated.',
            style: GoogleFonts.nunito(fontSize: 15, color: Colors.grey.shade700),
          ),
        ],
      );

  // ── Side panel: child selector + session info ────────────────────────────

  Widget _sidePanel() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('Select Explorer'),
          const SizedBox(height: 10),
          ..._profiles.map((p) => _ProfileTile(
                profile: p,
                selected: _selectedProfile?.id == p.id,
                onTap: () => setState(() => _selectedProfile = p),
              )),
          const SizedBox(height: 20),
          _sectionLabel('Session Summary'),
          const SizedBox(height: 10),
          _SummaryCard(
            childName: _selectedProfile?.name ?? '—',
            selectedCount: _selectedGameIds.length,
          ),
        ],
      );

  // ── Game picker grid ─────────────────────────────────────────────────────

  Widget _gamePickerCard() => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: _kNavy.withOpacity(0.07),
                blurRadius: 12,
                offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              _sectionLabel('Choose Games'),
              const Spacer(),
              Text('${_selectedGameIds.length}/${kGameCatalog.length} selected',
                  style: GoogleFonts.nunito(
                      color: _kNavy,
                      fontWeight: FontWeight.w600,
                      fontSize: 13)),
            ]),
            const SizedBox(height: 4),
            Text('Select at least one game to continue',
                style: GoogleFonts.nunito(
                    fontSize: 12, color: Colors.grey.shade500)),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                mainAxisExtent: 90,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: kGameCatalog.length,
              itemBuilder: (_, i) {
                final game = kGameCatalog[i];
                final selected = _selectedGameIds.contains(game.id);
                return _GameTile(
                  game: game,
                  selected: selected,
                  onToggle: () => setState(() {
                    if (selected) {
                      _selectedGameIds.remove(game.id);
                    } else {
                      _selectedGameIds.add(game.id);
                    }
                  }),
                );
              },
            ),
          ],
        ),
      );

  Widget _createButton() => SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: (_selectedProfile != null && _selectedGameIds.isNotEmpty && !_loading)
              ? _createSession
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: _kCoral,
            disabledBackgroundColor: Colors.grey.shade300,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: _loading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : Text(
                  'Create Session & Get Link  →',
                  style: GoogleFonts.fredoka(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w600),
                ),
        ),
      );

  Widget _sectionLabel(String text) => Text(
        text.toUpperCase(),
        style: GoogleFonts.nunito(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: _kNavy.withOpacity(0.5),
          letterSpacing: 1.2,
        ),
      );
}

// ── Profile tile ─────────────────────────────────────────────────────────────

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.profile,
    required this.selected,
    required this.onTap,
  });

  final ChildProfile profile;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final avatarColor =
        Color(int.parse('FF${profile.avatarColorHex}', radix: 16));
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? _kNavy : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: selected ? _kNavy : const Color(0xFFE0DEFF), width: 2),
          boxShadow: selected
              ? [BoxShadow(color: _kNavy.withOpacity(0.2), blurRadius: 8)]
              : [],
        ),
        child: Row(children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: avatarColor,
            child: Text(
              profile.name[0].toUpperCase(),
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(profile.name,
                    style: GoogleFonts.fredoka(
                        fontSize: 15,
                        color: selected ? Colors.white : _kNavy,
                        fontWeight: FontWeight.w600)),
                Text('Grade ${profile.level}',
                    style: GoogleFonts.nunito(
                        fontSize: 11,
                        color: selected
                            ? Colors.white70
                            : Colors.grey.shade500)),
              ],
            ),
          ),
          if (selected)
            const Icon(Icons.check_circle_rounded,
                color: Colors.white, size: 18),
        ]),
      ),
    );
  }
}

// ── Summary card ─────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.childName,
    required this.selectedCount,
  });

  final String childName;
  final int selectedCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kLavender,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _row(Icons.person_rounded, 'Explorer', childName),
          const SizedBox(height: 8),
          _row(Icons.games_rounded, 'Games assigned', '$selectedCount'),
          const SizedBox(height: 8),
          _row(Icons.lock_rounded, 'Access', 'PIN-protected'),
        ],
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) => Row(
        children: [
          Icon(icon, size: 16, color: _kNavy.withOpacity(0.6)),
          const SizedBox(width: 8),
          Text(label,
              style: GoogleFonts.nunito(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600)),
          const Spacer(),
          Text(value,
              style: GoogleFonts.nunito(
                  fontSize: 12, color: _kNavy, fontWeight: FontWeight.w700)),
        ],
      );
}

// ── Game tile ─────────────────────────────────────────────────────────────────

class _GameTile extends StatelessWidget {
  const _GameTile({
    required this.game,
    required this.selected,
    required this.onToggle,
  });

  final GameInfo game;
  final bool selected;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? game.color.withOpacity(0.12) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? game.color : const Color(0xFFE8E8F0),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(game.emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                game.name,
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: selected ? game.color : const Color(0xFF333355),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (selected)
              Icon(Icons.check_circle_rounded, color: game.color, size: 16),
          ],
        ),
      ),
    );
  }
}

// ── Session Created Dialog ────────────────────────────────────────────────────

class _SessionCreatedDialog extends StatelessWidget {
  const _SessionCreatedDialog({
    required this.session,
    required this.url,
  });

  final PracticeSession session;
  final String url;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF27AE60).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle_rounded,
                        color: Color(0xFF27AE60), size: 18),
                    const SizedBox(width: 6),
                    Text('Session Created!',
                        style: GoogleFonts.fredoka(
                            color: const Color(0xFF27AE60),
                            fontSize: 14,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '${session.childName}\'s Practice',
                style: GoogleFonts.fredoka(
                    fontSize: 22, color: _kNavy, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                '${session.totalCount} game${session.totalCount == 1 ? '' : 's'} assigned',
                style: GoogleFonts.nunito(color: Colors.grey.shade600, fontSize: 14),
              ),

              const SizedBox(height: 24),

              // PIN display
              Text('SESSION PIN',
                  style: GoogleFonts.nunito(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: _kNavy.withOpacity(0.5),
                      letterSpacing: 1.2)),
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: session.pin
                    .split('')
                    .map((d) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: 44,
                          height: 52,
                          decoration: BoxDecoration(
                            color: _kNavy,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Text(d,
                              style: GoogleFonts.fredoka(
                                  fontSize: 26,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600)),
                        ))
                    .toList(),
              ),

              const SizedBox(height: 24),

              // QR Code
              Text('SCAN TO JOIN',
                  style: GoogleFonts.nunito(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: _kNavy.withOpacity(0.5),
                      letterSpacing: 1.2)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFE0DEFF), width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: QrImageView(
                  data: url,
                  version: QrVersions.auto,
                  size: 160,
                  backgroundColor: Colors.white,
                ),
              ),

              const SizedBox(height: 20),

              // URL copy row
              Text('OR SHARE LINK',
                  style: GoogleFonts.nunito(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: _kNavy.withOpacity(0.5),
                      letterSpacing: 1.2)),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: _kLavender,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 12, top: 10, bottom: 10),
                      child: Text(
                        url,
                        style: GoogleFonts.nunito(
                            fontSize: 12,
                            color: _kNavy,
                            fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy_rounded, size: 18),
                    color: _kCoral,
                    tooltip: 'Copy link',
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: url));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Link copied!',
                              style: GoogleFonts.nunito()),
                          backgroundColor: _kNavy,
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ]),
              ),

              const SizedBox(height: 28),

              Row(children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context)
                      ..pop()
                      ..pushReplacementNamed(RouterPaths.parentsDashboard),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFE0DEFF)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Dashboard',
                        style: GoogleFonts.nunito(
                            color: _kNavy, fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kCoral,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('New Session',
                        style: GoogleFonts.nunito(
                            color: Colors.white, fontWeight: FontWeight.w700)),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}
