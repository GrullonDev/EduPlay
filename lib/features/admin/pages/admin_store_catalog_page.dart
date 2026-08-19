// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

// Project imports:
import 'package:edu_play/features/store/domain/repositories/store_catalog_repository.dart';
import 'package:edu_play/features/store/models/store_item.dart';
import 'package:edu_play/features/store/services/store_catalog_cache.dart';
import 'package:edu_play/utils/injection_container.dart';

const _kNavy = Color(0xFF1E1B6A);
const _kCoral = Color(0xFFFF6E6C);
const _kBg = Color(0xFFF8F7FF);

/// Lets an admin edit the Tienda catalog stored in Firestore
/// (`storeCatalog/{itemId}`) without an app release — price, PRO gating,
/// level requirement, featured flag, and a seasonal availability window.
/// Adding brand-new items (new icon/color) isn't supported here yet — only
/// editing/removing the existing catalog — since that needs an icon/color
/// picker that's out of scope for this first pass.
class AdminStoreCatalogPage extends StatefulWidget {
  const AdminStoreCatalogPage({super.key});

  @override
  State<AdminStoreCatalogPage> createState() => _AdminStoreCatalogPageState();
}

class _AdminStoreCatalogPageState extends State<AdminStoreCatalogPage> {
  final StoreCatalogRepository _repository = sl<StoreCatalogRepository>();
  final StoreCatalogCache _cache = sl<StoreCatalogCache>();

  List<StoreItem> _items = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await _repository.getCatalog();
      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'No se pudo cargar el catálogo. Revisa tu conexión e '
            'inténtalo de nuevo.';
        _loading = false;
      });
    }
  }

  Future<void> _save(StoreItem item) async {
    try {
      await _repository.upsertItem(item);
      await _cache.refresh();
      await _load();
    } catch (e) {
      _showSaveError();
    }
  }

  Future<void> _delete(StoreItem item) async {
    try {
      await _repository.deleteItem(item.id);
      await _cache.refresh();
      await _load();
    } catch (e) {
      _showSaveError();
    }
  }

  Future<void> _restoreDefaults() async {
    try {
      for (final item in allStoreItems) {
        await _repository.upsertItem(item);
      }
      await _cache.refresh();
      await _load();
    } catch (e) {
      _showSaveError();
    }
  }

  void _showSaveError() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'No se pudo guardar el cambio. Revisa tu conexión o tus '
          'permisos de administrador e inténtalo de nuevo.',
        ),
        backgroundColor: _kCoral,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kNavy,
        foregroundColor: Colors.white,
        title: Text(
          'Catálogo de la Tienda',
          style: GoogleFonts.fredoka(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Actualizar',
            onPressed: _load,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _kNavy))
          : _error != null
              ? _CatalogErrorState(message: _error!, onRetry: _load)
              : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${_items.length} artículos en el catálogo. Los cambios se reflejan en la Tienda al instante.',
                          style: GoogleFonts.nunito(fontSize: 13, color: Colors.grey[600]),
                        ),
                      ),
                      TextButton(
                        onPressed: _restoreDefaults,
                        child: const Text('Restaurar valores por defecto'),
                      ),
                    ],
                  ),
                ),
                for (final item in _items) _CatalogTile(item: item, onSave: _save, onDelete: _delete),
              ],
            ),
    );
  }
}

class _CatalogErrorState extends StatelessWidget {
  const _CatalogErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 40, color: _kCoral),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(fontSize: 14, color: Colors.grey[700]),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(backgroundColor: _kNavy),
              child: const Text('Reintentar', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

class _CatalogTile extends StatelessWidget {
  const _CatalogTile({required this.item, required this.onSave, required this.onDelete});
  final StoreItem item;
  final ValueChanged<StoreItem> onSave;
  final ValueChanged<StoreItem> onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      item.name,
                      style: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                    if (item.isProOnly) ...[
                      const SizedBox(width: 6),
                      const _Chip(text: 'PRO', color: Color(0xFFD97706)),
                    ],
                    if (item.isFeatured) ...[
                      const SizedBox(width: 6),
                      const _Chip(text: 'Destacado', color: _kCoral),
                    ],
                    if (item.isSeasonal) ...[
                      const SizedBox(width: 6),
                      const _Chip(text: 'Temporada', color: Color(0xFF16A34A)),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${item.category.name} · ${item.cost} pts · nivel ${item.minLevel}+',
                  style: GoogleFonts.nunito(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_rounded, color: _kNavy, size: 20),
            onPressed: () => _openEditDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: _kCoral, size: 20),
            onPressed: () => onDelete(item),
          ),
        ],
      ),
    );
  }

  Future<void> _openEditDialog(BuildContext context) async {
    final updated = await showDialog<StoreItem>(
      context: context,
      builder: (_) => _EditItemDialog(item: item),
    );
    if (updated != null) onSave(updated);
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.text, required this.color});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: color)),
    );
  }
}

class _EditItemDialog extends StatefulWidget {
  const _EditItemDialog({required this.item});
  final StoreItem item;

  @override
  State<_EditItemDialog> createState() => _EditItemDialogState();
}

class _EditItemDialogState extends State<_EditItemDialog> {
  late final TextEditingController _nameCtrl =
      TextEditingController(text: widget.item.name);
  late final TextEditingController _costCtrl =
      TextEditingController(text: widget.item.cost.toString());
  late final TextEditingController _levelCtrl =
      TextEditingController(text: widget.item.minLevel.toString());
  late bool _isProOnly = widget.item.isProOnly;
  late bool _isFeatured = widget.item.isFeatured;
  late bool _isSeasonal = widget.item.isSeasonal;
  late DateTime? _availableFrom = widget.item.availableFrom;
  late DateTime? _availableUntil = widget.item.availableUntil;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _costCtrl.dispose();
    _levelCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _availableFrom = picked;
      } else {
        _availableUntil = picked;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Editar artículo', style: GoogleFonts.fredoka(color: _kNavy, fontSize: 18)),
      content: SizedBox(
        width: 360,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _costCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Costo (pts)'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _levelCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Nivel mínimo'),
                    ),
                  ),
                ],
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Solo PRO'),
                value: _isProOnly,
                onChanged: (v) => setState(() => _isProOnly = v),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Destacado'),
                value: _isFeatured,
                onChanged: (v) => setState(() => _isFeatured = v),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Disponibilidad por temporada'),
                value: _isSeasonal,
                onChanged: (v) => setState(() {
                  _isSeasonal = v;
                  if (!v) {
                    _availableFrom = null;
                    _availableUntil = null;
                  }
                }),
              ),
              if (_isSeasonal) ...[
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => _pickDate(isStart: true),
                        child: Text(_availableFrom == null
                            ? 'Desde…'
                            : DateFormat('d MMM yyyy').format(_availableFrom!)),
                      ),
                    ),
                    Expanded(
                      child: TextButton(
                        onPressed: () => _pickDate(isStart: false),
                        child: Text(_availableUntil == null
                            ? 'Hasta…'
                            : DateFormat('d MMM yyyy').format(_availableUntil!)),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: _kNavy),
          onPressed: () {
            final updated = StoreItem(
              id: widget.item.id,
              name: _nameCtrl.text.trim().isEmpty ? widget.item.name : _nameCtrl.text.trim(),
              category: widget.item.category,
              cost: int.tryParse(_costCtrl.text) ?? widget.item.cost,
              color: widget.item.color,
              iconKey: widget.item.iconKey,
              isProOnly: _isProOnly,
              minLevel: int.tryParse(_levelCtrl.text) ?? widget.item.minLevel,
              isFeatured: _isFeatured,
              availableFrom: _isSeasonal ? _availableFrom : null,
              availableUntil: _isSeasonal ? _availableUntil : null,
            );
            Navigator.pop(context, updated);
          },
          child: const Text('Guardar', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
