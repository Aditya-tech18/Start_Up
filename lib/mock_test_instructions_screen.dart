import 'package:flutter/material.dart';
import 'mock_test_paper_screen_final.dart';

class MockTestInstructionsPage extends StatelessWidget {
  final String title;
  final int testId;   // <- Store testId as member
  const MockTestInstructionsPage({
    required this.title,
    required this.testId,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF161b22),
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF161b22),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E).withOpacity(0.93),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFFF9800), width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'General instructions',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                   RichText(
                    text: TextSpan(
                        style: TextStyle(fontSize: 15, color: Colors.white70),
                        children: [
                          TextSpan(
                              text: "Physics - ",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, color: Colors.white)),
                          TextSpan(text: "Full Syllabus\n"),
                          TextSpan(
                              text: "Chemistry - ",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, color: Colors.white)),
                          TextSpan(text: "Full Syllabus\n"),
                          TextSpan(
                              text: "Maths - ",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, color: Colors.white)),
                          TextSpan(text: "Full Syllabus\n"),
                        ]),
                  ),
                  const SizedBox(height: 16),
                  const Text("Test instructions",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFFFF9800))),
                  const SizedBox(height: 9),
                  const Text(
                    "1. The Test consists of Three Sections: - Physics, Chemistry, Mathematics.\n"
                    "2. Total number of Questions:- 90 (Each section consists of Thirty questions).\n"
                    "   • Section A: 20 MCQ (Attempt all 20)\n"
                    "   • Section B: 10 Integer (Attempt any 5)\n"
                    "3. Test Duration:- 180 mins (3 hours).\n"
                    "4. Test Timing:- 10:00 AM\n"
                    "5. Result Timing :- 10:00 AM (Wednesday)\n"
                    "6. Marking Scheme:-\n"
                    "   • Correct Answer: +4 marks\n"
                    "   • Wrong Answer: -1 mark\n"
                    "   • Unattempted: 0 marks\n"
                    "7. Maximum Score: 300 marks (75 questions × 4)\n"
                    "8. For Integer Type Questions:\n"
                    "   • Enter numeric answers (e.g., 2, 123, -5)\n"
                    "   • Answers like 2 and 02 are treated as same\n"
                    "   • Normal rounding rules apply (≥0.5 rounds up)\n",
                    style: TextStyle(fontSize: 15, color: Colors.white, height: 1.6),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => MockTestPaperScreen(testId: testId), // pass testId here!
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF9C27B0),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 13),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          textStyle: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        child: const Text("Start Test"),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
