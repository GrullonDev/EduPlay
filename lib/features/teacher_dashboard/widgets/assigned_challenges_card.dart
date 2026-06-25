import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:edu_play/shared/data/subject_catalog.dart';
import 'package:edu_play/utils/app_theme.dart';

/// "Retos Asignados" card: lists the challenges created by the teacher
/// (stored locally) and lets them add new ones.
class AssignedChallengesCard extends StatelessWidget {
  const AssignedChallengesCard({
    super.key,
    required this.challenges,
    required this.onAddChallenge,
  });

  final List<Map<String, dynamic>> challenges;
  final void Function({
    required String title,
    required String subjectKey,
    String? dueDate,
  }) onAddChallenge;

  Future<void> _showAddDialog(BuildContext context) async {
    final titleController = TextEditingController();
    String selectedSubject = subjectCatalog.first.key;
    DateTime? dueDate;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setState) {
            return AlertDialog(
              title: const Text('Nuevo Reto'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: titleController,
                      autofocus: true,
                      decoration: const InputDecoration(
                        labelText: 'Título del reto',
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: selectedSubject,
                      decoration: const InputDecoration(labelText: 'Materia'),
                      items: [
                        for (final subject in subjectCatalog)
                          DropdownMenuItem(
                            value: subject.key,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(subject.icon,
                                    size: 18, color: subject.color),
                                const SizedBox(width: 8),
                                Text(subject.label),
                              ],
                            ),
                          ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => selectedSubject = value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            dueDate == null
                                ? 'Sin fecha límite'
                                : 'Vence: ${dueDate!.day}/${dueDate!.month}/${dueDate!.year}',
                            style: GoogleFonts.nunito(color: Colors.grey[700]),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: dialogContext,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate:
                                  DateTime.now().add(const Duration(days: 365)),
                            );
                            if (picked != null) {
                              setState(() => dueDate = picked);
                            }
                          },
                          child: const Text('Elegir fecha'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final title = titleController.text.trim();
                    if (title.isEmpty) return;
                    onAddChallenge(
                      title: title,
                      subjectKey: selectedSubject,
                      dueDate: dueDate?.toIso8601String(),
                    );
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Crear Reto'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.flag_rounded, color: AppTheme.secondaryColor),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Retos Asignados',
                  style: GoogleFonts.fredoka(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textColor,
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddDialog(context),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Nuevo Reto'),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (challenges.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Aún no has asignado retos a tus estudiantes.',
                style: GoogleFonts.nunito(color: Colors.grey[600]),
              ),
            )
          else
            for (final challenge in challenges)
              _ChallengeRow(challenge: challenge),
        ],
      ),
    );
  }
}

class _ChallengeRow extends StatelessWidget {
  const _ChallengeRow({required this.challenge});

  final Map<String, dynamic> challenge;

  @override
  Widget build(BuildContext context) {
    final title = challenge['title'] as String? ?? 'Reto';
    final subjectKey = challenge['subject_key'] as String?;
    final subject = subjectKey != null ? subjectByKey(subjectKey) : null;
    final isCompleted = challenge['status'] == 'completed';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          if (subject != null) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: subject.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(subject.icon, size: 18, color: subject.color),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textColor,
                  ),
                ),
                if (subject != null)
                  Text(
                    subject.label,
                    style: GoogleFonts.nunito(
                        fontSize: 12, color: Colors.grey[600]),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: (isCompleted ? AppTheme.secondaryColor : Colors.orange)
                  .withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isCompleted ? 'Completado' : 'Activo',
              style: GoogleFonts.nunito(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isCompleted ? AppTheme.secondaryColor : Colors.orange,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
