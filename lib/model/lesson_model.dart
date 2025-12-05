class Lesson {
  final String id;
  final String title;
  final List<Activity> activities;

  Lesson({required this.id, required this.title, required this.activities});

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'] as String,
      title: json['title'] as String,
      activities: (json['activities'] as List)
          .map((activity) => Activity.fromJson(activity))
          .toList(),
    );
  }
}

class Activity {
  final String type;
  final String question;
  final List<String> options;
  final String answer;

  Activity({
    required this.type,
    required this.question,
    required this.options,
    required this.answer,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      type: json['type'] as String,
      question: json['question'] as String,
      options: List<String>.from(json['options']),
      answer: json['answer'] as String,
    );
  }
}
