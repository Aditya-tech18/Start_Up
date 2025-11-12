import 'package:saas_new/models_mock_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockTestService {
  final SupabaseClient supabase;

  MockTestService({required this.supabase});

  /// Fetches ONLY questions for 2025 2 April shift 2
  Future<List<Question>> fetchApril2Shift2Questions() async {
    final response = await supabase
        .from('questions')
        .select()
        .like('id', '2025242%')
        .order('id', ascending: true);

    return (response as List)
        .map((q) => Question.fromJson(q))
        .toList();
  }

  /// If you still want to support classic random subject-logic:
  Future<List<Question>> fetchQuestionsForSubject(String subject) async {
    try {
      // 20 MCQ (options_list NOT null)
      final mcqResponse = await supabase
          .from('questions')
          .select()
          .eq('subject', subject)
          .not('options_list', 'is', null)
          .limit(20)
          .order('id', ascending: false);

      // 10 Integer (options_list IS null)
      final integerResponse = await supabase
          .from('questions')
          .select()
          .eq('subject', subject)
  .filter('options_list', 'is', null)

          .limit(10)
          .order('id', ascending: false);

      List<Question> mcqQuestions =
          (mcqResponse as List).map((q) => Question.fromJson(q)).toList();
      List<Question> integerQuestions =
          (integerResponse as List).map((q) => Question.fromJson(q)).toList();

      mcqQuestions.shuffle();
      integerQuestions.shuffle();
      List<Question> allQuestions = [
        ...mcqQuestions.take(20),
        ...integerQuestions.take(10)
      ];
      allQuestions.shuffle();

      return allQuestions;
    } catch (e) {
      print('Error fetching questions: $e');
      rethrow;
    }
  }

  /// Loads all mock test questions for REAL exam (here: ONLY Shift 2 April 2025)
  Future<List<MockTestQuestion>> loadMockTestQuestions() async {
    try {
      List<Question> all = await fetchApril2Shift2Questions();
      List<MockTestQuestion> result = [];
      int qnum = 1;
      for (var q in all) {
        // Suppose section is A for first 20, B for next 10, repeat for each subject or whatever rule you want.
        String section = (qnum % 30 <= 20 && qnum % 30 != 0) ? 'A' : 'B';
        result.add(MockTestQuestion(
          globalQuestionNumber: qnum,
          question: q,
          section: section,
          subject: q.subject,
        ));
        qnum++;
      }
      return result;
    } catch (e) {
      print('Error loading mock test questions: $e');
      rethrow;
    }
  }

  /// Submit the test (NO answer sheet, only final result details)
  Future<MockTestResult> submitTest({
    required String userId,
    required Map<int, QuestionAnswer> answers,
    required List<MockTestQuestion> allQuestions,
    required int timeSpentSeconds,
  }) async {
    try {
      int totalScore = 0;
      int physicsScore = 0, chemistryScore = 0, mathsScore = 0;
      int physicsCorrect = 0, physicsWrong = 0, physicsUnattempted = 0;
      int chemistryCorrect = 0, chemistryWrong = 0, chemistryUnattempted = 0;
      int mathsCorrect = 0, mathsWrong = 0, mathsUnattempted = 0;
      int totalCorrect = 0, totalWrong = 0, totalUnattempted = 0;

      for (var mockQ in allQuestions) {
        var answer = answers[mockQ.globalQuestionNumber];

        if (answer == null || !answer.isAnswered) {
          totalUnattempted++;
          if (mockQ.subject == 'physics') physicsUnattempted++;
          if (mockQ.subject == 'chemistry') chemistryUnattempted++;
          if (mockQ.subject == 'maths') mathsUnattempted++;
        } else {
          int marks = answer.calculateMarks();
          totalScore += marks;

          if (mockQ.subject == 'physics') {
            physicsScore += marks;
            if (marks == 4) physicsCorrect++;
            else physicsWrong++;
          }
          if (mockQ.subject == 'chemistry') {
            chemistryScore += marks;
            if (marks == 4) chemistryCorrect++;
            else chemistryWrong++;
          }
          if (mockQ.subject == 'maths') {
            mathsScore += marks;
            if (marks == 4) mathsCorrect++;
            else mathsWrong++;
          }
          if (marks == 4) totalCorrect++;
          else totalWrong++;
        }
      }

      int totalAttempted = totalCorrect + totalWrong;

      final resultResponse = await supabase
          .from('mock_test_results')
          .insert({
            'user_id': userId,
            'test_id': 'mock_test_1',
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
            'total_questions_attempted': totalAttempted,
            'total_correct': totalCorrect,
            'total_wrong': totalWrong,
            'total_unattempted': totalUnattempted,
            'time_spent_seconds': timeSpentSeconds,
          })
          .select()
          .single();

      int resultId = resultResponse['id'] as int;

      return MockTestResult(
        id: resultId,
        userId: userId,
        testId: 'mock_test_1',
        totalScore: totalScore,
        physicsScore: physicsScore,
        chemistryScore: chemistryScore,
        mathsScore: mathsScore,
        physicsCorrect: physicsCorrect,
        physicsWrong: physicsWrong,
        physicsUnattempted: physicsUnattempted,
        chemistryCorrect: chemistryCorrect,
        chemistryWrong: chemistryWrong,
        chemistryUnattempted: chemistryUnattempted,
        mathsCorrect: mathsCorrect,
        mathsWrong: mathsWrong,
        mathsUnattempted: mathsUnattempted,
        totalQuestionsAttempted: totalAttempted,
        totalCorrect: totalCorrect,
        totalWrong: totalWrong,
        totalUnattempted: totalUnattempted,
        timeSpentSeconds: timeSpentSeconds,
        submittedAt: DateTime.now(),
      );
    } catch (e) {
      print('Error submitting test: $e');
      rethrow;
    }
  }

  Future<List<MockTestResult>> fetchUserTestResults(String userId) async {
    try {
      final response = await supabase
          .from('mock_test_results')
          .select()
          .eq('user_id', userId)
          .order('submitted_at', ascending: false);

      return (response as List)
          .map((r) => MockTestResult.fromJson(r))
          .toList();
    } catch (e) {
      print('Error fetching test results: $e');
      rethrow;
    }
  }

  Future<MockTestResult?> fetchTestResult(int resultId) async {
    try {
      final resultResponse = await supabase
          .from('mock_test_results')
          .select()
          .eq('id', resultId)
          .single();

      return MockTestResult.fromJson(resultResponse);
    } catch (e) {
      print('Error fetching test result: $e');
      return null;
    }
  }
}
