class QuizQuestion {
  final String question;
  final List<String> answers;

  QuizQuestion(
    this.question,
    this.answers,
  );
  List<String> getShuffleAnswer() {
    final shuffleList = List.of(answers);
    shuffleList.shuffle();
    return shuffleList;
  }
}
