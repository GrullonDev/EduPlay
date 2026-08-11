class ClassMember {
  const ClassMember({
    required this.id,
    required this.classId,
    required this.teacherUid,
    required this.className,
    required this.classSubject,
    required this.classGradeLevel,
    required this.displayName,
    required this.email,
    required this.role,
    required this.studentId,
    required this.childProfileId,
    required this.parentUid,
    required this.age,
    required this.focusSubject,
    required this.completedChallengeIds,
    required this.joinedAt,
  });

  final String id;
  final String classId;
  final String teacherUid;
  final String className;
  final String classSubject;
  final String classGradeLevel;
  final String displayName;
  final String email;
  final String role;
  final String studentId;
  final String childProfileId;
  final String parentUid;
  final int? age;
  final String focusSubject;
  final List<String> completedChallengeIds;
  final DateTime joinedAt;
}
