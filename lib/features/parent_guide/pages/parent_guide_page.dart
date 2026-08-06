import 'package:edu_play/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:edu_play/shared/widgets/edu_play_nav_bar.dart';

const _kNavy = Color(0xFF1E1B6A);
const _kRed = Color(0xFFC0392B);
const _kLavender = Color(0xFFEEEDF8);
const _kBg = Color(0xFFF8F7FF);

// ── Resource data model ───────────────────────────────────────────────────────

enum _ResourceType { article, video, pdf, worksheet }

class _Resource {
  const _Resource({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.icon,
    required this.subject,
    this.color = _kNavy,
    this.fullContent = '',
    this.duration = '',
  });

  final _ResourceType type;
  final String title;
  final String subtitle;
  final String tag;
  final IconData icon;
  final String subject;
  final Color color;
  final String fullContent;
  final String duration;

  bool matchesFilter(int filterIndex) {
    if (filterIndex == 0) return true; // All
    if (filterIndex == 1) return type == _ResourceType.article;
    if (filterIndex == 2) return type == _ResourceType.video;
    if (filterIndex == 3) {
      return type == _ResourceType.worksheet || type == _ResourceType.pdf;
    }
    return true;
  }

  bool matchesSearch(String query) {
    if (query.isEmpty) return true;
    final q = query.toLowerCase();
    return title.toLowerCase().contains(q) ||
        subtitle.toLowerCase().contains(q) ||
        subject.toLowerCase().contains(q);
  }
}

// ── All resources catalogue ───────────────────────────────────────────────────

const _kAllResources = <_Resource>[
  _Resource(
    type: _ResourceType.article,
    subject: 'PROGRESO',
    title: 'Cómo interpretar los reportes de EduPlay',
    subtitle:
        'Guía completa para padres sobre dominio de habilidades, curvas de aprendizaje y métricas de inteligencia emocional.',
    tag: '8 min de lectura',
    icon: Icons.insights_rounded,
    color: _kNavy,
    duration: '8 min',
    fullContent:
        'Los reportes de EduPlay muestran el progreso de tu hijo en tres dimensiones: dominio de habilidades, velocidad de aprendizaje y motivación. '
        'Cada icono de estrella equivale al 20 % de dominio en una competencia. '
        'Cuando veas una barra azul sólida, significa que tu hijo ha superado el objetivo semanal. '
        '\n\n**¿Qué hacer si el progreso es lento?**\n'
        'No te preocupes. El ritmo de cada niño es diferente. Revisa la sección "Necesita practicar" en el panel para saber en qué áreas enfocar el tiempo en casa.',
  ),
  _Resource(
    type: _ResourceType.video,
    subject: 'METAS',
    title: 'Establecer metas con tu hijo',
    subtitle:
        'Guía de 5 minutos sobre cómo definir objetivos de aprendizaje colaborativos.',
    tag: '5:20 mins',
    icon: Icons.flag_rounded,
    color: Color(0xFF8E44AD),
    duration: '5:20',
    fullContent:
        'Este video muestra cómo sentarte con tu hijo cada semana, revisar los logros y elegir juntos el próximo reto de aprendizaje.',
  ),
  _Resource(
    type: _ResourceType.article,
    subject: 'TIEMPO DE PANTALLA',
    title: 'La regla "Uno por Uno"',
    subtitle:
        'Cómo equilibrar el juego digital con la actividad física de manera efectiva.',
    tag: '6 min de lectura',
    icon: Icons.device_unknown_rounded,
    color: Color(0xFF2ECC71),
    duration: '6 min',
    fullContent:
        'La regla "Uno por Uno" sugiere que por cada 30 minutos de pantalla, el niño dedique otros 30 minutos a actividades físicas o creativas fuera de la pantalla. '
        'Estudios muestran que este equilibrio mejora la atención y reduce el agotamiento digital.',
  ),
  _Resource(
    type: _ResourceType.pdf,
    subject: 'BIENESTAR DIGITAL',
    title: 'Contrato de Bienestar Digital Familiar',
    subtitle: 'Plantilla descargable para establecer normas sanas en casa.',
    tag: '1.2 MB · PDF',
    icon: Icons.nights_stay_rounded,
    color: Color(0xFF2C3E50),
    duration: '',
    fullContent:
        'Un contrato sencillo que toda la familia puede firmar para acordar límites de pantalla, horarios y tipos de contenido permitido.',
  ),
  _Resource(
    type: _ResourceType.article,
    subject: 'CIENCIAS',
    title: 'Top 10 aplicaciones de ciencias para niños curiosos',
    subtitle:
        'Lista curada de apps seguras y exploratorias para jóvenes científicos.',
    tag: 'Recomendado por Maestra Sara',
    icon: Icons.science_rounded,
    color: Color(0xFF3498DB),
    duration: '5 min',
    fullContent:
        '1. SkyView — astronomía en tiempo real.\n2. Toca Lab — experimentos virtuales sin riesgo.\n3. Khan Academy Kids — ciencias básicas con personajes adorables.\n'
        '4. Frog Dissection — biología interactiva.\n5. NASA Visualization Explorer — imágenes reales del espacio.\n'
        'Y más en nuestra guía completa.',
  ),
  _Resource(
    type: _ResourceType.video,
    subject: 'MATEMÁTICAS',
    title: 'Alfabetización matemática: estrategias en casa',
    subtitle:
        'Maneras sencillas de incorporar las matemáticas en la rutina diaria.',
    tag: '12:40 mins',
    icon: Icons.calculate_rounded,
    color: Color(0xFFFF9800),
    duration: '12:40',
    fullContent:
        'Este video muestra cómo usar actividades cotidianas —compras, cocina, juegos— para reforzar conceptos matemáticos de forma natural y divertida.',
  ),
  _Resource(
    type: _ResourceType.worksheet,
    subject: 'MATEMÁTICAS',
    title: 'Laberinto de Sumas: El Jardín',
    subtitle: 'Hoja de trabajo imprimible para practicar sumas del 1 al 20.',
    tag: 'Nivel 1 · Imprimible',
    icon: Icons.calculate_rounded,
    color: Color(0xFF2ECC71),
    duration: '',
    fullContent:
        'Laberinto de sumas donde el niño debe resolver operaciones para encontrar el camino correcto a través del jardín.',
  ),
  _Resource(
    type: _ResourceType.worksheet,
    subject: 'ARTES',
    title: 'Hábitats de Animales para Colorear',
    subtitle:
        'Colorea e identifica los hábitats naturales de 8 animales diferentes.',
    tag: 'Nivel 1 · Imprimible',
    icon: Icons.palette_rounded,
    color: Color(0xFFE91E63),
    duration: '',
    fullContent:
        'Lámina de colorear con 8 animales en sus hábitats: selva, desierto, océano, montaña y más.',
  ),
  _Resource(
    type: _ResourceType.worksheet,
    subject: 'LECTURA',
    title: 'Tarjetas Fonéticas',
    subtitle: 'Conjunto de flashcards para practicar la lectura en voz alta.',
    tag: 'Nivel 2 · Imprimible',
    icon: Icons.auto_stories_rounded,
    color: Color(0xFF3498DB),
    duration: '',
    fullContent:
        '24 tarjetas fonéticas para recortar, cubiertas con los sonidos más frecuentes del español.',
  ),
  _Resource(
    type: _ResourceType.worksheet,
    subject: 'CIENCIAS',
    title: 'Diario de Observación del Clima',
    subtitle:
        'Registra el tiempo meteorológico durante 7 días y analiza los patrones.',
    tag: 'Nivel 2 · Imprimible',
    icon: Icons.wb_sunny_rounded,
    color: Color(0xFFFF9800),
    duration: '',
    fullContent:
        'Tabla semanal donde el niño dibuja el clima de cada día y responde 3 preguntas de reflexión.',
  ),
];

// ── Entry point ───────────────────────────────────────────────────────────────

class ParentGuidePage extends StatefulWidget {
  const ParentGuidePage({super.key});

  @override
  State<ParentGuidePage> createState() => _ParentGuidePageState();
}

class _ParentGuidePageState extends State<ParentGuidePage> {
  int _filterIndex = 0; // 0=Todo, 1=Artículos, 2=Videos, 3=Fichas
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _libraryKey = GlobalKey();
  final _newsletterEmailCtrl = TextEditingController();
  bool _subscribed = false;
  final Set<String> _bookmarked = {};

  static const _filters = [
    'Todo',
    'Artículos',
    'Videos',
    'Fichas',
  ];

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    _newsletterEmailCtrl.dispose();
    super.dispose();
  }

  void _scrollToLibrary() {
    final ctx = _libraryKey.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(ctx,
          duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    }
  }

  void _openResource(_Resource r) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ResourceDetailSheet(resource: r),
    );
  }

  void _toggleBookmark(String title) {
    setState(() {
      if (_bookmarked.contains(title)) {
        _bookmarked.remove(title);
      } else {
        _bookmarked.add(title);
      }
    });
  }

  void _downloadWorksheet(_Resource r) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.download_done_rounded,
                color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '"${r.title}" descargado correctamente.',
                style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF27AE60),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showLatestUpdates() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const _LatestUpdatesSheet(),
    );
  }

  void _subscribe() {
    final email = _newsletterEmailCtrl.text.trim();
    final emailRegex = RegExp(r'^[\w\.\+\-]+@[\w\-]+\.[a-z]{2,}$');
    if (!emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor ingresa un correo válido.',
              style: GoogleFonts.nunito()),
          backgroundColor: _kRed,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }
    setState(() => _subscribed = true);
    _newsletterEmailCtrl.clear();
  }

  List<_Resource> get _filteredResources {
    final q = _searchCtrl.text;
    return _kAllResources
        .where((r) => r.matchesFilter(_filterIndex) && r.matchesSearch(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Column(
        children: [
          const EduPlayNavBar.parent(activeParentTab: ParentTab.recursos),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollCtrl,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero banner
                  _HeroBanner(
                    onExploreLibrary: _scrollToLibrary,
                    onLatestUpdates: _showLatestUpdates,
                  ),

                  // Library section with search + filter
                  _LibrarySection(
                    key: _libraryKey,
                    filterIndex: _filterIndex,
                    filters: _filters,
                    onFilterTap: (i) => setState(() => _filterIndex = i),
                    searchCtrl: _searchCtrl,
                    resources: _filteredResources,
                    bookmarked: _bookmarked,
                    onOpenResource: _openResource,
                    onToggleBookmark: _toggleBookmark,
                    onDownload: _downloadWorksheet,
                  ),

                  // Newsletter
                  _NewsletterSection(
                    emailCtrl: _newsletterEmailCtrl,
                    subscribed: _subscribed,
                    onSubscribe: _subscribe,
                  ),

                  // Footer
                  const _GuideFooter(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Hero banner ───────────────────────────────────────────────────────────────

class _HeroBanner extends StatelessWidget {
  const _HeroBanner(
      {required this.onExploreLibrary, required this.onLatestUpdates});

  final VoidCallback onExploreLibrary;
  final VoidCallback onLatestUpdates;

  @override
  Widget build(BuildContext context) {
    final isDesktop = ScreenSize.of(context).isDesktop;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E1B6A), Color(0xFF2D2A8A)],
        ),
      ),
      child: Stack(
        children: [
          // Decorative blobs
          Positioned(
            top: -30,
            right: isDesktop ? 120 : -30,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
          ),
          Positioned(
            bottom: -40,
            right: isDesktop ? 60 : -20,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 56 : 24,
              vertical: isDesktop ? 52 : 36,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Text side
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD700).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color:
                                const Color(0xFFFFD700).withValues(alpha: 0.4),
                          ),
                        ),
                        child: Text(
                          'CENTRO DE RECURSOS PARA PADRES',
                          style: GoogleFonts.nunito(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                            color: const Color(0xFFFFD700),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Apoya el aprendizaje\nde tu hijo en casa',
                        style: GoogleFonts.fredoka(
                          fontSize: isDesktop ? 36 : 26,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Accede a nuestra biblioteca de artículos, guías en video y fichas\nimprimibles diseñadas para conectar el aula con el hogar.',
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.72),
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: onExploreLibrary,
                            icon: const Icon(Icons.auto_stories_rounded,
                                size: 16),
                            label: Text(
                              'Explorar biblioteca',
                              style: GoogleFonts.nunito(
                                  fontWeight: FontWeight.w700, fontSize: 13),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _kRed,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton(
                            onPressed: onLatestUpdates,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: BorderSide(
                                  color: Colors.white.withValues(alpha: 0.4)),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                            ),
                            child: Text(
                              'Novedades',
                              style: GoogleFonts.nunito(
                                  fontWeight: FontWeight.w700, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Quick stats row
                      Wrap(
                        spacing: 20,
                        runSpacing: 8,
                        children: [
                          _StatPill(
                              label:
                                  '${_kAllResources.where((r) => r.type == _ResourceType.article).length} artículos'),
                          _StatPill(
                              label:
                                  '${_kAllResources.where((r) => r.type == _ResourceType.video).length} videos'),
                          _StatPill(
                              label:
                                  '${_kAllResources.where((r) => r.type == _ResourceType.worksheet || r.type == _ResourceType.pdf).length} fichas'),
                        ],
                      ),
                    ],
                  ),
                ),
                // Art side
                if (isDesktop) ...[
                  const SizedBox(width: 40),
                  const Expanded(flex: 3, child: _HeroArtWidget()),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.nunito(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.white.withValues(alpha: 0.85),
        ),
      ),
    );
  }
}

class _HeroArtWidget extends StatelessWidget {
  const _HeroArtWidget();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFB347), Color(0xFFFF6B9D), Color(0xFF9B59B6)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 20,
            left: 20,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.2),
              ),
            ),
          ),
          Positioned(
            bottom: 30,
            right: 30,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.15),
              ),
            ),
          ),
          Center(
            child: Icon(
              Icons.menu_book_rounded,
              size: 72,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Library section ───────────────────────────────────────────────────────────

class _LibrarySection extends StatelessWidget {
  const _LibrarySection({
    super.key,
    required this.filterIndex,
    required this.filters,
    required this.onFilterTap,
    required this.searchCtrl,
    required this.resources,
    required this.bookmarked,
    required this.onOpenResource,
    required this.onToggleBookmark,
    required this.onDownload,
  });

  final int filterIndex;
  final List<String> filters;
  final ValueChanged<int> onFilterTap;
  final TextEditingController searchCtrl;
  final List<_Resource> resources;
  final Set<String> bookmarked;
  final ValueChanged<_Resource> onOpenResource;
  final ValueChanged<String> onToggleBookmark;
  final ValueChanged<_Resource> onDownload;

  @override
  Widget build(BuildContext context) {
    final isDesktop = ScreenSize.of(context).isDesktop;
    final hPad = isDesktop ? 56.0 : 24.0;

    final articles =
        resources.where((r) => r.type == _ResourceType.article).toList();
    final videos =
        resources.where((r) => r.type == _ResourceType.video).toList();
    final worksheets = resources
        .where((r) =>
            r.type == _ResourceType.worksheet || r.type == _ResourceType.pdf)
        .toList();

    final showArticles = filterIndex == 0 || filterIndex == 1;
    final showVideos = filterIndex == 0 || filterIndex == 2;
    final showWorksheets = filterIndex == 0 || filterIndex == 3;

    return Padding(
      padding: EdgeInsets.fromLTRB(hPad, 40, hPad, 36),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Biblioteca de recursos',
                      style: GoogleFonts.fredoka(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: _kNavy,
                      ),
                    ),
                    Text(
                      'Contenido curado por expertos en educación.',
                      style: GoogleFonts.nunito(
                          fontSize: 13, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
              // Filter chips — wrap on small screens
              if (isDesktop)
                Wrap(
                  spacing: 8,
                  children: List.generate(
                    filters.length,
                    (i) => _FilterChip(
                      label: filters[i],
                      selected: filterIndex == i,
                      onTap: () => onFilterTap(i),
                    ),
                  ),
                ),
            ],
          ),

          // Filter chips on mobile (below header)
          if (!isDesktop) ...[
            const SizedBox(height: 14),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(
                  filters.length,
                  (i) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _FilterChip(
                      label: filters[i],
                      selected: filterIndex == i,
                      onTap: () => onFilterTap(i),
                    ),
                  ),
                ),
              ),
            ),
          ],

          const SizedBox(height: 20),

          // Search bar
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const SizedBox(width: 14),
                Icon(Icons.search_rounded, size: 18, color: Colors.grey[400]),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: searchCtrl,
                    style: GoogleFonts.nunito(fontSize: 14),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Buscar artículos, videos, fichas...',
                      hintStyle: GoogleFonts.nunito(
                          fontSize: 13, color: Colors.grey[400]),
                      isDense: true,
                    ),
                  ),
                ),
                if (searchCtrl.text.isNotEmpty)
                  IconButton(
                    icon: Icon(Icons.close_rounded,
                        size: 16, color: Colors.grey[400]),
                    onPressed: searchCtrl.clear,
                    padding: EdgeInsets.zero,
                    constraints:
                        const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                const SizedBox(width: 4),
              ],
            ),
          ),

          // Empty state
          if (resources.isEmpty) ...[
            const SizedBox(height: 48),
            Center(
              child: Column(
                children: [
                  Icon(Icons.search_off_rounded,
                      size: 48, color: Colors.grey[300]),
                  const SizedBox(height: 14),
                  Text(
                    'Sin resultados',
                    style: GoogleFonts.fredoka(
                        fontSize: 18, color: Colors.grey[400]),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Prueba con otra búsqueda o cambia el filtro.',
                    style: GoogleFonts.nunito(
                        fontSize: 13, color: Colors.grey[400]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
          ] else ...[
            // ── Articles ──────────────────────────────────────────────────────
            if (showArticles && articles.isNotEmpty) ...[
              const SizedBox(height: 28),
              const _SubsectionHeader(
                icon: Icons.article_rounded,
                title: 'Artículos',
              ),
              const SizedBox(height: 16),
              ...articles.map((r) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ResourceTile(
                      resource: r,
                      isBookmarked: bookmarked.contains(r.title),
                      onTap: () => onOpenResource(r),
                      onBookmark: () => onToggleBookmark(r.title),
                    ),
                  )),
            ],

            // ── Videos ────────────────────────────────────────────────────────
            if (showVideos && videos.isNotEmpty) ...[
              const SizedBox(height: 28),
              const _SubsectionHeader(
                icon: Icons.play_circle_outline_rounded,
                title: 'Videos',
              ),
              const SizedBox(height: 16),
              if (isDesktop)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: videos
                      .map((r) => Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: _VideoCard(
                                resource: r,
                                isBookmarked: bookmarked.contains(r.title),
                                onTap: () => onOpenResource(r),
                                onBookmark: () => onToggleBookmark(r.title),
                              ),
                            ),
                          ))
                      .toList(),
                )
              else
                Column(
                  children: videos
                      .map((r) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _VideoCard(
                              resource: r,
                              isBookmarked: bookmarked.contains(r.title),
                              onTap: () => onOpenResource(r),
                              onBookmark: () => onToggleBookmark(r.title),
                            ),
                          ))
                      .toList(),
                ),
            ],

            // ── Worksheets / PDFs ─────────────────────────────────────────────
            if (showWorksheets && worksheets.isNotEmpty) ...[
              const SizedBox(height: 28),
              Row(
                children: [
                  const _SubsectionHeader(
                      icon: Icons.print_rounded, title: 'Fichas Imprimibles'),
                  const Spacer(),
                  TextButton(
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Más fichas próximamente.'),
                        duration: Duration(seconds: 2),
                      ),
                    ),
                    child: Text(
                      'Ver todas',
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _kNavy.withValues(alpha: 0.5),
                        decoration: TextDecoration.underline,
                        decorationColor: _kNavy.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                color: Colors.white.withValues(alpha: 0.6),
                padding: const EdgeInsets.all(16),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isDesktop ? 4 : 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.88,
                  ),
                  itemCount: worksheets.length,
                  itemBuilder: (_, i) => _WorksheetCard(
                    resource: worksheets[i],
                    isBookmarked: bookmarked.contains(worksheets[i].title),
                    onTap: () => onOpenResource(worksheets[i]),
                    onDownload: () => onDownload(worksheets[i]),
                    onBookmark: () => onToggleBookmark(worksheets[i].title),
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

// ── Filter chip ───────────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  const _FilterChip(
      {required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? _kNavy : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? _kNavy : Colors.grey.shade200),
        ),
        child: Text(
          label,
          style: GoogleFonts.nunito(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : Colors.grey[600],
          ),
        ),
      ),
    );
  }
}

// ── Subsection header ─────────────────────────────────────────────────────────

class _SubsectionHeader extends StatelessWidget {
  const _SubsectionHeader({required this.icon, required this.title});
  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: _kRed),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.fredoka(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _kNavy,
          ),
        ),
      ],
    );
  }
}

// ── Resource tile (article / pdf) ─────────────────────────────────────────────

class _ResourceTile extends StatelessWidget {
  const _ResourceTile({
    required this.resource,
    required this.isBookmarked,
    required this.onTap,
    required this.onBookmark,
  });

  final _Resource resource;
  final bool isBookmarked;
  final VoidCallback onTap;
  final VoidCallback onBookmark;

  Color get _gradientA => resource.color;
  Color get _gradientB => resource.color.withValues(alpha: 0.65);

  @override
  Widget build(BuildContext context) {
    final isPdf = resource.type == _ResourceType.pdf;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [_gradientA, _gradientB],
                  ),
                ),
                child: Center(
                  child: Icon(resource.icon,
                      size: 28, color: Colors.white.withValues(alpha: 0.85)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _ContentTypeBadge(
                        label: isPdf ? 'PDF' : 'ARTÍCULO',
                        color: resource.color,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        resource.tag,
                        style: GoogleFonts.nunito(
                            fontSize: 10, color: Colors.grey[400]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    resource.title,
                    style: GoogleFonts.nunito(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _kNavy),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    resource.subtitle,
                    style: GoogleFonts.nunito(
                        fontSize: 11, color: Colors.grey[500], height: 1.4),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Bookmark icon
            IconButton(
              icon: Icon(
                isBookmarked
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_border_rounded,
                size: 20,
                color: isBookmarked ? _kRed : Colors.grey[300],
              ),
              onPressed: onBookmark,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Video card ────────────────────────────────────────────────────────────────

class _VideoCard extends StatelessWidget {
  const _VideoCard({
    required this.resource,
    required this.isBookmarked,
    required this.onTap,
    required this.onBookmark,
  });

  final _Resource resource;
  final bool isBookmarked;
  final VoidCallback onTap;
  final VoidCallback onBookmark;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail with play button
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Container(
                    height: 140,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          resource.color.withValues(alpha: 0.85),
                          resource.color,
                        ],
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        resource.icon,
                        size: 60,
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child:
                      _ContentTypeBadge(label: 'VIDEO', color: resource.color),
                ),
                // Duration pill
                if (resource.duration.isNotEmpty)
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        resource.duration,
                        style: GoogleFonts.nunito(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Colors.white),
                      ),
                    ),
                  ),
                // Play button
                Positioned.fill(
                  child: Center(
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.9),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 8)
                        ],
                      ),
                      child: const Icon(Icons.play_arrow_rounded,
                          color: _kNavy, size: 26),
                    ),
                  ),
                ),
                // Bookmark
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: onBookmark,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                      child: Icon(
                        isBookmarked
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_border_rounded,
                        size: 16,
                        color: isBookmarked ? _kRed : Colors.grey[500],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    resource.title,
                    style: GoogleFonts.fredoka(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _kNavy),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    resource.subtitle,
                    style: GoogleFonts.nunito(
                        fontSize: 12, color: Colors.grey[500], height: 1.4),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Worksheet card ────────────────────────────────────────────────────────────

class _WorksheetCard extends StatelessWidget {
  const _WorksheetCard({
    required this.resource,
    required this.isBookmarked,
    required this.onTap,
    required this.onDownload,
    required this.onBookmark,
  });

  final _Resource resource;
  final bool isBookmarked;
  final VoidCallback onTap;
  final VoidCallback onDownload;
  final VoidCallback onBookmark;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF8F7FF),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Preview area
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(14)),
                  child: Container(
                    height: 90,
                    width: double.infinity,
                    color: resource.color.withValues(alpha: 0.1),
                    child: Center(
                      child: Icon(resource.icon,
                          size: 40,
                          color: resource.color.withValues(alpha: 0.45)),
                    ),
                  ),
                ),
                // Download button
                Positioned(
                  top: 7,
                  right: 7,
                  child: GestureDetector(
                    onTap: onDownload,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 4)
                        ],
                      ),
                      child: const Icon(Icons.download_rounded,
                          size: 14, color: Color(0xFF666666)),
                    ),
                  ),
                ),
                // Bookmark
                Positioned(
                  top: 7,
                  left: 7,
                  child: GestureDetector(
                    onTap: onBookmark,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 4)
                        ],
                      ),
                      child: Icon(
                        isBookmarked
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_border_rounded,
                        size: 14,
                        color: isBookmarked ? _kRed : Colors.grey[400],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    resource.subject,
                    style: GoogleFonts.nunito(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: resource.color,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    resource.title,
                    style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _kNavy),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Content type badge ────────────────────────────────────────────────────────

class _ContentTypeBadge extends StatelessWidget {
  const _ContentTypeBadge({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: GoogleFonts.nunito(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
          color: color,
        ),
      ),
    );
  }
}

// ── Resource detail bottom sheet ──────────────────────────────────────────────

class _ResourceDetailSheet extends StatelessWidget {
  const _ResourceDetailSheet({required this.resource});
  final _Resource resource;

  @override
  Widget build(BuildContext context) {
    final isVideo = resource.type == _ResourceType.video;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 4),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header image / gradient
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    resource.color,
                    resource.color.withValues(alpha: 0.6),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  if (isVideo)
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                            child: const Icon(Icons.play_arrow_rounded,
                                color: _kNavy, size: 32),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Video · ${resource.duration}',
                            style: GoogleFonts.nunito(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontWeight: FontWeight.w700,
                                fontSize: 13),
                          ),
                        ],
                      ),
                    )
                  else
                    Center(
                      child: Icon(resource.icon,
                          size: 60, color: Colors.white.withValues(alpha: 0.4)),
                    ),
                  Positioned(
                    top: 14,
                    left: 16,
                    child: _ContentTypeBadge(
                      label: _typeLabel(resource.type),
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            // Body
            Expanded(
              child: ListView(
                controller: scrollCtrl,
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                children: [
                  Text(
                    resource.subject,
                    style: GoogleFonts.nunito(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: resource.color,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    resource.title,
                    style: GoogleFonts.fredoka(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: _kNavy,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (resource.duration.isNotEmpty)
                    Row(
                      children: [
                        Icon(
                          isVideo
                              ? Icons.access_time_rounded
                              : Icons.menu_book_outlined,
                          size: 14,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isVideo
                              ? resource.duration
                              : '${resource.duration} de lectura',
                          style: GoogleFonts.nunito(
                              fontSize: 12, color: Colors.grey[400]),
                        ),
                      ],
                    ),
                  const SizedBox(height: 12),
                  Text(
                    resource.subtitle,
                    style: GoogleFonts.nunito(
                        fontSize: 14, color: Colors.grey[500], height: 1.5),
                  ),
                  const Divider(height: 32),
                  if (resource.fullContent.isNotEmpty)
                    Text(
                      resource.fullContent,
                      style: GoogleFonts.nunito(
                          fontSize: 14, color: Colors.grey[700], height: 1.7),
                    ),
                  if (isVideo) ...[
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _kLavender,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline_rounded,
                              size: 20, color: _kNavy),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Los videos estarán disponibles próximamente. '
                              'Regístrate en el boletín para saber cuándo se publican.',
                              style: GoogleFonts.nunito(
                                  fontSize: 13, color: _kNavy, height: 1.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  // CTA button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: resource.color,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isVideo
                                  ? 'Video guardado en tu lista.'
                                  : 'Abriendo recurso...',
                              style: GoogleFonts.nunito(),
                            ),
                            backgroundColor: resource.color,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            margin: const EdgeInsets.all(16),
                          ),
                        );
                      },
                      child: Text(
                        isVideo
                            ? 'Guardar en mi lista'
                            : 'Leer recurso completo',
                        style: GoogleFonts.nunito(
                            fontWeight: FontWeight.w700, fontSize: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _typeLabel(_ResourceType type) {
    switch (type) {
      case _ResourceType.article:
        return 'ARTÍCULO';
      case _ResourceType.video:
        return 'VIDEO';
      case _ResourceType.pdf:
        return 'PDF';
      case _ResourceType.worksheet:
        return 'FICHA';
    }
  }
}

// ── Latest updates bottom sheet ───────────────────────────────────────────────

class _LatestUpdatesSheet extends StatelessWidget {
  const _LatestUpdatesSheet();

  static const _updates = [
    (
      date: 'Junio 2026',
      title: '4 nuevas fichas de Ciencias',
      body:
          'Hemos agregado fichas sobre el ciclo del agua, los planetas, los tipos de suelo y la fotosíntesis.',
      icon: Icons.science_rounded,
      color: Color(0xFF3498DB),
    ),
    (
      date: 'Mayo 2026',
      title: 'Nuevo video: Motivación en casa',
      body:
          'Una guía de 8 minutos para mantener la motivación de tu hijo durante las sesiones de práctica.',
      icon: Icons.play_circle_rounded,
      color: Color(0xFF8E44AD),
    ),
    (
      date: 'Abril 2026',
      title: 'Artículo: Límites digitales saludables',
      body:
          'Estrategias basadas en evidencia para establecer rutinas digitales sanas sin generar conflictos en casa.',
      icon: Icons.article_rounded,
      color: _kNavy,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Novedades recientes',
            style: GoogleFonts.fredoka(
                fontSize: 22, fontWeight: FontWeight.w700, color: _kNavy),
          ),
          const SizedBox(height: 4),
          Text(
            'Lo que hemos añadido últimamente.',
            style: GoogleFonts.nunito(fontSize: 13, color: Colors.grey[500]),
          ),
          const SizedBox(height: 20),
          for (final u in _updates) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: u.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(u.icon, size: 20, color: u.color),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        u.date,
                        style: GoogleFonts.nunito(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Colors.grey[400],
                            letterSpacing: 0.5),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        u.title,
                        style: GoogleFonts.nunito(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: _kNavy),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        u.body,
                        style: GoogleFonts.nunito(
                            fontSize: 12, color: Colors.grey[500], height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (u != _updates.last) Divider(color: Colors.grey[100], height: 1),
            if (u != _updates.last) const SizedBox(height: 16),
          ],
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _kNavy,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () => Navigator.pop(context),
              child: Text('Cerrar',
                  style: GoogleFonts.nunito(
                      fontWeight: FontWeight.w700, fontSize: 15)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Newsletter section ────────────────────────────────────────────────────────

class _NewsletterSection extends StatelessWidget {
  const _NewsletterSection({
    required this.emailCtrl,
    required this.subscribed,
    required this.onSubscribe,
  });

  final TextEditingController emailCtrl;
  final bool subscribed;
  final VoidCallback onSubscribe;

  @override
  Widget build(BuildContext context) {
    final isDesktop = ScreenSize.of(context).isDesktop;

    return Container(
      color: _kLavender,
      padding:
          EdgeInsets.symmetric(horizontal: isDesktop ? 56 : 24, vertical: 52),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: subscribed
              ? Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: const Color(0xFF27AE60),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.check_rounded,
                          color: Colors.white, size: 34),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '¡Suscripción confirmada!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.fredoka(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: _kNavy,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Te enviaremos los mejores recursos cada martes.\nPuedes cancelar cuando quieras.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunito(
                          fontSize: 13, color: Colors.grey[500], height: 1.5),
                    ),
                  ],
                )
              : Column(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: _kNavy,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.mail_rounded,
                          color: Colors.white, size: 26),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Recibe recursos cada semana',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.fredoka(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: _kNavy,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Más de 15.000 padres reciben nuestras mejores actividades\ny consejos educativos directamente en su correo cada martes.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunito(
                          fontSize: 13, color: Colors.grey[500], height: 1.5),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 46,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            child: TextField(
                              controller: emailCtrl,
                              keyboardType: TextInputType.emailAddress,
                              style: GoogleFonts.nunito(fontSize: 13),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Tu correo electrónico',
                                hintStyle: GoogleFonts.nunito(
                                    fontSize: 13, color: Colors.grey[400]),
                                isDense: true,
                              ),
                              onSubmitted: (_) => onSubscribe(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: onSubscribe,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _kNavy,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 22, vertical: 13),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          child: Text(
                            'Suscribirme',
                            style: GoogleFonts.nunito(
                                fontWeight: FontWeight.w700, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Sin spam. Solo contenido útil. Cancela cuando quieras.',
                      style: GoogleFonts.nunito(
                          fontSize: 11, color: Colors.grey[400]),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// ── Footer ────────────────────────────────────────────────────────────────────

class _GuideFooter extends StatelessWidget {
  const _GuideFooter();

  @override
  Widget build(BuildContext context) {
    final isDesktop = ScreenSize.of(context).isDesktop;
    final hPad = isDesktop ? 56.0 : 24.0;

    return Container(
      color: const Color(0xFF111827),
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 40),
      child: Column(
        children: [
          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'EduPlay',
                        style: GoogleFonts.fredoka(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Construyendo el futuro del aprendizaje a través de la exploración lúdica.',
                        style: GoogleFonts.nunito(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.45),
                            height: 1.5),
                      ),
                    ],
                  ),
                ),
                const Expanded(
                  flex: 2,
                  child: _FooterCol('Recursos', [
                    'Recursos para maestros',
                    'Guía para padres',
                    'Soporte',
                  ]),
                ),
                const Expanded(
                  flex: 2,
                  child: _FooterCol('Legal', [
                    'Política de privacidad',
                    'Términos de servicio',
                  ]),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DESCARGA LA APP',
                        style: GoogleFonts.nunito(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          color: Colors.white.withValues(alpha: 0.45),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.apple_rounded,
                                color: Colors.white, size: 18),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Disponible en',
                                  style: GoogleFonts.nunito(
                                      fontSize: 9,
                                      color:
                                          Colors.white.withValues(alpha: 0.6)),
                                ),
                                Text(
                                  'App Store',
                                  style: GoogleFonts.nunito(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'EduPlay',
                  style: GoogleFonts.fredoka(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const SizedBox(height: 20),
                const _FooterCol('Recursos',
                    ['Recursos para maestros', 'Guía para padres', 'Soporte']),
                const SizedBox(height: 16),
                const _FooterCol('Legal',
                    ['Política de privacidad', 'Términos de servicio']),
              ],
            ),
          const SizedBox(height: 32),
          Divider(color: Colors.white.withValues(alpha: 0.1)),
          const SizedBox(height: 20),
          Text(
            '© ${DateTime.now().year} EduPlay Learning. Todos los derechos reservados.',
            style: GoogleFonts.nunito(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.35),
            ),
          ),
        ],
      ),
    );
  }
}

class _FooterCol extends StatelessWidget {
  const _FooterCol(this.title, this.links);
  final String title;
  final List<String> links;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: GoogleFonts.nunito(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            color: Colors.white.withValues(alpha: 0.45),
          ),
        ),
        const SizedBox(height: 12),
        for (final link in links)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              link,
              style: GoogleFonts.nunito(
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.65),
              ),
            ),
          ),
      ],
    );
  }
}
