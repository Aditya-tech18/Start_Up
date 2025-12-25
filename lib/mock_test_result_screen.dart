import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'models_mock_test.dart';
import 'mock_test_list_screen.dart';

class MockTestResultScreen extends StatefulWidget {
  final MockTestResult result;

  const MockTestResultScreen({Key? key, required this.result}) : super(key: key);

  @override
  _MockTestResultScreenState createState() => _MockTestResultScreenState();
}

class _MockTestResultScreenState extends State<MockTestResultScreen> {
  // List<MockTestResult>? previousResults;

  // @override
  // void initState() {
  //   super.initState();
  //   _loadPreviousResults();
  // }

  // Future<void> _loadPreviousResults() async {
  //   try {
  //     final user = Supabase.instance.client.auth.currentUser;
  //     if (user != null) {
  //       final response = await Supabase.instance.client
  //           .from('mock_test_results')
  //           .select()
  //           .eq('user_id', user.id)
  //           .order('submitted_at', ascending: false);
  //       final List data = response as List;
  //       setState(() {
  //         previousResults = data.map((e) => MockTestResult.fromJson(e)).toList();
  //       });
  //     }
  //   } catch (e) {
  //     print('Error loading previous results: $e');
  //   }
  // }

  String _formatTime(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int secs = seconds % 60;
    return '${hours}h ${minutes}m ${secs}s';
  }


@override
Widget build(BuildContext context) {
  final res = widget.result;
  return Scaffold(
    backgroundColor: const Color(0xFF161b22),
    appBar: AppBar(
      title: const Text(
        'Test Results',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      backgroundColor: const Color(0xFF161b22),
      elevation: 0,
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Score Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF9C27B0), width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Test Score',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${res.totalScore}',
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF9C27B0),
                          ),
                        ),
                        const Text(
                          'out of 300',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (res.percentile != null)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                'Percentile',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.white70),
                              ),
                              Text(
                                '${res.percentile!.toStringAsFixed(2)}%',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'Accuracy',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.white70),
                            ),
                            Text(
                              res.totalQuestionsAttempted == 0
                                  ? '0%'
                                  : '${((res.totalCorrect / res.totalQuestionsAttempted) * 100).toStringAsFixed(1)}%',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Subject-wise Breakdown
          const Text(
            'Subject-wise Analysis',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          _buildSubjectCard(
            'Physics',
            res.physicsScore,
            res.physicsCorrect,
            res.physicsWrong,
            res.physicsUnattempted,
            Colors.blue,
          ),
          const SizedBox(height: 12),
          _buildSubjectCard(
            'Chemistry',
            res.chemistryScore,
            res.chemistryCorrect,
            res.chemistryWrong,
            res.chemistryUnattempted,
            Colors.green,
          ),
          const SizedBox(height: 12),
          _buildSubjectCard(
            'Maths',
            res.mathsScore,
            res.mathsCorrect,
            res.mathsWrong,
            res.mathsUnattempted,
            Colors.orange,
          ),
          const SizedBox(height: 24),

          // Overall Statistics
          const Text(
            'Overall Statistics',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Correct',
                  res.totalCorrect.toString(),
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Wrong',
                  res.totalWrong.toString(),
                  Colors.red,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Unattempted',
                  res.totalUnattempted.toString(),
                  Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Attempted',
                  res.totalQuestionsAttempted.toString(),
                  const Color(0xFF9C27B0),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Time Taken',
                  _formatTime(res.timeSpentSeconds),
                  Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Retake Test Button
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => MockTestListScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9C27B0),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Retake Test',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    ),
  );
}


Widget _buildSubjectCard(
  String subject,
  int score,
  int correct,
  int wrong,
  int unattempted,
  Color color,
) {
  int total = correct + wrong + unattempted;
  double percentage = total == 0 ? 0 : (correct / total) * 100;

  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFF1E1E1E),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color.withOpacity(0.3), width: 1),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              subject,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              '$score/100',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage / 100,
            minHeight: 8,
            backgroundColor: Colors.grey[800],
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildStatBadge('✓ $correct', Colors.green),
            _buildStatBadge('✗ $wrong', Colors.red),
            _buildStatBadge('- $unattempted', Colors.grey),
          ],
        ),
      ],
    ),
  );
}


  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
