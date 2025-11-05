// lib/services/mock_test_service.dart

import 'package:saas_new/models_mock_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'models_mock_test.dart';

class MockTestService {
  final SupabaseClient supabase;

  MockTestService({required this.supabase});

  /// Fetch random questions for a subject with split between MCQ and Integer
  Future<List<Question>> fetchQuestionsForSubject(String subject) async {
    try {
      // Fetch 20 MCQ questions (where options_list is NOT null)
      final mcqResponse = await supabase
          .from('questions')
          .select()
          .eq('subject', subject)
          .not('options_list', 'is', null)
          .limit(20)
          .order('id', ascending: false);

      // Fetch 10 Integer questions (where options_list IS null)
      final integerResponse = await supabase
          .from('questions')
          .select()
          .eq('subject', subject)
    .not('options_list', 'is', null)

          .limit(10)
          .order('id', ascending: false);

      List<Question> mcqQuestions =
          (mcqResponse as List).map((q) => Question.fromJson(q)).toList();
      List<Question> integerQuestions =
          (integerResponse as List).map((q) => Question.fromJson(q)).toList();

      // Shuffle to get random selection
      mcqQuestions.shuffle();
      integerQuestions.shuffle();

      // Take only required number and shuffle together
      List<Question> allQuestions = [
        ...mcqQuestions.take(20),
        ...integerQuestions.take(10),
      ];
      allQuestions.shuffle();

      return allQuestions;
    } catch (e) {
      print('Error fetching questions: $e');
      rethrow;
    }
  }

  /// Load all 90 questions for the test (30 per subject, 20 MCQ + 10 Integer each)
  Future<List<MockTestQuestion>> loadMockTestQuestions() async {
    try {
      List<MockTestQuestion> allQuestions = [];
      int globalQuestionNumber = 1;

      // Subjects to process
      const subjects = ['physics', 'chemistry', 'maths'];

      for (String subject in subjects) {
        final questions = await fetchQuestionsForSubject(subject);

        // Separate MCQ (Section A) and Integer (Section B)
        List<Question> sectionA = [];
        List<Question> sectionB = [];

        for (var q in questions) {
          if (q.isMCQType) {
            sectionA.add(q);
          } else {
            sectionB.add(q);
          }
        }

        // Add Section A questions
        for (var q in sectionA.take(20)) {
          allQuestions.add(MockTestQuestion(
            globalQuestionNumber: globalQuestionNumber++,
            question: q,
            section: 'A',
            subject: subject,
          ));
        }

        // Add Section B questions
        for (var q in sectionB.take(10)) {
          allQuestions.add(MockTestQuestion(
            globalQuestionNumber: globalQuestionNumber++,
            question: q,
            section: 'B',
            subject: subject,
          ));
        }
      }

      return allQuestions;
    } catch (e) {
      print('Error loading mock test questions: $e');
      rethrow;
    }
  }

  /// Submit the test and save results to database (ONLY RESULTS, NO INDIVIDUAL ANSWERS)
  Future<MockTestResult> submitTest({
    required String userId,
    required Map<int, QuestionAnswer> answers,
    required List<MockTestQuestion> allQuestions,
    required int timeSpentSeconds,
  }) async {
    try {
      // Calculate scores and statistics
      int totalScore = 0;
      int physicsScore = 0, chemistryScore = 0, mathsScore = 0;
      int physicsCorrect = 0, physicsWrong = 0, physicsUnattempted = 0;
      int chemistryCorrect = 0, chemistryWrong = 0, chemistryUnattempted = 0;
      int mathsCorrect = 0, mathsWrong = 0, mathsUnattempted = 0;
      int totalCorrect = 0, totalWrong = 0, totalUnattempted = 0;

      for (var mockQ in allQuestions) {
        var answer = answers[mockQ.globalQuestionNumber];

        if (answer == null || !answer.isAnswered) {
          // Unanswered
          totalUnattempted++;
          if (mockQ.subject == 'physics') physicsUnattempted++;
          if (mockQ.subject == 'chemistry') chemistryUnattempted++;
          if (mockQ.subject == 'maths') mathsUnattempted++;
        } else {
          // Answered
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

      // Insert into mock_test_results ONLY (no individual answers table)
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

  /// Fetch all previous test results for a user
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

  /// Fetch specific test result
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
