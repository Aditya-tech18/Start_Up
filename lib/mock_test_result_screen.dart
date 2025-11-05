// lib/screens/mock_test_result_screen.dart

import 'package:flutter/material.dart';
import 'package:saas_new/models_mock_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'models_mock_test.dart';
import 'services_mock_test.dart';
import 'mock_test_list_screen.dart';

class MockTestResultScreen extends StatefulWidget {
  final MockTestResult result;

  const MockTestResultScreen({required this.result});

  @override
  _MockTestResultScreenState createState() => _MockTestResultScreenState();
}

class _MockTestResultScreenState extends State<MockTestResultScreen> {
  late MockTestService mockTestService;
  List<MockTestResult>? previousResults;

  @override
  void initState() {
    super.initState();
    mockTestService = MockTestService(supabase: Supabase.instance.client);
    _loadPreviousResults();
  }

  Future<void> _loadPreviousResults() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final results = await mockTestService.fetchUserTestResults(user.id);
        setState(() {
          previousResults = results;
        });
      }
    } catch (e) {
      print('Error loading previous results: $e');
    }
  }

  String _formatTime(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int secs = seconds % 60;
    return '${hours}h ${minutes}m ${secs}s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF161b22),
      appBar: AppBar(
        title: Text('Test Results', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Color(0xFF161b22),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Score Card
              Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Color(0xFF9C27B0), width: 2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Test Score',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${widget.result.totalScore}',
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF9C27B0),
                              ),
                            ),
                            Text(
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
                            if (widget.result.percentile != null)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Percentile',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  Text(
                                    '${widget.result.percentile!.toStringAsFixed(2)}%',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            SizedBox(height: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Accuracy',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white70,
                                  ),
                                ),
                                Text(
                                  widget.result.totalCorrect == 0
                                      ? '0%'
                                      : '${((widget.result.totalCorrect / widget.result.totalQuestionsAttempted) * 100).toStringAsFixed(1)}%',
                                  style: TextStyle(
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
              SizedBox(height: 20),

              // Subject-wise Breakdown
              Text(
                'Subject-wise Analysis',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 12),
              _buildSubjectCard(
                'Physics',
                widget.result.physicsScore,
                widget.result.physicsCorrect,
                widget.result.physicsWrong,
                widget.result.physicsUnattempted,
                Colors.blue,
              ),
              SizedBox(height: 12),
              _buildSubjectCard(
                'Chemistry',
                widget.result.chemistryScore,
                widget.result.chemistryCorrect,
                widget.result.chemistryWrong,
                widget.result.chemistryUnattempted,
                Colors.green,
              ),
              SizedBox(height: 12),
              _buildSubjectCard(
                'Maths',
                widget.result.mathsScore,
                widget.result.mathsCorrect,
                widget.result.mathsWrong,
                widget.result.mathsUnattempted,
                Colors.orange,
              ),
              SizedBox(height: 24),

              // Overall Statistics
              Text(
                'Overall Statistics',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Correct',
                      widget.result.totalCorrect.toString(),
                      Colors.green,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Wrong',
                      widget.result.totalWrong.toString(),
                      Colors.red,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Unattempted',
                      widget.result.totalUnattempted.toString(),
                      Colors.grey,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Attempted',
                      widget.result.totalQuestionsAttempted.toString(),
                      Color(0xFF9C27B0),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Time Taken',
                      _formatTime(widget.result.timeSpentSeconds),
                      Colors.orange,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),

              // Comparison with Previous Tests
              if (previousResults != null && previousResults!.length > 1)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Comparison with Previous Tests',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 12),
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[800]!),
                      ),
                      child: Column(
                        children: previousResults!
                            .take(3)
                            .toList()
                            .asMap()
                            .entries
                            .map((entry) {
                          int index = entry.key;
                          MockTestResult prev = entry.value;
                          bool isImproved =
                              widget.result.totalScore > prev.totalScore;

                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Test ${index + 1}',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  '${prev.totalScore}/300',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Icon(
                                  isImproved
                                      ? Icons.trending_up
                                      : Icons.trending_down,
                                  color:
                                      isImproved ? Colors.green : Colors.red,
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              SizedBox(height: 24),

              // Action Buttons
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
                        backgroundColor: Color(0xFF9C27B0),
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
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
              SizedBox(height: 16),
            ],
          ),
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
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF1E1E1E),
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
                '$score/${total * 4}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage / 100,
              minHeight: 8,
              backgroundColor: Colors.grey[800],
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          SizedBox(height: 12),
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
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
          SizedBox(height: 4),
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
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
