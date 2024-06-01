import 'package:adv_basic/data/questions.dart';
import 'package:adv_basic/models/quiz_question.dart';
import 'package:adv_basic/question_screen.dart';
import 'package:adv_basic/result_screen.dart';
import 'package:adv_basic/start_screen.dart';
import 'package:flutter/material.dart';

class Quiz extends StatefulWidget {
  const Quiz({super.key});

  @override
  State<Quiz> createState() => _QuizState();
}

class _QuizState extends State<Quiz> {
  var activeScreen = "start_screen";
  List<String> resultUserAnswer = [];

  @override
  void initState() {
    activeScreen = "start_screen";
    super.initState();
  }

  void switchScreen() {
    setState(() {
      activeScreen = "question_screen";
    });
  }

  void handleChoose(String answer) {
    resultUserAnswer.add(answer);
    if (resultUserAnswer.length == questions.length) {
      setState(() {
        activeScreen = "result_screen";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget? screen;

    if (activeScreen == "start_screen") {
      screen = StartScreen(switchScreen);
    } else if (activeScreen == "question_screen") {
      screen = QuestionScreen(
        handleChooseAnswer: handleChoose,
      );
    } else if (activeScreen == "result_screen") {
      screen = ResultsScreen(
        answersUser: resultUserAnswer,
        onReStart: () {
          setState(() {
            resultUserAnswer = [];
            activeScreen = "start_screen";
          });
        },
      );
    }
    return MaterialApp(
      title: 'Quiz App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 78, 13, 151),
                Color.fromARGB(255, 107, 15, 168),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: screen,
        ),
      ),
    );
  }
}
