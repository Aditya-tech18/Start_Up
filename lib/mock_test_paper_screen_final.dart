import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';
import 'models_mock_test.dart';
import 'services_mock_test.dart';
import 'mock_test_result_screen.dart';

// Helper for LaTeX/Mixed Text (Paste your _buildLatexText here if needed)

// ...You can copy your _buildLatexText from above for LaTeX support...

class MockTestPaperScreen extends StatefulWidget {
  final int testId;
  MockTestPaperScreen({required this.testId});

  @override
  State<MockTestPaperScreen> createState() => _MockTestPaperScreenState();
}

class _MockTestPaperScreenState extends State<MockTestPaperScreen> {
  late MockTestService mockTestService;
  late Future<List<MockTestQuestion>> questionsFuture;
  List<MockTestQuestion> allQuestions = [];
  Map<int, QuestionAnswer> answers = {};
  int currentQuestionIndex = 0;
  int timeRemainingSeconds = 180 * 60;
  late DateTime testStartTime;
  String currentSubject = 'physics';
  bool gridPanelOpen = true;

  @override
  void initState() {
    super.initState();
    mockTestService = MockTestService(supabase: Supabase.instance.client);
    testStartTime = DateTime.now();
    questionsFuture = mockTestService.loadMockTestQuestions();
    _startTimer();
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && timeRemainingSeconds > 0) {
        setState(() {
          timeRemainingSeconds--;
        });
        _startTimer();
      } else if (timeRemainingSeconds == 0 && mounted) {
        _autoSubmitTest();
      }
    });
  }

  String _formatTime(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int secs = seconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Color _getQuestionColor(int questionNumber) {
    var answer = answers[questionNumber];
    if (answer == null) return Colors.grey[700]!;
    if (!answer.isAnswered) return Colors.grey[700]!;
    if (answer.isMarkedForReview && answer.isAnswered) return Color(0xFF00BCD4);
    if (answer.isAnswered && answer.isCorrect) return Colors.green;
    if (answer.isAnswered) return Color(0xFFFFEA00);
    return Colors.grey[700]!;
  }

  void _jumpToQuestion(int questionNumber) {
    int index = allQuestions.indexWhere((q) => q.globalQuestionNumber == questionNumber);
    if (index != -1) {
      setState(() {
        currentQuestionIndex = index;
        currentSubject = allQuestions[index].subject;
      });
    }
  }

  void _saveCurrentAnswer(String? answer, bool marked) {
    int globalQuestionNumber = allQuestions[currentQuestionIndex].globalQuestionNumber;
    var mockQ = allQuestions[currentQuestionIndex];
    answers[globalQuestionNumber] = QuestionAnswer(
      questionId: mockQ.question.id,
      subject: mockQ.subject,
      section: mockQ.section,
      userAnswer: answer,
      correctAnswer: mockQ.question.correctAnswer,
      isMarkedForReview: marked,
      answeredAt: DateTime.now(),
    );
  }

  void _goToNextQuestion() {
    if (currentQuestionIndex < allQuestions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        currentSubject = allQuestions[currentQuestionIndex].subject;
      });
    }
  }

  void _goToPreviousQuestion() {
    if (currentQuestionIndex > 0) {
      setState(() {
        currentQuestionIndex--;
        currentSubject = allQuestions[currentQuestionIndex].subject;
      });
    }
  }

  Future<void> _autoSubmitTest() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        title: Text('Time Up!'),
        content: Text('Your test time is over. Submitting automatically...'),
      ),
    );
    await Future.delayed(const Duration(seconds: 2));
    await _submitTest();
  }

  Future<void> _submitTest() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not logged in')),
        );
        return;
      }
      int timeSpent = DateTime.now().difference(testStartTime).inSeconds;
      final result = await mockTestService.submitTest(
        userId: user.id,
        answers: answers,
        allQuestions: allQuestions,
        timeSpentSeconds: timeSpent,
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => MockTestResultScreen(result: result),
        ),
      );
    } catch (e) {
      print('Error submitting test: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting test: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MockTestQuestion>>(
      future: questionsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(backgroundColor: Color(0xFF1E1E1E), body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError) {
          return Scaffold(backgroundColor: Color(0xFF1E1E1E), body: Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.white))));
        }
        allQuestions = snapshot.data ?? [];
        if (allQuestions.isEmpty) {
          return Scaffold(backgroundColor: Color(0xFF1E1E1E), body: Center(child: Text('No questions', style: TextStyle(color: Colors.white))));
        }
        var currentMockQuestion = allQuestions[currentQuestionIndex];
        var currentQuestion = currentMockQuestion.question;
        var currentAnswer = answers[currentMockQuestion.globalQuestionNumber];
        return Scaffold(
          backgroundColor: Color(0xFF1E1E1E),
          appBar: AppBar(
            title: Row(
              children: [
                Text('ExamPro', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                SizedBox(width: 20),
                Icon(Icons.access_time, color: Colors.orange),
                SizedBox(width: 5),
                Text(_formatTime(timeRemainingSeconds), style: TextStyle(color: timeRemainingSeconds < 300 ? Colors.red : Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
            backgroundColor: Color(0xFF1E1E1E),
            elevation: 0,
            actions: [
              TextButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Submit Test?'),
                      content: Text('Sure you want to submit? Cannot retake.'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _submitTest();
                          },
                          child: Text('Submit', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                },
                child: Text('Submit Test', style: TextStyle(color: Color(0xFF9C27B0), fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            ],
          ),
          body: Row(
            children: [
              Expanded(
                flex: 3,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tab row (Physics | Chemistry | Maths)
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildSubjectTab('Physics'),
                              SizedBox(width: 8),
                              _buildSubjectTab('Chemistry'),
                              SizedBox(width: 8),
                              _buildSubjectTab('Maths'),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                        // Question Header
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Color(0xFF2A2E35),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[800]!),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Question ${currentMockQuestion.globalQuestionNumber}', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: currentMockQuestion.section == 'A' ? Colors.blue : Colors.red,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text('Section ${currentMockQuestion.section}', style: TextStyle(color: Colors.white, fontSize: 12)),
                                  ),
                                  SizedBox(width: 8),
                                  Text('Marks: +4, -1', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                  SizedBox(width: 8),
                                  Text('Type: ${currentMockQuestion.section == 'A' ? 'MCQ' : 'Integer'}', style: TextStyle(color: Color(0xFFFF9800), fontSize: 12)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16),
                        // Question Text (reuse your latex widget here for better formatting)
                        Text(currentQuestion.questionText, style: TextStyle(fontSize: 16, color: Colors.white, height: 1.6)),
                        SizedBox(height: 16),
                        // Image if exists
                        if (currentQuestion.questionImageUrl != null && currentQuestion.questionImageUrl!.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => Dialog(
                                  backgroundColor: Colors.transparent,
                                  child: PhotoView(
                                    imageProvider: CachedNetworkImageProvider(currentQuestion.questionImageUrl!),
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              width: double.infinity,
                              height: 200,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.grey[900],
                              ),
                              child: CachedNetworkImage(
                                imageUrl: currentQuestion.questionImageUrl!,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                                errorWidget: (context, url, error) => Center(child: Icon(Icons.image_not_supported)),
                              ),
                            ),
                          ),
                        SizedBox(height: 24),
                        // MCQ or Integer input
                        if (currentMockQuestion.section == 'A')
                          _buildMCQOptions(currentQuestion, currentMockQuestion)
                        else
                          _buildIntegerInput(currentQuestion, currentMockQuestion),
                        SizedBox(height: 24),
                        Row(
                          children: [
                            Checkbox(
                              value: currentAnswer?.isMarkedForReview ?? false,
                              onChanged: (value) {
                                setState(() {
                                  _saveCurrentAnswer(currentAnswer?.userAnswer, value ?? false);
                                });
                              },
                              checkColor: Colors.white,
                              activeColor: Color(0xFF9C27B0),
                            ),
                            Text('Mark for Review', style: TextStyle(color: Colors.white70, fontSize: 14)),
                          ],
                        ),
                        SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: currentQuestionIndex > 0 ? _goToPreviousQuestion : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF9C27B0),
                                disabledBackgroundColor: Colors.grey[700],
                                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: Text('Previous', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                            ElevatedButton(
                              onPressed: currentQuestionIndex < allQuestions.length - 1 ? _goToNextQuestion : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF9C27B0),
                                disabledBackgroundColor: Colors.grey[700],
                                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: Text('Save & Next', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Question Grid Panel
              AnimatedContainer(
                duration: Duration(milliseconds: 300),
                width: gridPanelOpen ? 200 : 0,
                color: Color(0xFF2A2E35),
                child: Column(
                  children: [
                    // Panel Toggle Button
                    Container(
                      height: 50,
                      color: Color(0xFF1E1E1E),
                      child: Row(
                        children: [
                          Expanded(
                            child: Center(
                              child: Text(
                                '${answers.values.where((a) => a.isAnswered).length}/75',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(gridPanelOpen ? Icons.chevron_right : Icons.chevron_left, color: Color(0xFF9C27B0)),
                            onPressed: () {
                              setState(() { gridPanelOpen = !gridPanelOpen; });
                            },
                          ),
                        ],
                      ),
                    ),
                    // Questions Grid
                    Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 5,
                              crossAxisSpacing: 6,
                              mainAxisSpacing: 6,
                            ),
                            itemCount: allQuestions.length,
                            itemBuilder: (context, index) {
                              int questionNumber = allQuestions[index].globalQuestionNumber;
                              bool isCurrentQuestion = index == currentQuestionIndex;
                              Color bgColor = _getQuestionColor(questionNumber);
                              return GestureDetector(
                                onTap: () => _jumpToQuestion(questionNumber),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: isCurrentQuestion ? Color(0xFFFF9800) : bgColor,
                                    borderRadius: BorderRadius.circular(4),
                                    border: isCurrentQuestion ? Border.all(color: Colors.white, width: 2) : null,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '$questionNumber',
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSubjectTab(String subject) {
    bool isActive = currentSubject.toLowerCase() == subject.toLowerCase();
    return GestureDetector(
      onTap: () { setState(() { currentSubject = subject.toLowerCase(); }); },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Color(0xFFFF9800) : Color(0xFF2A2E35),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isActive ? Color(0xFFFF9800) : Colors.grey[800]!),
        ),
        child: Text(
          subject,
          style: TextStyle(color: isActive ? Colors.black : Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildMCQOptions(Question question, MockTestQuestion mockQuestion) {
    var currentAnswer = answers[mockQuestion.globalQuestionNumber];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: (question.optionsList?.entries ?? []).map((option) {
        String optionKey = option.key;
        String optionValue = option.value;
        bool isSelected = currentAnswer?.userAnswer == optionKey;
        return GestureDetector(
          onTap: () {
            setState(() {
              _saveCurrentAnswer(optionKey, currentAnswer?.isMarkedForReview ?? false);
            });
          },
          child: Container(
            margin: EdgeInsets.only(bottom: 12),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected ? Color(0xFF9C27B0) : Color(0xFF2A2E35),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? Color(0xFF9C27B0) : Colors.grey[800]!,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Radio<String>(
                  value: optionKey,
                  groupValue: currentAnswer?.userAnswer,
                  onChanged: (value) {
                    setState(() {
                      _saveCurrentAnswer(value, currentAnswer?.isMarkedForReview ?? false);
                    });
                  },
                  activeColor: Colors.white,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${optionKey.toUpperCase()}. $optionValue',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildIntegerInput(Question question, MockTestQuestion mockQuestion) {
    var currentAnswer = answers[mockQuestion.globalQuestionNumber];
    TextEditingController controller = TextEditingController(text: currentAnswer?.userAnswer ?? '');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Enter the Answer (Numeric):', style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500)),
        SizedBox(height: 12),
        TextField(
          controller: controller,
          keyboardType: TextInputType.numberWithOptions(signed: true, decimal: true),
          style: TextStyle(color: Colors.white, fontSize: 16),
          decoration: InputDecoration(
            hintText: 'Enter your answer',
            hintStyle: TextStyle(color: Colors.grey[700]),
            filled: true,
            fillColor: Color(0xFF2A2E35),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[800]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[800]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Color(0xFF9C27B0), width: 2),
            ),
          ),
          onChanged: (value) {
            setState(() {
              _saveCurrentAnswer(value, currentAnswer?.isMarkedForReview ?? false);
            });
          },
        ),
      ],
    );
  }
}
