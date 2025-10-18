// File: lib/home_screen.dart

import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: const Icon(Icons.menu, color: Colors.white),
        title: const Text('Hello, Student', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: const [
          Icon(Icons.notifications_none, color: Colors.white),
          SizedBox(width: 12),
          Icon(Icons.person, color: Colors.white),
          SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Search Bar
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Search for questions, topics...',
                  prefixIcon: Icon(Icons.search, color: Colors.white54),
                ),
              ),
              const SizedBox(height: 16),

              // 2. Motivational Quote
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    '“The best way to predict the future is to create it.”',
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF9C27B0),
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 3. Questions Solved Card (Full Width - Vibrant)
              _buildQuestionsSolvedCard(context),
              const SizedBox(height: 12),
              
              // 4. Rank & Badges Card (Full Width - Vibrant)
              _buildRankAndBadgesCard(context),
              const SizedBox(height: 16),

              // 5. Graph Section (Activity Heatmap - always visible)
              _buildActivityGraph(context),
              const SizedBox(height: 20),

              // 6. Post (LinkedIn-style achievement post)
              _buildAchievementPostCard(context),
              const SizedBox(height: 20),

              // 7. Feature Cards Grid (3x3 Layout)
              Text(
                'Explore Core Features',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 10),
              _buildFeatureCardsGrid(context), // 3-Column Grid
              const SizedBox(height: 20),

              // 8. Recent Activity/Posts Section
              Text(
                'Community Feed',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 10),
              _buildActivityFeedItem(context, 'Welcome! Start your first challenge.'),
              _buildActivityFeedItem(context, 'Connect with your first mentor!'),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
  
  // --- 3x3 FEATURE GRID BUILDER ---
  Widget _buildFeatureCardsGrid(BuildContext context) {
    // Unique color gradients for visual distinction
    final List<Map<String, dynamic>> features = [
      {'title': 'PYQ Mains', 'subtitle': 'Foundational Practice', 'icon': Icons.lightbulb_outline, 'color1': const Color(0xFFE57C23), 'color2': const Color(0xFFFF9800)},
      {'title': 'PYQ Advanced', 'icon': Icons.military_tech_outlined, 'color1': const Color(0xFF9C27B0), 'color2': const Color(0xFF673AB7)},
      {'title': 'Mock Test', 'icon': Icons.timer_outlined, 'color1': const Color(0xFF00C0A4), 'color2': const Color(0xFF1976D2)},
      {'title': 'Mentors', 'icon': Icons.group_add_outlined, 'color1': const Color(0xFF4CAF50), 'color2': const Color(0xFF388E3C)}, // Green Gradient
      {'title': 'Career Counseling', 'icon': Icons.work_outline, 'color1': const Color(0xFF673AB7), 'color2': const Color(0xFFBA68C8)}, // Light Purple Gradient
      {'title': 'Study Material', 'icon': Icons.menu_book_outlined, 'color1': const Color(0xFFE57C23), 'color2': const Color(0xFFD32F2F)}, // Orange/Red Gradient
      {'title': 'Friendly Battles', 'icon': Icons.sports_esports_outlined, 'color1': const Color(0xFF1976D2), 'color2': const Color(0xFF42A5F5)}, // Blue Gradient
      {'title': 'Confession Boards', 'icon': Icons.forum_outlined, 'color1': const Color(0xFFF44336), 'color2': const Color(0xFFE57C23)}, // Red to Orange
      {'title': 'AI Doubt Solver', 'icon': Icons.psychology_outlined, 'color1': const Color(0xFF9C27B0), 'color2': const Color(0xFF7B1FA2)}, // Dark Purple
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // Set to 3 columns
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.85,
      ),
      itemCount: 9, // Exactly 3 rows of 3
      itemBuilder: (context, index) {
        final feature = features[index];
        
        // Define navigation for the 'PYQ Mains' card
        final onTapAction = feature['title'] == 'PYQ Mains' 
            ? () {
                Navigator.of(context).pushNamed('/pyq_mains'); // Correct Navigation
              }
            : null;

        return _buildColorfulGridCard(
          context,
          feature['title']!,
          feature['icon'] as IconData,
          feature['color1'] as Color,
          feature['color2'] as Color,
          onTap: onTapAction, // Pass the navigation action
        );
      },
    );
  }

  Widget _buildColorfulGridCard(BuildContext context, String title, IconData icon, Color color1, Color color2, {VoidCallback? onTap}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [color1.withOpacity(0.95), color2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: color2.withOpacity(0.4),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 30, color: Colors.white), // White icon for contrast
              const SizedBox(height: 6),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Access',
                style: TextStyle(color: Colors.white70, fontSize: 9),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- UTILITY WIDGETS (REMAIN THE SAME) ---

  Widget _buildQuestionsSolvedCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE57C23).withOpacity(0.25),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Questions Solved', style: TextStyle(color: Colors.white54, fontSize: 14)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('0 / 0',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: const Color(0xFFE57C23),
                      fontWeight: FontWeight.w900)),
              const Icon(Icons.check_circle_outline, color: Color(0xFF00C0A4), size: 28),
            ],
          ),
          const Divider(color: Colors.white12, height: 20),
          _buildDifficultyPill('Easy', 0, Colors.green),
          _buildDifficultyPill('Med.', 0, Colors.orange),
          _buildDifficultyPill('Hard', 0, const Color(0xFF9C27B0)),
        ],
      ),
    );
  }

  Widget _buildRankAndBadgesCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9C27B0).withOpacity(0.25),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Rank Info
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Your Rank', style: TextStyle(color: Colors.white54, fontSize: 14)),
              const SizedBox(height: 4),
              Text('Global Rank: --',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: const Color(0xFF9C27B0),
                      fontWeight: FontWeight.w900)),
              const SizedBox(height: 4),
              const Text('Next Rank in: 100 Solves', style: TextStyle(color: Colors.white70, fontSize: 11)),
            ],
          ),
          // Badges Info
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('Badges Earned', style: TextStyle(color: Colors.white54, fontSize: 14)),
              const SizedBox(height: 4),
              const Icon(Icons.workspace_premium_outlined, color: Color(0xFFE57C23), size: 28),
              const SizedBox(height: 4),
              const Text('Total Badges: 0', style: TextStyle(color: Colors.white70, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyPill(String label, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(label, style: TextStyle(color: color, fontSize: 12)),
          ),
          Text('$count', style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildActivityGraph(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Submissions in the past year', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            height: 120,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white12),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Oct', style: TextStyle(color: Colors.white54, fontSize: 11)),
                    Text('Jan', style: TextStyle(color: Colors.white54, fontSize: 11)),
                    Text('Apr', style: TextStyle(color: Colors.white54, fontSize: 11)),
                    Text('Jul', style: TextStyle(color: Colors.white54, fontSize: 11)),
                    Text('Sep', style: TextStyle(color: Colors.white54, fontSize: 11)),
                  ],
                ),
                SizedBox(height: 4),
                Expanded(
                  child: Center(
                    child: Text(
                      'Solve your first question to start the Heatmap!',
                      style: TextStyle(color: Color(0xFF00C0A4), fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total active days: 0', style: TextStyle(color: Colors.white54, fontSize: 11)),
              Text('Max streak: 0', style: TextStyle(color: Colors.white54, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementPostCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE57C23).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE57C23).withOpacity(0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Share Your Achievement!',
              style: TextStyle(color: const Color(0xFFE57C23), fontWeight: FontWeight.bold, fontSize: 14)),
          ElevatedButton.icon(
            onPressed: () {
              // Action to create a new post
            },
            icon: const Icon(Icons.create, size: 16),
            label: const Text('New Post', style: TextStyle(fontSize: 12)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE57C23),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityFeedItem(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            const Icon(Icons.star, color: Color(0xFF00C0A4), size: 16),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(color: Colors.white70, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}