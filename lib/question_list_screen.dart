import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:saas_new/question_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class QuestionListScreen extends StatefulWidget {
  final String chapterName;
  const QuestionListScreen({Key? key, required this.chapterName}) : super(key: key);

  @override
  State<QuestionListScreen> createState() => _QuestionListScreenState();
}

class _QuestionListScreenState extends State<QuestionListScreen> {
  List<Map<String, dynamic>> _questions = [];
  List<Map<String, dynamic>> _filteredQuestions = [];
  Set<int> _years = {};
  String _searchText = '';
  int? _selectedYear;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
  }

  Future<void> _fetchQuestions() async {
    setState(() => _loading = true);
    final response = await Supabase.instance.client
        .from('questions')
        .select()
        .eq('chapter', widget.chapterName);

    List<Map<String, dynamic>> questions = List<Map<String, dynamic>>.from(response ?? []);
    Set<int> years = questions.map((q) => q['exam_year'] as int).toSet();
    int latestYear = years.isNotEmpty ? years.reduce((a, b) => a > b ? a : b) : DateTime.now().year;

    setState(() {
      _questions = questions;
      _years = years;
      _selectedYear = latestYear;
      _loading = false;
    });
    _applyFilters();
  }

  void _applyFilters() {
    List<Map<String, dynamic>> filtered = _questions
        .where((q) => (_selectedYear == null || q['exam_year'] == _selectedYear))
        .where((q) => _searchText.isEmpty ||
            (q['question_text']?.toLowerCase().contains(_searchText.toLowerCase()) ?? false) ||
            (q['exam_shift']?.toLowerCase().contains(_searchText.toLowerCase()) ?? false))
        .toList();
    setState(() => _filteredQuestions = filtered);
  }

  // ---------- Same LaTeX RichText Rendering as QuestionScreen ----------
  Widget _buildLatexText(String text, {double fontSize = 15, Color color = Colors.white}) {
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
            child: Math.tex(mathContent,
                textStyle: TextStyle(fontSize: fontSize, color: color)),
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
    return RichText(text: TextSpan(children: spans));
  }
  // ----------------------------------------------------------------------

  Widget _buildYearDropdown() {
    List<int> sortedYears = _years.toList()..sort((b, a) => a.compareTo(b));
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: DropdownButtonFormField<int>(
        decoration: InputDecoration(
          labelText: 'Select Year',
          labelStyle: const TextStyle(
              color: Colors.orange,
              fontWeight: FontWeight.bold,
              fontSize: 15),
          filled: true,
          fillColor: Colors.grey[900],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.orange, width: 1.2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.orange, width: 2),
          ),
        ),
        dropdownColor: Colors.black,
        isExpanded: true,
        value: _selectedYear,
        icon: const Icon(Icons.arrow_drop_down, color: Colors.orange, size: 30),
        items: sortedYears
            .map((year) => DropdownMenuItem(
          value: year,
          child: Text(
            year.toString(),
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
          ),
        ))
            .toList(),
        onChanged: (year) {
          setState(() {
            _selectedYear = year;
          });
          _applyFilters();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          widget.chapterName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple[900],
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.orange))
          : Column(
              children: [
                _buildYearDropdown(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: TextField(
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                    decoration: InputDecoration(
                      hintText: 'Search question or shift...',
                      hintStyle: const TextStyle(color: Colors.white70),
                      prefixIcon: const Icon(Icons.search, color: Colors.orange, size: 26),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 14),
                      filled: true,
                      fillColor: Colors.grey[900],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.orange.shade400, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Colors.orange, width: 2),
                      ),
                    ),
                    onChanged: (text) {
                      _searchText = text;
                      _applyFilters();
                    },
                  ),
                ),
                Expanded(
                  child: _filteredQuestions.isEmpty
                      ? const Center(
                          child: Text(
                            'No questions found',
                            style: TextStyle(color: Colors.white54, fontSize: 15, fontWeight: FontWeight.w500),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 8),
                          itemCount: _filteredQuestions.length,
                          itemBuilder: (context, index) {
                            final q = _filteredQuestions[index];
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                              child: Material(
                                color: Colors.orange.shade800.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(18),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(18),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => QuestionScreen(
                                          chapterName: q['chapter'] ?? '',
                                          subjectName: q['subject'] ?? '',
                                          selectedYear: q['exam_year'].toString(),
                                          initialQuestionId: q['id'],
                                        ),
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 18),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _buildLatexText(q['question_text'] ?? '', fontSize: 15, color: Colors.white),
                                        const SizedBox(height: 12),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: Colors.deepPurple[800],
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            '${q['exam_year']} • ${q['exam_shift']}',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.orange.shade200,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
