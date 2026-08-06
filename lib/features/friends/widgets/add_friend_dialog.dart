import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:edu_play/features/friends/models/friend_identity.dart';
import 'package:edu_play/features/friends/services/friends_service.dart';

const _kNavy = Color(0xFF1E1B6A);
const _kCoral = Color(0xFFFF6E6C);

/// Dialog that shows the current user's shareable friend code and lets them
/// enter a friend's code to send a connection request.
class AddFriendDialog extends StatefulWidget {
  const AddFriendDialog({super.key, required this.identity});

  final FriendIdentity identity;

  @override
  State<AddFriendDialog> createState() => _AddFriendDialogState();
}

class _AddFriendDialogState extends State<AddFriendDialog> {
  final _codeCtrl = TextEditingController();
  String? _myCode;
  bool _loadingCode = true;
  bool _sending = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMyCode();
  }

  Future<void> _loadMyCode() async {
    try {
      final code = await FriendsService.getOrCreateMyCode(widget.identity);
      if (!mounted) return;
      setState(() {
        _myCode = code;
        _loadingCode = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'No se pudo generar tu código.';
        _loadingCode = false;
      });
    }
  }

  Future<void> _send() async {
    final code = _codeCtrl.text.trim();
    if (code.isEmpty) return;
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      await FriendsService.sendRequestByCode(
        me: widget.identity,
        code: code,
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _sending = false;
      });
    }
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Agregar amigo',
        style: GoogleFonts.fredoka(
          fontSize: 20,
          color: _kNavy,
          fontWeight: FontWeight.w700,
        ),
      ),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tu código',
              style: GoogleFonts.nunito(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F4FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _loadingCode
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            _myCode ?? '—',
                            style: GoogleFonts.fredoka(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 3,
                              color: _kNavy,
                            ),
                          ),
                  ),
                  if (_myCode != null)
                    IconButton(
                      icon: const Icon(Icons.copy_rounded, size: 18),
                      color: _kNavy,
                      tooltip: 'Copiar código',
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: _myCode!));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Código copiado.'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Comparte este código para que otros te agreguen.',
              style: GoogleFonts.nunito(fontSize: 11, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 20),
            Text(
              'Agregar con un código',
              style: GoogleFonts.nunito(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _codeCtrl,
              textCapitalization: TextCapitalization.characters,
              maxLength: 6,
              decoration: const InputDecoration(
                hintText: 'Ej. AB12CD',
                counterText: '',
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                _error!,
                style: GoogleFonts.nunito(fontSize: 12, color: Colors.red.shade700),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _sending ? null : () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _sending ? null : _send,
          style: ElevatedButton.styleFrom(
            backgroundColor: _kCoral,
            foregroundColor: Colors.white,
          ),
          child: _sending
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Enviar solicitud'),
        ),
      ],
    );
  }
}
