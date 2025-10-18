// File: lib/subscription_screen.dart

import 'package:flutter/material.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Your Plan',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Motivational Quote Section
            Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFE57C23).withOpacity(0.2), // Orange background
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: const Color(0xFFE57C23)),
              ),
              child: const Text(
                '"Success is not final, failure is not fatal: it is the courage to continue that counts."',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: Color(0xFFE57C23),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Subscription Options Grid
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.9,
                ),
                itemCount: 4,
                itemBuilder: (context, index) {
                  return SubscriptionCard(index: index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SubscriptionCard extends StatelessWidget {
  final int index;

  const SubscriptionCard({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> plans = [
      {
        'title': 'FREE',
        'price': '₹ 0',
        'color': Colors.grey,
        'features': ['Basic Access', 'Limited Content'],
      },
      {
        'title': 'PYQ PRO',
        'price': '₹ 49',
        'color': const Color(0xFFE57C23), // Orange
        'features': ['Full PYQs', 'Full Mock Tests', 'Graph Access'],
      },
      {
        'title': '6 MONTHS PREMIUM',
        'price': '₹ 99',
        'color': const Color(0xFFE57C23), // Orange
        'features': ['6 Month Access', 'Full Mentorship', 'Friendly Battles'],
      },
      {
        'title': '1 YEAR PREMIUM',
        'price': '₹ 199',
        'color': const Color(0xFF9C27B0), // Purple
        'features': ['1 Year Access', 'All Features', 'Priority Support'],
      },
    ];

    final plan = plans[index];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: plan['color'].withOpacity(0.5), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                plan['title'],
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: plan['color'],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                plan['price'],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              ...plan['features'].map<Widget>((feature) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Row(
                    children: [
                      Icon(Icons.check, size: 14, color: plan['color']),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          feature,
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
          // Button to proceed to the main app dashboard
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Navigate to the main app dashboard
                Navigator.of(context).pushReplacementNamed('/home');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: plan['color'], // Button color matches the plan
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              child: const Text('Start Prep', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}