class ParentChallenge {
  const ParentChallenge({
    required this.subject,
    required this.title,
    required this.subtitle,
    required this.assignedBy,
    required this.tag,
  });

  final String subject;
  final String title;
  final String subtitle;
  final String? assignedBy;
  final String tag;

  factory ParentChallenge.fromJson(Map<String, dynamic> json) {
    return ParentChallenge(
      subject: json['subject'] as String? ?? '',
      title: json['title'] as String? ?? 'DesafÃ­o',
      subtitle: json['subtitle'] as String? ?? '',
      assignedBy: json['assignedBy'] as String?,
      tag: json['tag'] as String? ?? 'Pendiente',
    );
  }

  String get displaySubtitle {
    if (assignedBy != null && assignedBy!.isNotEmpty) {
      return 'Asignado por: $assignedBy';
    }
    return subtitle;
  }
}
