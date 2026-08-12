class TeacherClass {
  const TeacherClass({
    required this.id,
    required this.teacherUid,
    this.teacherName = '',
    required this.name,
    required this.subject,
    required this.gradeLevel,
    required this.joinCode,
    required this.studentCount,
    this.minAge = 3,
    this.maxAge = 12,
    this.isPublic = false,
    required this.createdAt,
  });

  final String id;
  final String teacherUid;
  final String teacherName;
  final String name;
  final String subject;
  final String gradeLevel;
  final String joinCode;
  final int studentCount;
  final int minAge;
  final int maxAge;
  final bool isPublic;
  final DateTime createdAt;

  String get ageRangeLabel => '$minAge-$maxAge anos';
}
