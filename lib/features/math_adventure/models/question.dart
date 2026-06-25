class Question {
  Question({
    required this.question,
    required this.options,
    required this.answer,
  });
  final String question;
  final List<String> options;
  final int answer;
}
