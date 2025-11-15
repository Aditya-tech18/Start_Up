import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'models_mock_test.dart';
import 'mock_test_result_screen.dart';

class MockTestPaperScreen extends StatefulWidget {
  const MockTestPaperScreen({Key? key}) : super(key: key);

  @override
  State<MockTestPaperScreen> createState() => _MockTestPaperScreenState();
}

class _MockTestPaperScreenState extends State<MockTestPaperScreen> {
  final List<String> _subjects = ['Physics', 'Chemistry', 'Mathematics'];
  String _currentSubject = 'Physics';
  String _currentSection = 'A'; // 'A' = MCQ (20 Qs), 'B' = Integer (10 Qs)
  int _currentQuestionIndex = 0;

  Map<String, Map<String, List<Question>>> _questions = {};
  Map<String, Map<String, List<QuestionAnswer?>>> _answers = {};
  Map<String, Map<String, List<String?>>> _selectedAnswers = {};
  Map<String, Set<int>> _sectionBSelected = {};

  bool _isLoading = true;
  String? _errorMessage;
  bool _testSubmitted = false;
  String _userAnswer = '';
  bool _isMarkedForReview = false;

  String? _currentUserId;
  String? _currentUserEmail;

  late DateTime _testStartTime;
  int _timeRemainingSeconds = 3 * 60 * 60;
  bool _timerRunning = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    _timerRunning = false;
    super.dispose();
  }

  Future<void> _getCurrentUser() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        _currentUserId = user.id;
        _currentUserEmail = user.email;
      }
    } catch (e) {}
  }

  void _initializeData() {
    for (final subject in _subjects) {
      _questions[subject] = {'A': [], 'B': []};
      _answers[subject] = {
        'A': List.generate(20, (_) => null),
        'B': List.generate(10, (_) => null),
      };
      _sectionBSelected[subject] = <int>{};
      _selectedAnswers[subject] = {
        'A': List.generate(20, (_) => null),
        'B': List.generate(10, (_) => null),
      };
    }
    _getCurrentUser().then((_) {
      _fetchQuestionsFromSupabase();
    });
  }

  Future<void> _fetchQuestionsFromSupabase() async {
    try {
      final response = await Supabase.instance.client
          .from('questions')
          .select()
          .gte('id', 202524200)
          .lte('id', 202524999)
          .order('id', ascending: true);

      if (response == null || response is! List || response.isEmpty) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'No questions found for this exam';
        });
        return;
      }

      List<Question> allQuestions = (response as List)
          .map((json) {
        try {
          return Question.fromJson(json);
        } catch (e) {
          return null;
        }
      }).whereType<Question>().toList();

      for (final subject in _subjects) {
        List<Question> subjectQuestions = allQuestions
            .where((q) => q.subject.toLowerCase() == subject.toLowerCase())
            .toList();
        List<Question> sectionAQuestions = subjectQuestions
            .where((q) => q.optionsList != null && q.optionsList!.isNotEmpty)
            .toList();
        List<Question> sectionBQuestions = subjectQuestions
            .where((q) => q.optionsList == null || q.optionsList!.isEmpty)
            .toList();
        _questions[subject]!['A'] = sectionAQuestions.take(20).toList();
        _questions[subject]!['B'] = sectionBQuestions.take(10).toList();
      }
      setState(() {
        _isLoading = false;
      });
      _startTimer();
    } catch (e, stackTrace) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error: $e';
      });
    }
  }

  void _startTimer() {
    _testStartTime = DateTime.now();
    Future.doWhile(() async {
      if (!_timerRunning || _testSubmitted) return false;
      await Future.delayed(const Duration(seconds: 1));
      if (mounted && _timeRemainingSeconds > 0) {
        setState(() {
          _timeRemainingSeconds--;
        });
        return true;
      } else if (_timeRemainingSeconds <= 0 && mounted && !_testSubmitted) {
        _autoSubmitTest();
        return false;
      }
      return false;
    });
  }

  String _formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  // ...rest of the logic will be in the next part!
  void _goToQuestion(int index) {
    setState(() {
      _currentQuestionIndex = index;
      if (_answers[_currentSubject]![_currentSection]![index] != null) {
        String savedAnswer =
            _answers[_currentSubject]![_currentSection]![index]!.userAnswer ?? '';
        _selectedAnswers[_currentSubject]![_currentSection]![index] =
            savedAnswer.isNotEmpty ? savedAnswer : null;
        _isMarkedForReview =
            _answers[_currentSubject]![_currentSection]![index]!.isMarkedForReview;
        if (_currentSection == 'B') {
          _userAnswer = savedAnswer;
        }
      } else {
        _selectedAnswers[_currentSubject]![_currentSection]![index] = null;
        _isMarkedForReview = false;
        _userAnswer = '';
      }
    });
  }

  void _nextQuestion() {
    final currentQuestions = _questions[_currentSubject]![_currentSection]!;
    String? selectedButNotSaved =
        _selectedAnswers[_currentSubject]![_currentSection]![_currentQuestionIndex];
    bool isSaved = _answers[_currentSubject]![_currentSection]![_currentQuestionIndex] != null;

    if (selectedButNotSaved != null && !isSaved) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('⚠️ Answer Not Saved'),
          content: const Text(
              'You selected an option but didn\'t save it. Do you want to go to next question?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Go Back & Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                if (_currentQuestionIndex < currentQuestions.length - 1) {
                  _goToQuestion(_currentQuestionIndex + 1);
                }
              },
              child: const Text('Skip Without Saving'),
            ),
          ],
        ),
      );
    } else {
      if (_currentQuestionIndex < currentQuestions.length - 1) {
        _goToQuestion(_currentQuestionIndex + 1);
      }
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      _goToQuestion(_currentQuestionIndex - 1);
    }
  }

  void _switchSubject(String subject) {
    setState(() {
      _currentSubject = subject;
      _currentSection = 'A';
      _currentQuestionIndex = 0;
      _userAnswer = '';
      _isMarkedForReview = false;
    });
  }

  void _switchSection(String section) {
    setState(() {
      _currentSection = section;
      _currentQuestionIndex = 0;
      _userAnswer = '';
      _isMarkedForReview = false;
    });
  }

void _toggleMarkForReview() {
  setState(() {
    _isMarkedForReview = !_isMarkedForReview;
    // This part ensures answer object always exists if marked for review
    if (_answers[_currentSubject]![_currentSection]![_currentQuestionIndex] == null) {
      _answers[_currentSubject]![_currentSection]![_currentQuestionIndex] = QuestionAnswer(
        questionId: _currentQuestionIndex,
        subject: _currentSubject,
        section: _currentSection,
        userAnswer: '', // No answer
        isMarkedForReview: _isMarkedForReview,
        marksObtained: 0,
        answeredAt: null,
      );
    } else {
      _answers[_currentSubject]![_currentSection]![_currentQuestionIndex]!
          .isMarkedForReview = _isMarkedForReview;
    }
  });
}


void _saveCurrentAnswer() {
  String? selectedAnswer;
  if (_currentSection == 'A') {
    selectedAnswer = _selectedAnswers[_currentSubject]![_currentSection]![_currentQuestionIndex];
  } else {
    selectedAnswer = _userAnswer.isNotEmpty ? _userAnswer : null;
  }
  if (selectedAnswer == null || selectedAnswer.isEmpty) {
    // Simply return without showing any notification
    return;
  }
  final answerObj = QuestionAnswer(
    questionId: _currentQuestionIndex,
    subject: _currentSubject,
    section: _currentSection,
    userAnswer: selectedAnswer,
    correctAnswer: '',
    isMarkedForReview: _isMarkedForReview,
    marksObtained: 0,
    answeredAt: DateTime.now(),
  );
  setState(() {
    _answers[_currentSubject]![_currentSection]![_currentQuestionIndex] = answerObj;
  });
}
  void _selectIntegerQuestion(int index) {
    final selected = _sectionBSelected[_currentSubject]!;
    if (selected.length < 5 || selected.contains(index)) {
      setState(() {
        if (selected.contains(index)) {
          selected.remove(index);
        } else {
          selected.add(index);
        }
      });
    }
  }

  Future<void> _autoSubmitTest() async {
    _timerRunning = false;
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('⏰ Time Up!'),
        content: const Text('Your test time has ended. Submitting automatically...'),
        actions: [],
      ),
    );
    await Future.delayed(const Duration(seconds: 2));
    await _submitMockTest();
  }

  void _showSubmitDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('✅ Submit Test?'),
        content: const Text('Are you sure you want to submit the test and exit?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _submitMockTest();
            },
            child: const Text('Yes, Submit'),
          ),
        ],
      ),
    );
  }
  Future<void> _submitMockTest() async {
    _timerRunning = false;

    // Subject-wise analytics (JEE +4, -1)
    int physicsScore = 0, chemistryScore = 0, mathsScore = 0;
    int physicsCorrect = 0, chemistryCorrect = 0, mathsCorrect = 0;
    int physicsWrong = 0, chemistryWrong = 0, mathsWrong = 0;
    int physicsUnattempted = 0, chemistryUnattempted = 0, mathsUnattempted = 0;

    int totalCorrect = 0, totalWrong = 0, totalUnattempted = 0, totalAttempted = 0;

    for (final subject in _subjects) {
      int correct = 0, wrong = 0, unattempted = 0;
      List<String> sections = ['A', 'B'];
      for (final section in sections) {
        final answers = _answers[subject]![section]!;
        final questions = _questions[subject]![section]!;
        for (int i = 0; i < answers.length && i < questions.length; i++) {
          final ans = answers[i];
          final correctAns = (questions[i].correctAnswer?.trim() ?? "");
          final userAns = ans?.userAnswer?.trim() ?? "";
          if (userAns.isEmpty) {
            unattempted++;
          } else if (userAns == correctAns) {
            correct++;
          } else {
            wrong++;
          }
        }
      }
      int score = (correct * 4) - wrong;
      if (subject == "Physics") {
        physicsScore = score;
        physicsCorrect = correct;
        physicsWrong = wrong;
        physicsUnattempted = unattempted;
      } else if (subject == "Chemistry") {
        chemistryScore = score;
        chemistryCorrect = correct;
        chemistryWrong = wrong;
        chemistryUnattempted = unattempted;
      } else if (subject == "Maths") {
        mathsScore = score;
        mathsCorrect = correct;
        mathsWrong = wrong;
        mathsUnattempted = unattempted;
      }
      totalCorrect += correct;
      totalWrong += wrong;
      totalUnattempted += unattempted;
      totalAttempted += correct + wrong;
    }

    int totalScore = physicsScore + chemistryScore + mathsScore;

    setState(() {
      _testSubmitted = true;
    });

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MockTestResultScreen(
            result: MockTestResult(
              id: 0,
              userId: _currentUserId ?? 'unknown',
              testId: 'mock_2025_jee_main',
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
              timeSpentSeconds:
                  DateTime.now().difference(_testStartTime).inSeconds,
              submittedAt: DateTime.now(),
              percentile: null,
            ),
          ),
        ),
      );
    }
  }
  // ========== UI ==========

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF161b22),
        appBar: AppBar(
          title: const Text('JEE Main Mock Test 2025'),
          backgroundColor: const Color(0xFF1E1E1E),
        ),
        body: const Center(
          child: CircularProgressIndicator(color: Colors.orange),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: const Color(0xFF161b22),
        appBar: AppBar(
          title: const Text('Error'),
          backgroundColor: const Color(0xFF1E1E1E),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _errorMessage = null;
                  });
                  _fetchQuestionsFromSupabase();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    final currentQuestions =
        _questions[_currentSubject]![_currentSection] ?? [];
    if (currentQuestions.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFF161b22),
        body: const Center(
          child: Text('No questions available',
              style: TextStyle(color: Colors.white)),
        ),
      );
    }
    final currentQuestion = currentQuestions[_currentQuestionIndex];

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: const Color(0xFF161b22),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1E1E1E),
          elevation: 0,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$_currentSubject - Section $_currentSection',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Row(
                children: [
                  Icon(Icons.timer,
                      color: _timeRemainingSeconds < 600 ? Colors.red : Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    _formatTime(_timeRemainingSeconds),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color:
                          _timeRemainingSeconds < 600 ? Colors.red : Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            // Subject tabs
            Container(
              color: const Color(0xFF1E1E1E),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _subjects.map((subject) {
                  bool isSelected = _currentSubject == subject;
                  return GestureDetector(
                    onTap: () => _switchSubject(subject),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding:
                          const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.orange : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? Colors.orange : Colors.white30,
                        ),
                      ),
                      child: Text(
                        subject,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            // Section Tabs
            Container(
              color: const Color(0xFF1E1E1E),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: ['A', 'B'].map((section) {
                  bool isSelected = _currentSection == section;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: GestureDetector(
                      onTap: () => _switchSection(section),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 6, horizontal: 20),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.orange : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.orange),
                        ),
                        child: Text(
                          'Section $section',
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.orange,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
            // Dashboard, Question, Options/Input, Mark, Navigation...
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildQuestionDashboard(),
                      const SizedBox(height: 24),

                      _buildQuestionCard(currentQuestion),
                      const SizedBox(height: 20),

                      if (_currentSection == 'A')
                        _buildMCQOptions(currentQuestion)
                      else
                        _buildIntegerInput(currentQuestion),

                      const SizedBox(height: 24),
                      if (!_testSubmitted) _buildMarkForReviewCheckbox(),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),

            if (!_testSubmitted) _buildBottomNavigationBar(currentQuestions.length),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionDashboard() {
    final questionCount = _currentSection == 'A' ? 20 : 10;
    final attemptedCount = _getAttemptedCount();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Attempted: $attemptedCount / $questionCount',
            style: const TextStyle(
              color: Colors.orange,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: 8,
              mainAxisSpacing: 10,
            ),
            itemCount: questionCount,
            itemBuilder: (context, index) {
              Color tileColor = _getQuestionTileColor(index);
              bool isCurrentQuestion = _currentQuestionIndex == index;
              return GestureDetector(
                onTap: () => _goToQuestion(index),
                child: Container(
                  decoration: BoxDecoration(
                    color: tileColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isCurrentQuestion ? Colors.yellow : Colors.transparent,
                      width: isCurrentQuestion ? 3 : 1,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

Widget _buildQuestionCard(Question question) {
  // Remove option lines like (1) ... (2) ... at the end of questionText if present
  String cleanQuestionText = question.questionText;
  final optRegex = RegExp(r'(\(?[1-4]\)?\.?\s?.+?)(?=(\(?[2-4]\)?\.?\s))', dotAll: true); // Handles "(1)" or "1)" or "1."
  // Remove all lines that look like options at the END (and after 'is:'/etc, to preserve main question)
  if (question.optionsList != null && question.optionsList!.isNotEmpty) {
    // Remove from last 'is:' to end if options are present
    int idx = cleanQuestionText.lastIndexOf('is:');
    if (idx != -1) {
      cleanQuestionText = cleanQuestionText.substring(0, idx + 3).replaceAll('\\n', '\n').trim();
    } else {
      // fallback: remove from first (1), (A), etc if found late in question
      for (final k in question.optionsList!.keys) {
        final pattern = '($k)';
        final lastIdx = cleanQuestionText.lastIndexOf(pattern);
        if (lastIdx > 20) {
          cleanQuestionText = cleanQuestionText.substring(0, lastIdx).replaceAll('\\n', '\n').trim();
          break;
        }
      }
    }
  }

  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFF1E1E1E),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.white12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Q${_currentQuestionIndex + 1}',
              style: const TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            Text(
              '${question.examYear} | ${question.examShift}',
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 11,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildLatexText(cleanQuestionText, fontSize: 16, color: Colors.white),
        if (question.questionImageUrl != null && question.questionImageUrl!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Image.network(
              question.questionImageUrl!,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.white24),
            ),
          ),
      ],
    ),
  );
}


Widget _buildMCQOptions(Question question) {
  // Debug print to check what is actually fetched
  print('Question options: ${question.optionsList}');

  if (question.optionsList == null || question.optionsList!.isEmpty) {
    return const SizedBox.shrink();
  }

  String? savedAnswer = _selectedAnswers[_currentSubject]![_currentSection]![_currentQuestionIndex];

  String toLaTeX(String txt) {
    // Convert ALL a/b (like 3/8, 1/2, 3/2, etc.) to LaTeX fractions
    txt = txt.replaceAllMapped(
      RegExp(r'(\d+)\s*/\s*(\d+)'),
      (m) => '\\frac{${m[1]}}{${m[2]}}',
    );
    // Convert pi to LaTeX symbol
    txt = txt.replaceAllMapped(
      RegExp(r'(?<!\\)pi'),
      (m) => r'\pi'
    );
    // Always wrap in $...$ for correct parsing
    if (!txt.startsWith(r'$')) txt = '\$$txt\$';
    return txt;
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Select your answer:',
        style: TextStyle(
          color: Colors.orange,
          fontWeight: FontWeight.bold,
          fontSize: 17,
        ),
      ),
      const SizedBox(height: 16),
      ...question.optionsList!.entries.map((entry) {
        String optionKey = entry.key;
        String optionValue = entry.value.trim();
        bool isImage = optionValue.startsWith('http') &&
          (optionValue.endsWith('.png') ||
           optionValue.endsWith('.jpg') ||
           optionValue.endsWith('.jpeg'));
        bool isSelected = savedAnswer == optionKey;

        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedAnswers[_currentSubject]![_currentSection]![_currentQuestionIndex] = optionKey;
              });
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF32291A) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? Colors.orange : Colors.grey[700]!,
                  width: isSelected ? 2.1 : 1.2,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '(${optionKey}) ',
                    style: const TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                  Flexible(
                    child: isImage
                      ? Image.network(
                          optionValue,
                          fit: BoxFit.contain,
                          height: 45,
                        )
                      : _buildLatexText(
                          toLaTeX(optionValue),
                          fontSize: 17,
                          color: Colors.white,
                        ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    ],
  );
}







  Widget _buildIntegerInput(Question question) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white12),
          ),
          child: Row(
            children: [
              const Text('Answer: ',
                  style: TextStyle(color: Colors.white70, fontSize: 16)),
              Expanded(
                child: TextField(
                  controller: TextEditingController(text: _userAnswer),
                  onChanged: (value) {
                    setState(() {
                      _userAnswer = value;
                      _selectedAnswers[_currentSubject]![_currentSection]![_currentQuestionIndex] = value;
                    });
                  },
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                    color: Colors.yellow,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter integer',
                    hintStyle: const TextStyle(color: Colors.white30),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMarkForReviewCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: _isMarkedForReview,
          onChanged: (_) => _toggleMarkForReview(),
          activeColor: Colors.orange,
        ),
        const Text(
          'Mark for Review',
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
        const Spacer(),
        ElevatedButton.icon(
          onPressed: _showSubmitDialog,
          icon: const Icon(Icons.check_circle),
          label: const Text('Submit'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
          ),
        ),
      ],
    );
  }

Widget _buildBottomNavigationBar(int totalQuestions) {
  final isLastQuestion = _currentQuestionIndex == totalQuestions - 1;
  final isFirstQuestion = _currentQuestionIndex == 0;

  TextStyle labelStyle = const TextStyle(
    fontSize: 15, // Reduced font size for better fit
    fontWeight: FontWeight.w600,
    color: Colors.white,
    overflow: TextOverflow.ellipsis,
  );

  return SafeArea(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        border: const Border(top: BorderSide(color: Colors.white12)),
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: !isFirstQuestion ? _previousQuestion : null,
              icon: const Icon(Icons.arrow_back, size: 20),
              label: FittedBox(
                child: Text('Previous', maxLines: 1, style: labelStyle),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800],
                disabledBackgroundColor: Colors.grey[900],
                minimumSize: const Size(0, 52),
                padding: const EdgeInsets.symmetric(horizontal: 2),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _toggleMarkForReview,
              icon: Icon(
                _isMarkedForReview ? Icons.bookmark : Icons.bookmark_border,
                size: 20,
              ),
              label: FittedBox(
                child: Text('Mark', maxLines: 1, style: labelStyle),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                minimumSize: const Size(0, 52),
                padding: const EdgeInsets.symmetric(horizontal: 2),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                _saveCurrentAnswer();
                if (!isLastQuestion) _nextQuestion();
                else _showSubmitDialog();
              },
              icon: Icon(
                isLastQuestion ? Icons.check_circle : Icons.save,
                size: 20,
              ),
              label: FittedBox(
                child: Text(
                  isLastQuestion ? 'Submit' : 'Save & Next',
                  maxLines: 1,
                  style: labelStyle,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isLastQuestion ? Colors.red : Colors.green,
                minimumSize: const Size(0, 52),
                padding: const EdgeInsets.symmetric(horizontal: 2),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Color _getQuestionTileColor(int index) {
  final answer = _answers[_currentSubject]![_currentSection]![index];
  if (answer != null && answer.isMarkedForReview) {
    return Colors.purple;
  }
  if (answer != null && answer.isAnswered) {
    return Colors.green;
  }
  return Colors.grey[700]!;
}

  int _getAttemptedCount() {
    int count = 0;
    final answers = _answers[_currentSubject]![_currentSection];
    for (final ans in answers!) {
      if (ans != null && ans.isAnswered) count++;
    }
    return count;
  }

Widget _buildLatexText(String text, {double fontSize = 16, Color color = Colors.white}) {
  if (text.isEmpty) {
    return Text('', style: TextStyle(fontSize: fontSize, color: color));
  }
  List<InlineSpan> spans = [];
  int currentIndex = 0;
  final blockMathRegex = RegExp(r'\$\$(.+?)\$\$', dotAll: true);
  final blockMatches = blockMathRegex.allMatches(text).toList();
  List<int> blockMathPositions = [];
  for (var match in blockMatches) {
    blockMathPositions.add(match.start);
    blockMathPositions.add(match.end);
  }
  while (currentIndex < text.length) {
    bool isBlockMath = false;
    for (var match in blockMatches) {
      if (currentIndex == match.start) {
        isBlockMath = true;
        String mathContent = match.group(1)!.trim();
        if (mathContent.contains('\\\\')) {
          mathContent = mathContent.replaceAll('\\\\', '\\');
        }
        try {
          spans.add(WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Math.tex(
                mathContent,
                textStyle: TextStyle(fontSize: fontSize + 2, color: color),
              ),
            ),
          ));
        } catch (e) {
          spans.add(TextSpan(
              text: '[Math Error]',
              style: TextStyle(fontSize: fontSize - 2, color: Colors.red)));
        }
        currentIndex = match.end;
        break;
      }
    }
    if (isBlockMath) continue;
    int nextDollar = text.indexOf(r'$', currentIndex);
    if (nextDollar == -1) {
      if (currentIndex < text.length) {
        spans.add(TextSpan(
            text: text.substring(currentIndex),
            style: TextStyle(fontSize: fontSize, color: color)));
      }
      break;
    }
    if (nextDollar > currentIndex) {
      spans.add(TextSpan(
          text: text.substring(currentIndex, nextDollar),
          style: TextStyle(fontSize: fontSize, color: color)));
    }
    bool skipThisDollar = false;
    for (int pos in blockMathPositions) {
      if (nextDollar == pos || nextDollar == pos - 1) {
        skipThisDollar = true;
        break;
      }
    }
    if (skipThisDollar) {
      currentIndex = nextDollar + 1;
      continue;
    }
    int closingDollar = text.indexOf(r'$', nextDollar + 1);
    if (closingDollar == -1) {
      spans.add(TextSpan(
          text: text.substring(nextDollar),
          style: TextStyle(fontSize: fontSize, color: color)));
      break;
    }
    String mathContent = text.substring(nextDollar + 1, closingDollar).trim();
    if (mathContent.isNotEmpty) {
      if (mathContent.contains('\\\\')) {
        mathContent = mathContent.replaceAll('\\\\', '\\');
      }
      try {
        spans.add(WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Math.tex(
              mathContent,
              textStyle: TextStyle(fontSize: fontSize, color: color),
            ),
          ),
        ));
      } catch (e) {
        spans.add(TextSpan(
            text: '[Math Error]',
            style: TextStyle(fontSize: fontSize - 2, color: Colors.red)));
      }
    }
    currentIndex = closingDollar + 1;
  }
  if (spans.isEmpty) {
    return Text(text, style: TextStyle(fontSize: fontSize, color: color));
  }
  return RichText(
    text: TextSpan(children: spans),
    softWrap: true,
    overflow: TextOverflow.visible,
  );
}


}

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
    this.correctAnswer = '',
    this.isMarkedForReview = false,
    this.marksObtained = 0,
    this.answeredAt,
  });

  factory QuestionAnswer.empty() {
    return QuestionAnswer(
      questionId: -1,
      subject: '',
      section: '',
    );
  }

  bool get isAnswered => userAnswer != null && userAnswer!.isNotEmpty;
  bool get isCorrect => userAnswer == correctAnswer;
}
