import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../keys/razorpay_keys.dart';
import 'package:uuid/uuid.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  late Razorpay _razorpay;
  bool _paymentInProgress = false;

  final List<Map<String, dynamic>> plans = [
    {
      'name': 'Start Your Big Journey',
      'desc': 'Begin small, dream big! 🚀',
      'duration': '1 month',
      'months': 1,
      'amount': 900, // ₹9 in paise
      'price': '₹9',
      'oldPrice': '₹19',
      'icon': Icons.rocket_launch_rounded,
      'mostPopular': false,
    },
    {
      'name': 'Booster Plan',
      'desc': 'Boost your prep, real results! ⚡',
      'duration': '3 months',
      'months': 3,
      'amount': 2700,
      'price': '₹27',
      'oldPrice': '₹49',
      'icon': Icons.bolt_rounded,
      'mostPopular': false,
    },
    {
      'name': 'Perfect Exam Season',
      'desc': 'Game-changer for exam season 🎯',
      'duration': '6 months',
      'months': 6,
      'amount': 5400,
      'price': '₹54',
      'oldPrice': '₹99',
      'icon': Icons.track_changes_rounded,
      'mostPopular': true,
    },
    {
      'name': 'Saathi Plan — Yearlong Prep',
      'desc': 'A trusted companion for a year 🤝',
      'duration': '12 months',
      'months': 12,
      'amount': 10800,
      'price': '₹108',
      'oldPrice': '₹199',
      'icon': Icons.handshake_rounded,
      'mostPopular': false,
    },
  ];

  // Save selected plan for processing after payment
  Map<String, dynamic>? _pendingPlan;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handleSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handleError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void openCheckout(Map<String, dynamic> plan) async {
    setState(() {
      _paymentInProgress = true;
      _pendingPlan = plan;
    });

    var options = {
      'key': RazorpayKeys.keyId,
      'amount': plan['amount'],
      'name': 'Prepixo',
      'description': '${plan['name']} - ${plan['duration']}',
      'prefill': {
        'contact': '', // optionally user's phone
        'email': Supabase.instance.client.auth.currentUser?.email ?? '',
      },
      'theme': {'color': '#E57C23'},
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      setState(() => _paymentInProgress = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

Future<void> _handleSuccess(PaymentSuccessResponse response) async {
  setState(() => _paymentInProgress = false);

  // Get current authenticated user from Supabase Auth
  final user = Supabase.instance.client.auth.currentUser;

  // Handle edge case where user is not found
  if (user == null || _pendingPlan == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('User not found. Please login again.'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  final now = DateTime.now();

  // Calculate expiry: add plan months to now, handling overflow correctly
  int monthsToAdd = _pendingPlan!['months'] ?? 1;
  int year = now.year + ((now.month + monthsToAdd - 1) ~/ 12);
  int month = ((now.month + monthsToAdd - 1) % 12) + 1;
  final validUntil = DateTime(year, month, now.day);

  // Prepare the subscription data, using user.id as upsert key (no need for random uuid)
  final upsertData = {
    'user_id': user.id,                            // Unique key for each user
    'email': user.email,                           // Redundant but useful
    'plan_name': _pendingPlan!['name'],
    'paid_on': now.toIso8601String(),
    'valid_until': validUntil.toIso8601String(),
    'payment_id': response.paymentId,
  };

  // Upsert on user_id to avoid duplicate constraint violation
  final insertResult = await Supabase.instance.client
      .from('subscriptions')
      .upsert(upsertData, onConflict: 'user_id');

  if (insertResult.error == null) {
    // Payment and subscription DB update succeeded, inform user and pop to home/refresh logic
    if (!mounted) return; // Prevent calling context if widget is gone
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Payment Successful! Subscription activated.'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.of(context).pop(true); // Indicate success to HomeScreen
  } else {
    // Payment succeeded, but DB update failed
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment succeeded, DB failed: ${insertResult.error!.message}'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

  void _handleError(PaymentFailureResponse response) {
    setState(() => _paymentInProgress = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment Failed! ${response.message ?? ""} (Code: ${response.code})'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    setState(() => _paymentInProgress = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Selected external wallet: ${response.walletName}'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Subscription', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.orange),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: ListView(
          children: [
            const Text(
              'Unlock all mock tests, PYQs, and smart tracking with premium access:',
              style: TextStyle(
                  color: Colors.white70, fontSize: 18, fontWeight: FontWeight.w400
              ),
            ),
            const SizedBox(height: 18),
            ...plans.map(_buildPlanCard).toList(),
            if (_paymentInProgress) ...[
              const SizedBox(height: 18),
              const Center(child: CircularProgressIndicator(color: Colors.orange)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(Map<String, dynamic> plan) {
    bool isPopular = plan['mostPopular'] == true;
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        border: Border.all(
            color: isPopular ? Colors.orange : Colors.white12,
            width: isPopular ? 2.2 : 1.0),
        borderRadius: BorderRadius.circular(13),
        boxShadow: isPopular
            ? [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.12),
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, 5),
                )
              ]
            : [],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(plan['icon'], color: isPopular ? Colors.orange : Colors.white70, size: 26),
                const SizedBox(width: 15),
                Expanded(
                  child: Text(plan['name'],
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isPopular ? Colors.orange : Colors.white,
                          fontSize: 17)),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(plan['desc'],
                style: TextStyle(
                    fontSize: 13,
                    color: Colors.orange.withOpacity(0.96),
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 7),
            Row(
              children: [
                Text(plan['oldPrice'],
                    style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white38,
                        decoration: TextDecoration.lineThrough)),
                const SizedBox(width: 12),
                Text(plan['price'],
                    style: const TextStyle(
                        fontSize: 18,
                        color: Colors.orange,
                        fontWeight: FontWeight.bold)),
                const SizedBox(width: 10),
                Text(plan['duration'],
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white54,
                      fontWeight: FontWeight.w400,
                    )),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _paymentInProgress ? null : () => openCheckout(plan),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  textStyle: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                  elevation: isPopular ? 6 : 1,
                ),
                child: Text(isPopular ? 'Join Now (Most Popular)' : 'Join Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
