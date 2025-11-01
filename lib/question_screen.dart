import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';

// --- DATA STRUCTURE FOR A SINGLE QUESTION ---
class PyqQuestion {
  final int id;
  final String chapter;
  final String subject;
  final int year;
  final String shift;
  final String text;
  final Map<String, String> options;
  final String correctAnswer;
  final String solution;
  final String? questionImageUrl;

  
  const PyqQuestion({
    required this.id,
    required this.chapter,
    required this.subject,
    required this.year,
    required this.shift,
    required this.text,
    required this.options,
    required this.correctAnswer,
    required this.solution,
    this.questionImageUrl,   
  });

  factory PyqQuestion.fromJson(Map<String, dynamic> json) {
    Map<String, String> parsedOptions = {};
    
    try {
      var optionsList = json['options_list'];
      
      print('═══════════════════════════════════════');
      print('📝 Question ID: ${json['id']}');
      print('📝 options_list type: ${optionsList.runtimeType}');
      
      if (optionsList == null) {
        print('❌ options_list is NULL');
      } else if (optionsList is String) {
        if (optionsList.isEmpty) {
          print('❌ options_list is EMPTY');
        } else {
          print('📝 Raw string length: ${optionsList.length}');
          print('📝 First 200 chars: ${optionsList.substring(0, optionsList.length > 200 ? 200 : optionsList.length)}');
          
          try {
            Map<String, dynamic> optionsJson = jsonDecode(optionsList);
            parsedOptions = optionsJson.map((key, value) => MapEntry(key, value.toString()));
            print('✅ SUCCESS: Parsed ${parsedOptions.length} options');
            parsedOptions.forEach((key, value) {
              print('   Option $key: ${value.substring(0, value.length > 50 ? 50 : value.length)}...');
            });
          } catch (e) {
            print('❌ jsonDecode error: $e');
            print('💡 Trying to check if the string is already valid JSON...');
          }
        }
      } else if (optionsList is Map) {
        parsedOptions = (optionsList as Map).map((key, value) => MapEntry(key.toString(), value.toString()));
        print('✅ Converted Map: ${parsedOptions.length} options');
      }
      
      print('═══════════════════════════════════════');
      
    } catch (e, stackTrace) {
      print('❌❌❌ FATAL ERROR: $e');
      print('Stack: $stackTrace');
    }
    
    return PyqQuestion(
      id: json['id'] ?? 0,
      chapter: json['chapter'] ?? '',
      subject: json['subject'] ?? '',
      year: json['exam_year'] ?? 2024,
      shift: json['exam_shift'] ?? '',
      text: json['question_text'] ?? '',
      options: parsedOptions,
      correctAnswer: json['correct_answer'] ?? '',
      solution: json['solution'] ?? '',
      questionImageUrl: json['question_image_url'], 
    );
  }
}

class QuestionScreen extends StatefulWidget {
  final String chapterName;
  final String subjectName;
  final String selectedYear;
  
  const QuestionScreen({
    super.key, 
    required this.chapterName, 
    required this.subjectName,
    required this.selectedYear,
  });

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  List<PyqQuestion> _filteredQuestions = [];
  int _currentQuestionIndex = 0;
  String? _selectedOption;
  bool _isSubmitted = false;
  bool _isLoading = true;
  String? _errorMessage;
  String _userAnswer = '';

  String _removeLeadingZeros(String input) {
  return input.replaceFirst(RegExp(r'^0+'), '');
}


  bool get _isNumericalQuestion => 
      _filteredQuestions.isNotEmpty && 
      _filteredQuestions[_currentQuestionIndex].options.isEmpty;

  @override
  void initState() {
    super.initState();
    _fetchQuestionsFromSupabase();
  }

  Future<void> _fetchQuestionsFromSupabase() async {
    try {
      final response = await Supabase.instance.client
          .from('questions')
          .select()
          .or('chapter.eq.${widget.chapterName},chapter.eq.${widget.chapterName.replaceAll("&", "and")}')
          .eq('exam_year', int.parse(widget.selectedYear))
          .order('id', ascending: true);

      print('📊 Got ${response?.length ?? 0} questions\n');
      
      if (response == null || response is! List || response.isEmpty) {
        setState(() {
          _filteredQuestions = [];
          _isLoading = false;
          _errorMessage = 'No questions found for ${widget.chapterName} - ${widget.selectedYear}';
        });
        return;
      }
      
      setState(() {
        _filteredQuestions = (response as List)
            .map((json) => PyqQuestion.fromJson(json))
            .toList();
        _isLoading = false;
      });
      
      print('✅ Loaded ${_filteredQuestions.length} questions');
      if (_filteredQuestions.isNotEmpty) {
        print('✅ First question has ${_filteredQuestions[0].options.length} options\n');
      }
      
    } catch (e, stackTrace) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error: $e';
      });
      print('❌ Error: $e');
      print('Stack: $stackTrace');
    }
  }

void _submitAnswer(String selectedOption) async {
  if (_isSubmitted) return;
  setState(() {
    _selectedOption = selectedOption;
    _isSubmitted = true;
  });

  // -------- DB Submission Logic (for heatmap) --------
  try {
    final user = Supabase.instance.client.auth.currentUser;
    final questionId = _filteredQuestions[_currentQuestionIndex].id;

    await Supabase.instance.client.from('submissions').insert({
      'user_id': user?.id,
      'question_id': questionId,
      'submitted_at': DateTime.now().toIso8601String(),
    });
    print('✅ Submission recorded for heatmap');
  } catch (e) {
    print('❌ Failed to record submission: $e');
  }
  // ----------------------------------------------------
}


void _nextQuestion() {
  if (_currentQuestionIndex < _filteredQuestions.length - 1) {
    setState(() {
      _currentQuestionIndex++;
      _selectedOption = null;
      _userAnswer = '';
      _isSubmitted = false;
    });
  } else {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Chapter ${widget.chapterName} Completed!')),
      );
    });
  }
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
            print('Block LaTeX Error: $e for content: $mathContent');
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
            child: Math.tex(mathContent,
                textStyle: TextStyle(fontSize: fontSize, color: color)),
          ));
        } catch (e) {
          print('Inline LaTeX Error: $e for content: $mathContent');
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
    
    return RichText(text: TextSpan(children: spans));
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.chapterName),
          backgroundColor: const Color(0xFF1E1E1E),
        ),
        body: const Center(
          child: CircularProgressIndicator(color: Color(0xFFE57C23)),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.chapterName),
          backgroundColor: const Color(0xFF1E1E1E),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(_errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, color: Colors.white54)),
                const SizedBox(height: 24),
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
        ),
      );
    }

    if (_filteredQuestions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.chapterName)),
        body: const Center(
          child: Text('No PYQs found.',
              style: TextStyle(fontSize: 16, color: Colors.white54)),
        ),
      );
    }
    
final currentQuestion = _filteredQuestions[_currentQuestionIndex];

    
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.chapterName} PYQs',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        actions: [
          Center(
              child: Text(
                  '${_currentQuestionIndex + 1}/${_filteredQuestions.length}',
                  style: const TextStyle(fontWeight: FontWeight.bold))),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          _buildYearSelectorRow(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text(
        'JEE Main ${currentQuestion.year} | ${currentQuestion.shift} | Q.${currentQuestion.id}',
        style: const TextStyle(color: Colors.white54, fontSize: 12)),
    const SizedBox(height: 12),
    // YAHAN PE Image Wala CODE Add karo
    if (currentQuestion.questionImageUrl != null && currentQuestion.questionImageUrl!.isNotEmpty)
      Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            currentQuestion.questionImageUrl!,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) =>
                Icon(Icons.broken_image, size: 60, color: Colors.white24),
          ),
        ),
      ),
    // AB tumhara question box jaise hai waise hi likho
    _buildQuestionBox(currentQuestion.text),
    const SizedBox(height: 24),
    ..._buildOptionsFromMap(context, currentQuestion.options, currentQuestion.correctAnswer),
    const SizedBox(height: 32),
    if (_isSubmitted) ...[
      _buildSolutionBox(context, currentQuestion.solution),
      const SizedBox(height: 16),
      _buildAIDoubtSolverButton(context),
    ],
  ],
)

            ),
          ),
          _buildBottomNavigation(context),
        ],
      ),
    );
  }

  List<Widget> _buildOptionsFromMap(
      BuildContext context, Map<String, String> options, String correctAnswer) {
    if (options.isEmpty) {
      return [
        Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isSubmitted
                  ? (_userAnswer == correctAnswer ? Colors.green : Colors.red)
                  : const Color(0xFFE57C23),
              width: 2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Your Answer: ',
                  style: TextStyle(fontSize: 18, color: Colors.white70)),
              Text(
                _userAnswer.isEmpty ? 'Type you answer...' : _userAnswer,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: _isSubmitted
                      ? (_userAnswer == correctAnswer ? Colors.green : Colors.red)
                      : const Color(0xFFE57C23),
                ),
              ),
            ],
          ),
        ),
        if (_isSubmitted && _userAnswer != correctAnswer)
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green, width: 2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 24),
                const SizedBox(width: 12),
                const Text('Correct Answer: ',
                    style: TextStyle(fontSize: 16, color: Colors.green)),
                Text(
                  correctAnswer,
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green),
                ),
              ],
            ),
          ),
      ];
    }
    
return options.entries.map((entry) {
  // MERE CHANGE:
  // Agar option image URL hai (http ya .png/.jpg etc)
  String optionValue = entry.value.trim();
  String optionDisplayText = '(${entry.key}) ';
  if (optionValue.startsWith('http') && (
      optionValue.endsWith('.png') || 
      optionValue.endsWith('.jpg') ||
      optionValue.endsWith('.jpeg'))) {
    // Agar image hai, _buildOptionImageTile use karo
    return _buildOptionImageTile(
      context, optionDisplayText, optionValue, correctAnswer, entry.key
    );
  } else {
    // Baaki normal LaTeX options
    String displayText = optionDisplayText + optionValue;
    return _buildOptionTile(context, displayText, correctAnswer);
  }
}).toList();

  }

 Widget _buildOptionImageTile(BuildContext context, String prefix, String imageUrl, String correctAnswer, String optionKey) {
  final isCorrect = correctAnswer == optionKey;
  final isSelected = _selectedOption == (prefix + imageUrl);
  Color tileColor = Theme.of(context).cardColor;
  Color borderColor = Colors.white12;
  IconData? trailingIcon;

  if (_isSubmitted) {
    if (isCorrect) {
      tileColor = Colors.green.withOpacity(0.2);
      borderColor = Colors.green;
      trailingIcon = Icons.check_circle;
    } else if (isSelected) {
      tileColor = Colors.red.withOpacity(0.2);
      borderColor = Colors.red;
      trailingIcon = Icons.close_sharp;
    }
  } else if (isSelected) {
    borderColor = const Color(0xFFE57C23);
  }

  return Padding(
    padding: const EdgeInsets.only(bottom: 12.0),
    child: GestureDetector(
      onTap: _isSubmitted ? null : () => _submitAnswer(prefix + imageUrl),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: tileColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Row(
          children: [
            Text(prefix, style: TextStyle(fontSize: 15, color: Colors.white)),
            const SizedBox(width: 8),
            Image.network(
              imageUrl,
              height: 70,   // <--- INCREASE THIS!
              width: 110,   // <--- Optional, to keep aspect ratio
              fit: BoxFit.contain,
              errorBuilder: (c, o, s) =>
                Icon(Icons.broken_image, color: Colors.white24, size: 32),
            ),
            if (trailingIcon != null) ...[
              const SizedBox(width: 10),
              Icon(trailingIcon, color: borderColor, size: 20),
            ],
          ],
        ),
      ),
    ),
  );
}



  Widget _buildYearSelectorRow(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Theme.of(context).cardColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white12),
            ),
            child: Text('Year: ${widget.selectedYear}',
                style: const TextStyle(
                    color: Color(0xFFE57C23),
                    fontWeight: FontWeight.bold,
                    fontSize: 14)),
          ),
          const Row(
            children: [
              Text('Solved: 0/0',
                  style: TextStyle(color: Colors.white70, fontSize: 12)),
              SizedBox(width: 10),
              Text('Accuracy: --%',
                  style: TextStyle(color: Colors.white54, fontSize: 12)),
            ],
          )
        ],
      ),
    );
  }

  

  Widget _buildQuestionBox(String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white12),
      ),
      child: _buildLatexText(text, fontSize: 16, color: Colors.white),
    );
  }

  Widget _buildOptionTile(
      BuildContext context, String option, String correctAnswer) {
    final isSelected = _selectedOption == option;
    Color tileColor = Theme.of(context).cardColor;
    Color borderColor = Colors.white12;
    IconData? trailingIcon;
    String correctOptionDisplay = '($correctAnswer)';
    
    if (_isSubmitted) {
      if (option.startsWith(correctOptionDisplay)) {
        tileColor = Colors.green.withOpacity(0.2);
        borderColor = Colors.green;
        trailingIcon = Icons.check_circle;
      } else if (isSelected) {
        tileColor = Colors.red.withOpacity(0.2);
        borderColor = Colors.red;
        trailingIcon = Icons.close_sharp;
      }
    } else if (isSelected) {
      borderColor = const Color(0xFFE57C23);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: GestureDetector(
        onTap: _isSubmitted ? null : () => _submitAnswer(option),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: tileColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor, width: 2),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildLatexText(option,
                    fontSize: 15,
                    color: _isSubmitted &&
                            option.startsWith(correctOptionDisplay)
                        ? Colors.green
                        : Colors.white),
              ),
              if (trailingIcon != null)
                Icon(trailingIcon, color: borderColor, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSolutionBox(BuildContext context, String solution) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Solution',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE57C23))),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white38),
          ),
          child: _buildLatexText(solution, fontSize: 15, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildAIDoubtSolverButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('AI Doubt Solver is analyzing the question...')),
        );
      },
      icon: const Icon(Icons.psychology_outlined, color: Colors.white),
      label: const Text('Ask AI Doubt Solver'),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF9C27B0),
        minimumSize: const Size(double.infinity, 45),
      ),
    );
  }

  Widget _buildBottomNavigation(BuildContext context) {
    final bool isLastQuestion =
        _currentQuestionIndex == _filteredQuestions.length - 1;
    
    if (_isNumericalQuestion && !_isSubmitted) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                border: const Border(top: BorderSide(color: Colors.white12)),
              ),
              child: ElevatedButton(
                onPressed: _userAnswer.isNotEmpty
                    ? () => _submitAnswer(_userAnswer)
                    : null,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: const Color(0xFFE57C23),
                ),
                child: const Text(
                  'Submit Answer',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
            ),
            _buildNumericKeyboard(),
          ],
        ),
      );
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: const Border(top: BorderSide(color: Colors.white12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton.icon(
            onPressed: _currentQuestionIndex > 0
                ? () {
                    setState(() {
                      _currentQuestionIndex--;
                      _selectedOption = null;
                      _userAnswer = '';
                      _isSubmitted = false;
                    });
                  }
                : null,
            icon: const Icon(Icons.arrow_back, color: Colors.white70),
            label: const Text('Previous',
                style: TextStyle(color: Colors.white70)),
          ),
          if (!_isSubmitted)
            ElevatedButton(
              onPressed: (_selectedOption != null || _userAnswer.isNotEmpty)
                  ? () => _submitAnswer(_selectedOption ?? _userAnswer)
                  : null,
              child: const Text('Submit Answer',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            )
          else if (!isLastQuestion)
            ElevatedButton(
              onPressed: _nextQuestion,
              child: const Text('Next Question',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            )
          else
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Finish',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }

  // NUMERIC KEYBOARD WIDGET (INTEGRATED)
  Widget _buildNumericKeyboard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildKeyboardRow(['7', '8', '9']),
          const SizedBox(height: 12),
          _buildKeyboardRow(['4', '5', '6']),
          const SizedBox(height: 12),
          _buildKeyboardRow(['1', '2', '3']),
          const SizedBox(height: 12),
          _buildKeyboardRow(['Clear', '0', '⌫']),
        ],
      ),
    );
  }

  Widget _buildKeyboardRow(List<String> keys) {
    return Row(
      children: keys.map((key) => Expanded(child: _buildKey(key))).toList(),
    );
  }

  Widget _buildKey(String key) {
    bool isSpecial = key == 'Clear' || key == '⌫';
    
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Material(
        color: isSpecial ? Colors.grey[700] : Colors.grey[800],
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () {
            if (key == 'Clear') {
              setState(() {
                _userAnswer = '';
              });
            } else if (key == '⌫') {
              if (_userAnswer.isNotEmpty) {
                setState(() {
                  _userAnswer =
                      _userAnswer.substring(0, _userAnswer.length - 1);
                });
              }
            } else {
              if (_userAnswer.length < 8) {
                setState(() {
                  _userAnswer += key;
                });
              }
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 60,
            alignment: Alignment.center,
            child: Text(
              key,
              style: TextStyle(
                fontSize: isSpecial ? 18 : 24,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
