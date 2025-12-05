import 'package:flutter/material.dart';
import 'package:mcq_demo_task/provider/quiz_provider.dart';
import 'package:provider/provider.dart';

import 'screens/quiz_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (context) => QuizProvider())],
      child: const QuizApp(),
    ),
  );
}

class QuizApp extends StatelessWidget {
  const QuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiz App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const QuizScreen(),
    );
  }
}
