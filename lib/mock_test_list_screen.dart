// lib/mock_test_list_screen.dart

import 'package:flutter/material.dart';
import 'mock_test_instructions_screen.dart';

class MockTestListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // List of all available mock tests
    final List<Map<String, dynamic>> mockTests = [
      {
        'id': 1,
        'title': 'Mock Test 1',
        'date': '25 Jan 2024',
        'time': '10:00 AM',
        'status': 'New',
        'attempts': 0,
      },
      {
        'id': 2,
        'title': 'Mock Test 2',
        'date': '26 Jan 2024',
        'time': '10:00 AM',
        'status': 'New',
        'attempts': 0,
      },
      {
        'id': 3,
        'title': 'Mock Test 3',
        'date': '27 Jan 2024',
        'time': '10:00 AM',
        'status': 'New',
        'attempts': 0,
      },
      {
        'id': 4,
        'title': 'Mock Test 4',
        'date': '28 Jan 2024',
        'time': '10:00 AM',
        'status': 'New',
        'attempts': 0,
      },
      {
        'id': 5,
        'title': 'Mock Test 5',
        'date': '29 Jan 2024',
        'time': '10:00 AM',
        'status': 'New',
        'attempts': 0,
      },
    ];

    return Scaffold(
      backgroundColor: Color(0xFF161b22),
      appBar: AppBar(
        title: Text("Mock Tests", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Color(0xFF161b22),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
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
                  builder: (_) => MockTestInstructionsPage(
                    title: test['title'],
                    testId: test['id'],
                  )));
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
                      Text('📅 ${test['date']} at ${test['time']}',
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
