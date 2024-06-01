import 'package:adv_basic/data/questions.dart';
import 'package:adv_basic/sumary/questions_sumary.dart';
import 'package:flutter/material.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen(
      {super.key, required this.answersUser, required this.onReStart});

  final void Function() onReStart;
  final List<String> answersUser;

  List<Map<String, Object>> get sumaryData {
    final List<Map<String, Object>> data = [];
    for (int i = 0; i < answersUser.length; i++) {
      data.add({
        'question': questions[i].question,
        'question_index': i,
        'correct_answer': questions[i].answers[0],
        'answer_user': answersUser[i],
      });
    }
    return data;
  }

  @override
  Widget build(BuildContext context) {
    final numTotalQuestions = questions.length;
    final numCorrectQuestions = sumaryData
        .where(
          (data) => data['answer_user'] == data['correct_answer'],
        )
        .length;
    return SizedBox(
      width: double.infinity,
      child: Container(
        margin: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'You answered $numCorrectQuestions out of $numTotalQuestions questions correctly!',
              style: const TextStyle(
                color: Color.fromARGB(255, 230, 200, 253),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 30,
            ),
            QuestionsSummary(sumaryData),
            const SizedBox(
              height: 30,
            ),
            TextButton.icon(
              onPressed: onReStart,
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.refresh),
              label: const Text('Restart Quiz!'),
            )
          ],
        ),
      ),
    );
  }
}
