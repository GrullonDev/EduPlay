// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:google_fonts/google_fonts.dart';

// Project imports:
import 'package:edu_play/features/notifications/models/app_notification.dart';
import 'package:edu_play/features/notifications/services/notifications_service.dart';

const _kNavy = Color(0xFF1E1B6A);
const _kCoral = Color(0xFFFF6E6C);

class NotificationsButton extends StatelessWidget {
  const NotificationsButton({
    super.key,
    this.childId,
    this.iconColor,
    this.iconSize = 22,
    this.padding = const EdgeInsets.all(4),
  });

  final String? childId;
  final Color? iconColor;
  final double iconSize;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<AppNotification>>(
      stream: NotificationsService.watchMine(childId: childId),
      builder: (context, snapshot) {
        final notifications = snapshot.data ?? const <AppNotification>[];
        final unread = notifications.where((n) => !n.read).length;

        return InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showNotifications(context, notifications),
          child: Padding(
            padding: padding,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  Icons.notifications_outlined,
                  color: iconColor ?? Colors.grey.shade600,
                  size: iconSize,
                ),
                if (unread > 0)
                  Positioned(
                    top: -7,
                    right: -7,
                    child: Container(
                      constraints:
                          const BoxConstraints(minWidth: 16, minHeight: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: const BoxDecoration(
                        color: _kCoral,
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.all(Radius.circular(999)),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        unread > 9 ? '9+' : '$unread',
                        style: GoogleFonts.nunito(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showNotifications(
    BuildContext context,
    List<AppNotification> notifications,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Notificaciones',
                      style: GoogleFonts.fredoka(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: _kNavy,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: notifications.any((n) => !n.read)
                          ? () async {
                              await NotificationsService.markAllRead(
                                childId: childId,
                              );
                              if (context.mounted) Navigator.pop(context);
                            }
                          : null,
                      child: const Text('Marcar leidas'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (notifications.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: Text(
                        'No tienes notificaciones nuevas.',
                        style: GoogleFonts.nunito(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                else
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: notifications.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final notification = notifications[index];
                        return _NotificationTile(notification: notification);
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification});

  final AppNotification notification;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: notification.read
            ? Colors.grey.shade100
            : _kCoral.withValues(alpha: 0.12),
        child: Icon(
          switch (notification.type) {
            'friend_request' => Icons.person_add_alt_1_rounded,
            'teacher_message' => Icons.school_rounded,
            _ => Icons.notifications_rounded,
          },
          color: notification.read ? Colors.grey.shade500 : _kCoral,
        ),
      ),
      title: Text(
        notification.title,
        style: GoogleFonts.nunito(
          fontWeight: notification.read ? FontWeight.w600 : FontWeight.w800,
          color: _kNavy,
        ),
      ),
      subtitle: Text(
        notification.body,
        style: GoogleFonts.nunito(color: Colors.grey.shade600),
      ),
      trailing: notification.read
          ? null
          : IconButton(
              tooltip: 'Marcar leida',
              icon: const Icon(Icons.done_rounded),
              onPressed: () => NotificationsService.markRead(notification.id),
            ),
    );
  }
}
