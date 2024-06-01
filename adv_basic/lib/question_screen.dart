import 'package:adv_basic/answer_button.dart';
import 'package:adv_basic/data/questions.dart';
import 'package:adv_basic/models/quiz_question.dart';
import 'package:flutter/material.dart';

class QuestionScreen extends StatefulWidget {
  const QuestionScreen({super.key, required this.handleChooseAnswer});

  final void Function(String answer) handleChooseAnswer;

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  int currentIndexQuestion = 0;
  late QuizQuestion currentQuestion = questions[currentIndexQuestion];

  void handleNextQuestion() {
    if (currentIndexQuestion < questions.length - 1) {
      setState(() {
        currentIndexQuestion++;
        currentQuestion = questions[currentIndexQuestion];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(50),
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            currentQuestion.question,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          ...currentQuestion.getShuffleAnswer().map((answer) {
            return AnswerButton(
                text: answer,
                onTap: () {
                  handleNextQuestion();
                  widget.handleChooseAnswer(answer);
                });
          }),
        ],
      ),
    );
  }
}
