// File: lib/exam_selection_screen.dart

import 'package:flutter/material.dart';

class ExamSelectionScreen extends StatefulWidget {
  const ExamSelectionScreen({super.key});

  @override
  State<ExamSelectionScreen> createState() => _ExamSelectionScreenState();
}

class _ExamSelectionScreenState extends State<ExamSelectionScreen> {
  String? selectedExam;
  final TextEditingController _searchController = TextEditingController();

  final List<String> allExams = [
    'IIT JEE',
    'GATE',
    'NDA',
    'NEET',
    'UPSC',
    'SSC CGL',
    'CAT',
    'CLAT',
  ];

  List<String> filteredExams = [];

  @override
  void initState() {
    super.initState();
    filteredExams = allExams;
    _searchController.addListener(_filterExams);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterExams);
    _searchController.dispose();
    super.dispose();
  }

  void _filterExams() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredExams = allExams
          .where((exam) => exam.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Your Target Exam',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text(
              'What\'s your goal?',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search for an exam...',
                labelStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFE57C23)),
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                ),
                itemCount: filteredExams.length,
                itemBuilder: (context, index) {
                  final exam = filteredExams[index];
                  final isSelected = selectedExam == exam;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedExam = exam;
                      });
                      
                      // Navigates to the SubscriptionScreen
                      Navigator.of(context).pushNamed('/subscription');
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFE57C23).withOpacity(0.2)
                            : Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFFE57C23)
                              : Colors.transparent,
                          width: 2,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: const Color(0xFFE57C23).withOpacity(0.3),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ]
                            : [],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.school, size: 40, color: Colors.white),
                          const SizedBox(height: 8),
                          Text(
                            exam,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}