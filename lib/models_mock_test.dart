import 'dart:convert';

class Question {
  final int id;
  final String subject; // 'physics', 'chemistry', 'maths'
  final String chapter;
  final String questionText;
  final Map<String, String>? optionsList; // null for integer type
  final String correctAnswer;
  final String solution;
  final String? questionImageUrl;
  final int examYear;
  final String examShift;

  Question({
    required this.id,
    required this.subject,
    required this.chapter,
    required this.questionText,
    required this.optionsList,
    required this.correctAnswer,
    required this.solution,
    this.questionImageUrl,
    required this.examYear,
    required this.examShift,
  });

  bool get isIntegerType => optionsList == null || optionsList!.isEmpty;
  bool get isMCQType => optionsList != null && optionsList!.isNotEmpty;

factory Question.fromJson(Map<String, dynamic> json) {
  Map<String, String>? parsedOptions;
  final optionsList = json['options_list'];
  if (optionsList == null) {
    parsedOptions = null;
  } else if (optionsList is String) {
    // No post-processing needed!
    try {
      parsedOptions = Map<String, dynamic>.from(jsonDecode(optionsList))
        .map((k, v) => MapEntry(k.toString(), v.toString()));
    } catch (err) {
      parsedOptions = null;
    }
  } else if (optionsList is Map) {
    parsedOptions = (optionsList as Map).map((k, v) => MapEntry(k.toString(), v.toString()));
  } else {
    parsedOptions = null;
  }
  return Question(
    id: json['id'] as int,
    subject: json['subject'] as String,
    chapter: json['chapter'] as String,
    questionText: json['question_text'] as String,
    optionsList: parsedOptions,
    correctAnswer: json['correct_answer'] as String,
    solution: json['solution'] as String? ?? '',
    questionImageUrl: json['question_image_url'] as String?,
    examYear: json['exam_year'] as int? ?? 0,
    examShift: json['exam_shift'] as String? ?? '',
  );
}


}

// Wrap question with section info for mock test
class MockTestQuestion {
  final int globalQuestionNumber; // e.g. 1-90 in complete mock
  final Question question;
  final String section; // 'A' or 'B'
  final String subject; // 'physics', 'chemistry', 'maths'

  MockTestQuestion({
    required this.globalQuestionNumber,
    required this.question,
    required this.section,
    required this.subject,
  });
}

// User's answer state for a question inside the mock test session
class QuestionAnswer {
  final int questionId;
  final String subject;
  final String section;
  String? userAnswer;
  final String correctAnswer;
  bool isMarkedForReview;
  int marksObtained;
  DateTime? answeredAt;

  QuestionAnswer({
    required this.questionId,
    required this.subject,
    required this.section,
    this.userAnswer,
    required this.correctAnswer,
    this.isMarkedForReview = false,
    this.marksObtained = 0,
    this.answeredAt,
  });

  bool get isAnswered => userAnswer != null && userAnswer!.isNotEmpty;
  bool get isCorrect => userAnswer == correctAnswer;

  int calculateMarks() {
    if (!isAnswered) return 0;
    String normalizedUserAnswer = userAnswer!.trim();
    String normalizedCorrectAnswer = correctAnswer.trim();
    try {
      int userNum = int.parse(normalizedUserAnswer);
      int correctNum = int.parse(normalizedCorrectAnswer);
      if (userNum == correctNum) {
        marksObtained = 4;
        return 4;
      }
    } catch (e) {
      if (normalizedUserAnswer == normalizedCorrectAnswer) {
        marksObtained = 4;
        return 4;
      }
    }
    marksObtained = -1;
    return -1;
  }
}

// State holder for current mock test session
class MockTestState {
  final List<MockTestQuestion> allQuestions;
  final Map<int, QuestionAnswer> answers; // key: globalQuestionNumber
  int currentQuestionIndex;

  MockTestState({
    required this.allQuestions,
    this.answers = const {},
    this.currentQuestionIndex = 0,
  });

  MockTestQuestion get currentQuestion => allQuestions[currentQuestionIndex];
  QuestionAnswer? getCurrentAnswer() => answers[currentQuestion.globalQuestionNumber];

  MockTestState copyWith({
    List<MockTestQuestion>? allQuestions,
    Map<int, QuestionAnswer>? answers,
    int? currentQuestionIndex,
  }) {
    return MockTestState(
      allQuestions: allQuestions ?? this.allQuestions,
      answers: answers ?? this.answers,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
    );
  }
}

class MockTestResult {
  final int id;
  final String userId;
  final String testId;
  final int totalScore;
  final int physicsScore;
  final int chemistryScore;
  final int mathsScore;
  final int physicsCorrect;
  final int physicsWrong;
  final int physicsUnattempted;
  final int chemistryCorrect;
  final int chemistryWrong;
  final int chemistryUnattempted;
  final int mathsCorrect;
  final int mathsWrong;
  final int mathsUnattempted;
  final int totalQuestionsAttempted;
  final int totalCorrect;
  final int totalWrong;
  final int totalUnattempted;
  final int timeSpentSeconds;
  final int? rank;
  final double? percentile;
  final DateTime submittedAt;

  MockTestResult({
    required this.id,
    required this.userId,
    required this.testId,
    required this.totalScore,
    required this.physicsScore,
    required this.chemistryScore,
    required this.mathsScore,
    required this.physicsCorrect,
    required this.physicsWrong,
    required this.physicsUnattempted,
    required this.chemistryCorrect,
    required this.chemistryWrong,
    required this.chemistryUnattempted,
    required this.mathsCorrect,
    required this.mathsWrong,
    required this.mathsUnattempted,
    required this.totalQuestionsAttempted,
    required this.totalCorrect,
    required this.totalWrong,
    required this.totalUnattempted,
    required this.timeSpentSeconds,
    this.rank,
    this.percentile,
    required this.submittedAt,
  });

  factory MockTestResult.fromJson(Map<String, dynamic> json) {
    return MockTestResult(
      id: json['id'] as int,
      userId: json['user_id'] as String,
      testId: json['test_id'] as String,
      totalScore: json['total_score'] as int,
      physicsScore: json['physics_score'] as int,
      chemistryScore: json['chemistry_score'] as int,
      mathsScore: json['maths_score'] as int,
      physicsCorrect: json['physics_correct'] as int,
      physicsWrong: json['physics_wrong'] as int,
      physicsUnattempted: json['physics_unattempted'] as int,
      chemistryCorrect: json['chemistry_correct'] as int,
      chemistryWrong: json['chemistry_wrong'] as int,
      chemistryUnattempted: json['chemistry_unattempted'] as int,
      mathsCorrect: json['maths_correct'] as int,
      mathsWrong: json['maths_wrong'] as int,
      mathsUnattempted: json['maths_unattempted'] as int,
      totalQuestionsAttempted: json['total_questions_attempted'] as int,
      totalCorrect: json['total_correct'] as int,
      totalWrong: json['total_wrong'] as int,
      totalUnattempted: json['total_unattempted'] as int,
      timeSpentSeconds: json['time_spent_seconds'] as int,
      rank: json['rank'] as int?,
      percentile: (json['percentile'] as num?)?.toDouble(),
      submittedAt: DateTime.parse(json['submitted_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'test_id': testId,
      'total_score': totalScore,
      'physics_score': physicsScore,
      'chemistry_score': chemistryScore,
      'maths_score': mathsScore,
      'physics_correct': physicsCorrect,
      'physics_wrong': physicsWrong,
      'physics_unattempted': physicsUnattempted,
      'chemistry_correct': chemistryCorrect,
      'chemistry_wrong': chemistryWrong,
      'chemistry_unattempted': chemistryUnattempted,
      'maths_correct': mathsCorrect,
      'maths_wrong': mathsWrong,
      'maths_unattempted': mathsUnattempted,
      'total_questions_attempted': totalQuestionsAttempted,
      'total_correct': totalCorrect,
      'total_wrong': totalWrong,
      'total_unattempted': totalUnattempted,
      'time_spent_seconds': timeSpentSeconds,
    };
  }
}
