import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  int totalQuestions = 0;
  int solvedQuestions = 0;
  bool _hasNavigatedToLogin = false;

  Map<String, int> subjectTotals = {
    "physics": 0,
    "chemistry": 0,
    "maths": 0,
  };
  Map<String, int> subjectSolved = {
    "physics": 0,
    "chemistry": 0,
    "maths": 0,
  };

  Map<DateTime, int> activityMap = {};
  bool isLoading = true;
  String? userId;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _getUserIdAndFetchStats();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      fetchStats(); // Jab app foreground pe aayega, refresh kar dena data
    }
  }

  Future<void> _getUserIdAndFetchStats() async {
    userId = Supabase.instance.client.auth.currentUser?.id;
    await fetchStats();
  }

  Future<void> fetchStats() async {
    setState(() => isLoading = true);
    final client = Supabase.instance.client;

    final totalQRes = await client.from('questions').select('subject');
    if (totalQRes != null) {
      totalQuestions = (totalQRes as List).length;
      subjectTotals = {"physics": 0, "chemistry": 0, "maths": 0};
      for (var row in (totalQRes as List)) {
        final subject = (row['subject'] ?? '').toString().toLowerCase();
        if (subjectTotals.containsKey(subject)) {
          subjectTotals[subject] = (subjectTotals[subject] ?? 0) + 1;
        }
      }
    }

    final solvedQRes = await client
        .from('submissions')
        .select('question_id, submitted_at')
        .eq('user_id', userId ?? '');
    solvedQuestions = (solvedQRes as List).length;

    subjectSolved = {"physics": 0, "chemistry": 0, "maths": 0};
    if (solvedQRes != null && (solvedQRes as List).isNotEmpty) {
      final questionIds =
          (solvedQRes as List).map((e) => e['question_id'] as int).toList();
      if (questionIds.isNotEmpty) {
        final questionsRes = await client
            .from('questions')
            .select('id, subject')
            .filter('id', 'in', questionIds);
        for (var row in (questionsRes as List)) {
          final subj = (row['subject'] ?? '').toString().toLowerCase();
          if (subjectSolved.containsKey(subj)) {
            subjectSolved[subj] = (subjectSolved[subj] ?? 0) + 1;
          }
        }
      }
    }

    activityMap.clear();
    if (solvedQRes != null) {
      for (var row in (solvedQRes as List)) {
        if (row['submitted_at'] == null) continue;
        final date =
            DateTime.tryParse(row['submitted_at'].toString())?.toLocal();
        if (date == null) continue;
        final day = DateTime(date.year, date.month, date.day);
        activityMap[day] = (activityMap[day] ?? 0) + 1;
      }
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        // Wait for connection
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: const Color(0xFFE57C23)),
            ),
          );
        }

        final session = snapshot.data?.session;
        if (session == null) {
          if (!_hasNavigatedToLogin) {
            _hasNavigatedToLogin = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pushReplacementNamed('/login');
            });
          }
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: const Color(0xFFE57C23)),
            ),
          );
        }

        // User is logged in, ensure userId is set
        if (userId == null) {
          userId = session.user.id;
          _getUserIdAndFetchStats();
        }

        // Show loading while fetching data
        if (isLoading) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: const Color(0xFFE57C23)),
            ),
          );
        }

        // User logged in + data loaded, show home screen
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            leading: const Icon(Icons.menu, color: Colors.white),
            title: const Text('Hello, Student',
                style: TextStyle(fontWeight: FontWeight.bold)),
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
                  const TextField(
                    decoration: InputDecoration(
                      labelText: 'Search for questions, topics...',
                      prefixIcon: Icon(Icons.search, color: Colors.white54),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        '"The best way to predict the future is to create it."',
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
                  Center(child: _buildSolvedCircle()),
                  const SizedBox(height: 10),
                  _buildSubjectStats(),
                  const SizedBox(height: 36),
                  Text('Submissions in the past year',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 8),
                  ActivityHeatmap(activityMap: activityMap),
                  const SizedBox(height: 10),
                  _buildAchievementPostCard(context),
                  const SizedBox(height: 20),
                  Text('Explore Core Features',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 10),
                  _buildFeatureCardsGrid(context),
                  const SizedBox(height: 20),
                  Text('Community Feed',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 10),
                  _buildActivityFeedItem(
                      context, 'Welcome! Start your first challenge.'),
                  _buildActivityFeedItem(
                      context, 'Connect with your first mentor!'),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSolvedCircle() {
    final percent = totalQuestions > 0 ? solvedQuestions / totalQuestions : 0.0;
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          SizedBox(
            width: 140,
            height: 140,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background circle
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.grey[700]!,
                      width: 2,
                    ),
                  ),
                ),
                // Progress arc (outer ring with gradient)
                SizedBox(
                  width: 140,
                  height: 140,
                  child: CircularProgressIndicator(
                    value: percent,
                    strokeWidth: 12,
                    backgroundColor: Colors.grey[800],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      percent < 0.33
                          ? Colors.red
                          : percent < 0.66
                              ? Colors.orange
                              : Colors.green,
                    ),
                  ),
                ),
                // Center text
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$solvedQuestions',
                      style: const TextStyle(
                        fontSize: 44,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '/$totalQuestions',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Solved',
            style: TextStyle(
              fontSize: 14,
              color: Colors.green,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectStats() {
    const subjectColors = {
      'physics': Colors.cyan,
      'chemistry': Colors.deepOrange,
      'maths': Colors.purple,
    };
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: ['physics', 'chemistry', 'maths'].map((subject) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '${subjectSolved[subject]} / ${subjectTotals[subject]}',
              style: TextStyle(
                fontSize: 18,
                color: subjectColors[subject],
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(subject[0].toUpperCase() + subject.substring(1),
                style: const TextStyle(fontSize: 14, color: Colors.white60)),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildFeatureCardsGrid(BuildContext context) {
    final List<Map<String, dynamic>> features = [
      {
        'title': 'PYQ Mains',
        'subtitle': 'Foundational Practice',
        'icon': Icons.lightbulb_outline,
        'color1': const Color(0xFFE57C23),
        'color2': const Color(0xFFFF9800)
      },
      {
        'title': 'PYQ Advanced',
        'icon': Icons.military_tech_outlined,
        'color1': const Color(0xFF9C27B0),
        'color2': const Color(0xFF673AB7)
      },
      {
        'title': 'Mock Test',
        'icon': Icons.timer_outlined,
        'color1': const Color(0xFF00C0A4),
        'color2': const Color(0xFF1976D2)
      },
      {
        'title': 'Mentors',
        'icon': Icons.group_add_outlined,
        'color1': const Color(0xFF4CAF50),
        'color2': const Color(0xFF388E3C)
      },
      {
        'title': 'Career Counseling',
        'icon': Icons.work_outline,
        'color1': const Color(0xFF673AB7),
        'color2': const Color(0xFFBA68C8)
      },
      {
        'title': 'Study Material',
        'icon': Icons.menu_book_outlined,
        'color1': const Color(0xFFE57C23),
        'color2': const Color(0xFFD32F2F)
      },
      {
        'title': 'Friendly Battles',
        'icon': Icons.sports_esports_outlined,
        'color1': const Color(0xFF1976D2),
        'color2': const Color(0xFF42A5F5)
      },
      {
        'title': 'Confession Boards',
        'icon': Icons.forum_outlined,
        'color1': const Color(0xFFF44336),
        'color2': const Color(0xFFE57C23)
      },
      {
        'title': 'AI Doubt Solver',
        'icon': Icons.psychology_outlined,
        'color1': const Color(0xFF9C27B0),
        'color2': const Color(0xFF7B1FA2)
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.85,
      ),
      itemCount: 9,
      itemBuilder: (context, index) {
        final feature = features[index];
        final onTapAction = feature['title'] == 'PYQ Mains'
            ? () {
                Navigator.of(context).pushNamed('/pyq_mains');
              }
            : null;

        return _buildColorfulGridCard(
          context,
          feature['title']!,
          feature['icon'] as IconData,
          feature['color1'] as Color,
          feature['color2'] as Color,
          onTap: onTapAction,
        );
      },
    );
  }

  Widget _buildColorfulGridCard(BuildContext context, String title,
      IconData icon, Color color1, Color color2,
      {VoidCallback? onTap}) {
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
              Icon(icon, size: 30, color: Colors.white),
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
              style: TextStyle(
                  color: const Color(0xFFE57C23),
                  fontWeight: FontWeight.bold,
                  fontSize: 14)),
          ElevatedButton.icon(
            onPressed: () {},
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
            Text(title,
                style: const TextStyle(color: Colors.white70, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

class ActivityHeatmap extends StatefulWidget {
  final Map<DateTime, int> activityMap;
  const ActivityHeatmap({required this.activityMap, Key? key})
      : super(key: key);

  @override
  _ActivityHeatmapState createState() => _ActivityHeatmapState();
}

class _ActivityHeatmapState extends State<ActivityHeatmap> {
  DateTime? hoveredDate;

  Color getPurpleShade(int count) {
    if (count == 0) return const Color(0xFF161b22);
    if (count == 1) return const Color(0xFFd8b4fe);
    if (count <= 3) return const Color(0xFFc084fc);
    if (count <= 6) return const Color(0xFFa855f7);
    return const Color(0xFF7e22ce);
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    final months = List.generate(12, (i) {
      final date = DateTime(now.year, now.month - i, 1);
      return DateTime(date.year, date.month, 1);
    }).reversed.toList();

    const double boxSize = 10;
    const double gap = 2;
    const int gridCols = 7; // Show as standard week (Sun-Sat) per row

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0d1117),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[850]!, width: 1),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: months.map((monthStart) {
            final daysInMonth =
                DateUtils.getDaysInMonth(monthStart.year, monthStart.month);

            // prepare day-boxes in rows
            List<Widget> squares = [];
            for (int i = 0; i < daysInMonth; i++) {
              final day = DateTime(monthStart.year, monthStart.month, i + 1);
              final count = widget.activityMap[day] ?? 0;
              final color = getPurpleShade(count);
              final isHovered = hoveredDate == day;
              squares.add(
                MouseRegion(
                  onEnter: (_) => setState(() => hoveredDate = day),
                  onExit: (_) => setState(() => hoveredDate = null),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 120),
                    width: boxSize,
                    height: boxSize,
                    margin: EdgeInsets.all(gap / 2),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: isHovered && count > 0
                          ? [
                              BoxShadow(
                                color: color.withOpacity(0.7),
                                blurRadius: 6,
                                spreadRadius: 1,
                              ),
                            ]
                          : [],
                      border: Border.all(
                        color: isHovered
                            ? const Color(0xFFc084fc)
                            : const Color(0xFF161b22),
                        width: isHovered ? 1.1 : 0.7,
                      ),
                    ),
                    transform: isHovered
                        ? (Matrix4.identity()..scale(1.2))
                        : Matrix4.identity(),
                    child: isHovered && count > 0
                        ? Tooltip(
                            message:
                                "Solved $count question${count > 1 ? 's' : ''} on ${DateFormat('MMMM d, yyyy').format(day)}.",
                            textStyle: const TextStyle(
                                color: Colors.white, fontSize: 11),
                            decoration: BoxDecoration(
                              color: const Color(0xFF3a187a),
                              borderRadius: BorderRadius.circular(7),
                            ),
                            waitDuration: Duration.zero,
                            child: const SizedBox.expand(),
                          )
                        : null,
                  ),
                ),
              );
            }

            // add blanks to fill incomplete last row (7 columns)
            int fillers = (gridCols - (daysInMonth % gridCols)) % gridCols;
            for (int i = 0; i < fillers; i++) {
              squares.add(Container(
                  width: boxSize,
                  height: boxSize,
                  margin: EdgeInsets.all(gap / 2)));
            }

            int numRows = (squares.length / gridCols).ceil();

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 9),
              child: Column(
                children: [
                  SizedBox(
                    width: gridCols * (boxSize + gap),
                    height: numRows * (boxSize + gap),
                    child: GridView.count(
                      crossAxisCount: gridCols,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: gap,
                      crossAxisSpacing: gap,
                      children: squares,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    DateFormat.MMM().format(monthStart),
                    style: const TextStyle(
                      color: Color(0xFF8b949e),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
