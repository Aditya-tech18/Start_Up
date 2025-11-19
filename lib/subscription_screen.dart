import 'package:flutter/material.dart';

// Dummy payment logic—replace with your Razorpay logic.
Future<bool> launchRazorpay(String price, String name, String duration) async {
  await Future.delayed(Duration(seconds: 2));
  return true;
}

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  static const Color bgColor = Colors.black;
  static final Color cardColor = Colors.grey[900]!;
  static const Color accent = Color(0xFFE57C23);     // Orange from your "Submit", year border, etc.
  static const Color borderColor = Colors.orange;
  static const Color softAccent = Color(0xFFF9B36B); // Lighter orange for badge
  static const Color labelBg = Color(0xFF381E55);    // From shift container (deep purple)

  static final List<Map<String, dynamic>> plans = [
    {
      'name': 'Start Your Big Journey',
      'tagline': 'Begin small, dream big! 🚀',
      'duration': '1 month access',
      'oldPrice': '₹19',
      'price': '₹9',
      'icon': Icons.rocket_launch_rounded,
      'badge': 'Limited-time Beta Offer 🎉',
      'buttonText': 'Join Now',
      'mostPopular': false,
    },
    {
      'name': 'Booster Plan',
      'tagline': 'Boost your prep for real results! ⚡',
      'duration': '3 months access',
      'oldPrice': '₹49',
      'price': '₹27',
      'icon': Icons.bolt_rounded,
      'badge': 'Limited-time Beta Offer 🎉',
      'buttonText': 'Join Now',
      'mostPopular': false,
    },
    {
      'name': 'Perfect Exam Season',
      'tagline': 'Game-changer for exam season 🎯',
      'duration': '6 months access',
      'oldPrice': '₹99',
      'price': '₹54',
      'icon': Icons.track_changes_rounded,
      'badge': '🔥 Most Popular · Beta Offer!',
      'buttonText': 'Join Now',
      'mostPopular': true,
    },
    {
      'name': 'Saathi Plan — Yearlong Prep',
      'tagline': 'A trusted companion for a year 🤝',
      'duration': '12 months access',
      'oldPrice': '₹199',
      'price': '₹108',
      'icon': Icons.handshake_rounded,
      'badge': 'Limited-time Beta Offer 🎉',
      'buttonText': 'Join Now',
      'mostPopular': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: bgColor,
        title: Text(
          'Join Prepixo Beta — Early Access',
          style: TextStyle(
            color: accent, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 22, 18, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Get full access to PYQs, mock tests, smart tracking — now at launch prices!',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 13),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 6, horizontal: 13),
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.13),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Text(
                        'Daily new questions 🚀 — you’re joining early into something growing fast.',
                        style: TextStyle(
                          fontSize: 13,
                          color: accent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              // Plans vertical list
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Column(
                  children: [
                    for (final plan in plans)
                      _buildVerticalPlanCard(context, plan),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Footer
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 3),
                child: Center(
                  child: Text(
                    'Limited spots for first 1000 learners. Join before prices increase!',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildVerticalPlanCard(
      BuildContext context, Map<String, dynamic> plan) {
    bool isPopular = plan['mostPopular'] ?? false;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 23),
      padding: const EdgeInsets.fromLTRB(17, 19, 17, 15),
      decoration: BoxDecoration(
        color: cardColor,
        border: Border.all(
            color: isPopular ? accent : Colors.white12,
            width: isPopular ? 2.2 : 1.1),
        borderRadius: BorderRadius.circular(17),
        boxShadow: [
          if (isPopular)
            BoxShadow(
              color: accent.withOpacity(0.18),
              blurRadius: 30,
              spreadRadius: 4,
              offset: const Offset(0, 6),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon + Title
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(plan['icon'],
                  color: isPopular ? accent : Colors.white70, size: 26),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  plan['name'],
                  style: TextStyle(
                    fontSize: 16,
                    color: isPopular ? accent : Colors.white,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            plan['tagline'],
            style: TextStyle(
              fontSize: 13,
              color: accent.withOpacity(0.93),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 11),
          Row(
            children: [
              Text(
                plan['oldPrice'],
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white38,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                plan['price'],
                style: TextStyle(
                  fontSize: 22,
                  color: accent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 11),
              Text(
                plan['duration'],
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.white54,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          // Badge (like shift/year container style)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: labelBg,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Text(
              plan['badge'],
              style: TextStyle(
                fontSize: 11,
                color: softAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 13),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                final paymentSuccess = await launchRazorpay(
                    plan['price'], plan['name'], plan['duration']);
                if (paymentSuccess) {
                  Navigator.of(context).pop(true);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Payment failed or cancelled.'),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 3),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: isPopular ? 7 : 1,
                shadowColor:
                    isPopular ? accent.withOpacity(0.32) : Colors.black12,
              ),
              child: Text(plan['buttonText']),
            ),
          ),
        ],
      ),
    );
  }
}
