// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:google_fonts/google_fonts.dart';

const _kNavy = Color(0xFF1E1B6A);
const _kGold = Color(0xFFF39C12);

/// Hosts the Recurrente checkout page in an in-app webview and watches
/// `orders/{orderId}` for the PAID transition written by the
/// `recurrenteWebhook` Cloud Function.
///
/// Pops `true` once the order is confirmed PAID, or `false` if the user
/// cancels (AppBar close button, or the webview navigates to a URL
/// containing [cancelUrlFragment]).
class RecurrenteCheckoutScreen extends StatefulWidget {
  const RecurrenteCheckoutScreen({
    super.key,
    required this.checkoutUrl,
    required this.orderId,
    this.cancelUrlFragment = '/cancelled',
  });

  final String checkoutUrl;
  final String orderId;
  final String cancelUrlFragment;

  @override
  State<RecurrenteCheckoutScreen> createState() =>
      _RecurrenteCheckoutScreenState();
}

class _RecurrenteCheckoutScreenState extends State<RecurrenteCheckoutScreen> {
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
      _orderSubscription;
  bool _closed = false;
  bool _pageLoaded = false;
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    _orderSubscription = FirebaseFirestore.instance
        .collection('orders')
        .doc(widget.orderId)
        .snapshots()
        .listen(_onOrderSnapshot);
  }

  void _onOrderSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final status = snapshot.data()?['status'] as String?;
    if (status == 'PAID') {
      _close(true);
    }
  }

  void _close(bool paid) {
    if (_closed || !mounted) return;
    _closed = true;
    Navigator.of(context).pop(paid);
  }

  @override
  void dispose() {
    _orderSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _close(false);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: _kNavy,
          foregroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () => _close(false),
          ),
          title: Text(
            'Completar pago',
            style: GoogleFonts.fredoka(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(28),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_rounded,
                      size: 13, color: Colors.white.withValues(alpha: 0.75)),
                  const SizedBox(width: 6),
                  Text(
                    'Conexión segura · Recurrente',
                    style: GoogleFonts.nunito(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withValues(alpha: 0.75),
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: Stack(
          children: [
            InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri(widget.checkoutUrl)),
              onProgressChanged: (controller, progress) {
                if (!mounted) return;
                setState(() => _progress = progress / 100);
              },
              onLoadStop: (controller, url) {
                if (!mounted) return;
                setState(() => _pageLoaded = true);
              },
              shouldOverrideUrlLoading: (controller, navigationAction) async {
                final url = navigationAction.request.url?.toString() ?? '';
                if (url.contains(widget.cancelUrlFragment)) {
                  _close(false);
                  return NavigationActionPolicy.CANCEL;
                }
                return NavigationActionPolicy.ALLOW;
              },
            ),
            if (!_pageLoaded)
              Positioned.fill(
                child: Container(
                  color: Colors.white,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 36,
                          height: 36,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(_kNavy),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Cargando pasarela de pago…',
                          style: GoogleFonts.nunito(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            if (_pageLoaded && _progress < 1)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: LinearProgressIndicator(
                  value: _progress,
                  minHeight: 2.5,
                  backgroundColor: Colors.transparent,
                  valueColor: const AlwaysStoppedAnimation<Color>(_kGold),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
