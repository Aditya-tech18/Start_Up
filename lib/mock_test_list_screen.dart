import 'package:flutter/material.dart';
import 'mock_test_instructions_screen.dart';

class MockTestListScreen extends StatelessWidget {
  const MockTestListScreen({Key? key}) : super(key: key);

  final List<Map<String, dynamic>> _mockTests = const [
    {
      'id': 1,
      'title': 'JEE Main 2 April 2025 Shift 2',
      'date': '2 Apr 2025',
      'duration': '3 Hours',
      'questions': 30, // 20 MCQ + 10 Integer (attempt any 5)
      'pattern': '20 MCQs + 10 Integer Type (attempt 5)',
      'status': 'New',
    },
    // Add more tests here if needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF161b22),
      appBar: AppBar(
        title: const Text('Mock Tests', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        backgroundColor: const Color(0xFF161b22),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: ListView.separated(
          itemCount: _mockTests.length,
          separatorBuilder: (_, __) => const SizedBox(height: 20),
          itemBuilder: (context, index) {
            final test = _mockTests[index];
            return _buildMockTestCard(context, test);
          },
        ),
      ),
    );
  }

  Widget _buildMockTestCard(BuildContext context, Map<String, dynamic> testData) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MockTestInstructionsPage(
              title: testData['title'],
              testId: testData['id'],
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFFF9800).withOpacity(0.5),
            width: 2,
          ),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitleRow(testData),
            const SizedBox(height: 12),
            _buildInfoRow(testData),
            const SizedBox(height: 12),
            _buildStartButton(context, testData),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleRow(Map<String, dynamic> testData) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            testData['title'],
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF9C27B0),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            testData['status'],
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(Map<String, dynamic> testData) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2E35),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          _buildDetailItem('📅', testData['date']),
          _verticalDivider(),
          _buildDetailItem('⏰', testData['duration']),
          _verticalDivider(),
          _buildDetailItem('❓', '${testData['questions']} Questions'),
        ],
      ),
    );
  }

  Widget _verticalDivider() {
    return Container(height: 20, width: 1, color: Colors.white12);
  }

  Widget _buildDetailItem(String icon, String label) {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartButton(BuildContext context, Map<String, dynamic> testData) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MockTestInstructionsPage(
                title: testData['title'],
                testId: testData['id'],
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF9C27B0),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: const Text(
          '🚀 Start Test',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}
