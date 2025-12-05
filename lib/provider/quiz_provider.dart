import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../model/lesson_model.dart';

class QuizProvider extends ChangeNotifier {
  Lesson? _lesson;
  String? _selectedAnswer;
  bool _hasAnswered = false;
  bool _isLoading = true;

  // Getters
  Lesson? get lesson => _lesson;
  String? get selectedAnswer => _selectedAnswer;
  bool get hasAnswered => _hasAnswered;
  bool get isLoading => _isLoading;

  QuizProvider() {
    loadLesson();
  }

  Future<void> loadLesson() async {
    try {
      _isLoading = true;
      final String jsonString = await rootBundle.loadString(
        'assets/lesson.json',
      );
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      _lesson = Lesson.fromJson(jsonData);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Error loading lesson: $e');
    }
  }

  void handleAnswer(String answer) {
    if (!_hasAnswered) {
      _selectedAnswer = answer;
      _hasAnswered = true;
      notifyListeners();
    }
  }

  void resetQuiz() {
    _selectedAnswer = null;
    _hasAnswered = false;
    notifyListeners();
  }

  Color getOptionColor(String option) {
    if (!_hasAnswered) {
      return Colors.grey.shade200;
    }

    final correctAnswer = _lesson!.activities[0].answer;

    if (option == correctAnswer) {
      return Colors.green.shade100;
    } else if (option == _selectedAnswer) {
      return Colors.red.shade100;
    }

    return Colors.grey.shade200;
  }

  IconData? getOptionIcon(String option) {
    if (!_hasAnswered) return null;

    final correctAnswer = _lesson!.activities[0].answer;

    if (option == correctAnswer) {
      return Icons.check_circle;
    } else if (option == _selectedAnswer) {
      return Icons.cancel;
    }

    return null;
  }

  Color? getOptionIconColor(String option) {
    if (!_hasAnswered) return null;

    final correctAnswer = _lesson!.activities[0].answer;

    if (option == correctAnswer) {
      return Colors.green;
    } else if (option == _selectedAnswer) {
      return Colors.red;
    }

    return null;
  }
}
