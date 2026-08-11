import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:edu_play/features/friends/models/friend_identity.dart';
import 'package:edu_play/features/friends/models/friend_request.dart';
import 'package:edu_play/features/friends/services/friends_service.dart';
import 'package:edu_play/features/friends/widgets/add_friend_dialog.dart';
import 'package:edu_play/features/friends/widgets/friend_avatar.dart';
import 'package:edu_play/utils/routes/router_paths.dart';

const _kNavy = Color(0xFF1E1B6A);
const _kCoral = Color(0xFFFF6E6C);
const _kBg = Color(0xFFF8F7FF);

/// Role-agnostic "Amigos" content: friend list, incoming requests, and the
/// entry point to add a new friend by code. Embedded in the student, parent
/// and teacher dashboards.
class FriendsView extends StatelessWidget {
  const FriendsView({
    super.key,
    required this.identity,
    this.title = 'Amigos',
    this.subtitle = 'Conecta con otros usuarios de EduPlay.',
  });

  final FriendIdentity? identity;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final me = identity;
    if (me == null) {
      return const _SignInGate();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.fredoka(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: _kNavy,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  final sent = await showDialog<bool>(
                    context: context,
                    builder: (_) => AddFriendDialog(identity: me),
                  );
                  if (sent == true && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Solicitud de amistad enviada.'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.person_add_alt_1_rounded, size: 16),
                label: Text(
                  'Agregar amigo',
                  style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kCoral,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _IncomingRequestsSection(identity: me),
          const SizedBox(height: 24),
          _FriendsListSection(identity: me),
        ],
      ),
    );
  }
}

class _SignInGate extends StatelessWidget {
  const _SignInGate();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.people_alt_rounded, size: 48, color: _kNavy),
            const SizedBox(height: 16),
            Text(
              'Inicia sesión para usar Amigos',
              style: GoogleFonts.fredoka(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _kNavy,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Necesitas una cuenta para conectar con otros usuarios de EduPlay.',
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(fontSize: 13, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pushNamed(RouterPaths.login),
              style: ElevatedButton.styleFrom(
                backgroundColor: _kNavy,
                foregroundColor: Colors.white,
              ),
              child: const Text('Iniciar sesión'),
            ),
          ],
        ),
      ),
    );
  }
}

class _IncomingRequestsSection extends StatelessWidget {
  const _IncomingRequestsSection({required this.identity});
  final FriendIdentity identity;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<FriendRequestModel>>(
      stream: FriendsService.watchIncomingRequests(identity),
      builder: (context, snapshot) {
        final requests = snapshot.data ?? const <FriendRequestModel>[];
        if (requests.isEmpty) return const SizedBox.shrink();

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE0DEFF)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Solicitudes pendientes (${requests.length})',
                style: GoogleFonts.fredoka(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _kNavy,
                ),
              ),
              const SizedBox(height: 12),
              ...requests.map((r) => _RequestRow(request: r, myKey: identity.key)),
            ],
          ),
        );
      },
    );
  }
}

class _RequestRow extends StatefulWidget {
  const _RequestRow({required this.request, required this.myKey});
  final FriendRequestModel request;
  final String myKey;

  @override
  State<_RequestRow> createState() => _RequestRowState();
}

class _RequestRowState extends State<_RequestRow> {
  bool _busy = false;

  Future<void> _respond(bool accept) async {
    setState(() => _busy = true);
    try {
      await FriendsService.respondToRequest(widget.request.id, accept: accept);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(accept
              ? 'No se pudo aceptar la solicitud. Intenta de nuevo.'
              : 'No se pudo rechazar la solicitud. Intenta de nuevo.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final other = widget.request.other(widget.myKey);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          FriendAvatar(name: other.name, radius: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  other.name,
                  style: GoogleFonts.nunito(fontWeight: FontWeight.w700, color: _kNavy),
                ),
                Text(
                  roleLabel(other.role),
                  style: GoogleFonts.nunito(fontSize: 11, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          if (_busy)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else ...[
            IconButton(
              icon: const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A)),
              tooltip: 'Aceptar',
              onPressed: () => _respond(true),
            ),
            IconButton(
              icon: Icon(Icons.cancel_rounded, color: Colors.red.shade400),
              tooltip: 'Rechazar',
              onPressed: () => _respond(false),
            ),
          ],
        ],
      ),
    );
  }
}

class _FriendsListSection extends StatelessWidget {
  const _FriendsListSection({required this.identity});
  final FriendIdentity identity;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<FriendRequestModel>>(
      stream: FriendsService.watchFriends(identity),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final friends = snapshot.data ?? const <FriendRequestModel>[];

        if (friends.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: _kBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Icon(Icons.people_outline_rounded, size: 40, color: _kNavy),
                const SizedBox(height: 12),
                Text(
                  'Aún no tienes amigos conectados.',
                  style: GoogleFonts.nunito(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 4),
                Text(
                  'Usa "Agregar amigo" y comparte tu código.',
                  style: GoogleFonts.nunito(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
          );
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 280,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 3.2,
          ),
          itemCount: friends.length,
          itemBuilder: (context, i) => _FriendTile(
            request: friends[i],
            myKey: identity.key,
          ),
        );
      },
    );
  }
}

class _FriendTile extends StatelessWidget {
  const _FriendTile({required this.request, required this.myKey});
  final FriendRequestModel request;
  final String myKey;

  @override
  Widget build(BuildContext context) {
    final other = request.other(myKey);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: _kNavy.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          FriendAvatar(name: other.name, radius: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  other.name,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.nunito(fontWeight: FontWeight.w700, color: _kNavy),
                ),
                Text(
                  roleLabel(other.role),
                  style: GoogleFonts.nunito(fontSize: 11, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.person_remove_rounded, size: 18, color: Colors.grey.shade400),
            tooltip: 'Eliminar amigo',
            onPressed: () => _confirmRemove(context),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmRemove(BuildContext context) async {
    final other = request.other(myKey);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar amigo'),
        content: Text('¿Eliminar a ${other.name} de tus amigos?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade600),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await FriendsService.removeRequest(request.id);
    }
  }
}

/// Convenience helper to build a [FriendIdentity] for the parent role from
/// the currently signed-in Firebase user.
FriendIdentity? parentIdentity(String parentName) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return null;
  return FriendIdentity(uid: user.uid, role: 'parent', name: parentName);
}

/// Convenience helper to build a [FriendIdentity] for the teacher role.
FriendIdentity? teacherIdentity(String teacherName) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return null;
  return FriendIdentity(uid: user.uid, role: 'teacher', name: teacherName);
}

/// Convenience helper to build a [FriendIdentity] for a student, scoped to
/// the currently signed-in parent account and (optionally) a child profile.
FriendIdentity? studentIdentity({
  required String displayName,
  String? childId,
}) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return null;
  return FriendIdentity(
    uid: user.uid,
    childId: childId,
    role: 'student',
    name: displayName,
  );
}
