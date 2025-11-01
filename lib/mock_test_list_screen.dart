import 'package:flutter/material.dart';
import 'mock_test_list_screen.dart'; // Apne file path ke according adjust kar le


class MockTestListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> mockTests = List.generate(10, (i) => {
      'id': i + 1,
      'title': 'Mock Test ${i + 1}',
      'date': '${25 + i} Jan 2024',
      'status': i == 2 ? 'Attempted' : i == 1 ? 'Missed' : 'New',
      'attempts': i == 2 ? 1 : 0,
    });

    return Scaffold(
      backgroundColor: Color(0xFF161b22),
      appBar: AppBar(
        title: Text("Mock Tests", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Color(0xFF161b22),
        elevation: 0,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(20),
        itemCount: mockTests.length,
        itemBuilder: (context, idx) {
          final test = mockTests[idx];
          Color statusColor;
          switch (test['status']) {
            case 'Attempted':
              statusColor = Colors.green;
              break;
            case 'Missed':
              statusColor = Colors.orange;
              break;
            default:
              statusColor = Color(0xFF9C27B0); // purple for "New"
          }
          return GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => MockTestInstructionsPage(title: test['title'])));
            },
            child: Container(
              margin: EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Colors.grey[900]!,
                  width: 1,
                ),
              ),
              child: ListTile(
                title: Row(
                  children: [
                    Text(test['title'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.white,
                        )),
                    SizedBox(width: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        test['status'],
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  ],
                ),
                subtitle: Padding(
                  padding: EdgeInsets.only(top: 3),
                  child: Row(
                    children: [
                      Text('🧑‍💻 ${test['attempts']} Attempts',
                          style: TextStyle(color: Colors.white70, fontSize: 13)),
                      SizedBox(width: 16),
                      Text('📅 ${test['date']} at 10:00 AM',
                          style: TextStyle(color: Colors.white38, fontSize: 13)),
                    ],
                  ),
                ),
                trailing: Icon(Icons.arrow_forward_ios, color: Color(0xFF9C27B0)),
              ),
            ),
          );
        },
      ),
    );
  }
}

class MockTestInstructionsPage extends StatelessWidget {
  final String title;
  MockTestInstructionsPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF161b22),
      appBar: AppBar(
        title: Text(title,
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Color(0xFF161b22),
      ),
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Container(
          decoration: BoxDecoration(
            color: Color(0xFF1E1E1E).withOpacity(0.93),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Color(0xFFFF9800), width: 1),
          ),
          child: Padding(
            padding: EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'General instructions',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
                ),
                SizedBox(height: 10),
                RichText(
                  text: TextSpan(
                      style: TextStyle(fontSize: 15, color: Colors.white70),
                      children: [
                        TextSpan(text: "Physics - ", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                        TextSpan(text: "Full Syllabus\n"),
                        TextSpan(text: "Chemistry - ", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                        TextSpan(text: "Full Syllabus\n"),
                        TextSpan(text: "Maths - ", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                        TextSpan(text: "Full Syllabus\n"),
                      ]),
                ),
                SizedBox(height: 16),
                Text("Test instructions", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFFFF9800))),
                SizedBox(height: 9),
                Text(
                  "1. The Test consists of Three Sections: - Physics, Chemistry, Mathematics.\n"
                  "2. Total number of Questions:- 90 (Each section consists of Thirty questions).\n"
                  "3. It will have 20 SCQ type and 10 Integer type (Attempt any 5 for Integer).\n"
                  "4. Test Duration:- 180 mins.\n"
                  "5. Test Timing:- 10:00 AM\n"
                  "6. Result Timing :- 10:00 AM (Wednesday)\n"
                  "7. Marking Scheme:-\n"
                  "SCQ: +4 for correct, -1 for wrong\n"
                  "Integer: +4 for correct, -1 for wrong\n",
                  style: TextStyle(fontSize: 15, color: Colors.white),
                ),
                SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => MockTestPaperScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF9C27B0),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 13),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      child: Text("Start Test"),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MockTestPaperScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1E1E1E),
      appBar: AppBar(
        title: Text('Mock Test Paper'),
        backgroundColor: Color(0xFF1E1E1E),
      ),
      body: Center(
        child: Text(
          'Mock Test (Coming Soon)',
          style: TextStyle(fontSize: 24, color: Color(0xFF9C27B0)),
        ),
      ),
    );
  }
}
