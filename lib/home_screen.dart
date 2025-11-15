import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'mock_test_list_screen.dart'; // Apne file path ke according adjust kar le


class MultiSegmentProgressPainter extends CustomPainter {
  final double physicsPercent;
  final double chemistryPercent;
  final double mathsPercent;
  final double totalPercent;
  final double strokeWidth;

  MultiSegmentProgressPainter({
    required this.physicsPercent,
    required this.chemistryPercent,
    required this.mathsPercent,
    required this.totalPercent,
    this.strokeWidth = 12,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final double startAngle = -math.pi / 2; // Start top center
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    double curAngle = startAngle;

    // Draw Physics
    if (physicsPercent > 0) {
      paint.color = Colors.cyan;
      double sweep = totalPercent * physicsPercent * 2 * math.pi;
      canvas.drawArc(rect, curAngle, sweep, false, paint);
      curAngle += sweep;
    }
    // Draw Chemistry
    if (chemistryPercent > 0) {
      paint.color = Colors.deepOrange;
      double sweep = totalPercent * chemistryPercent * 2 * math.pi;
      canvas.drawArc(rect, curAngle, sweep, false, paint);
      curAngle += sweep;
    }
    // Draw Maths
    if (mathsPercent > 0) {
      paint.color = Colors.purple;
      double sweep = totalPercent * mathsPercent * 2 * math.pi;
      canvas.drawArc(rect, curAngle, sweep, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}


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

final solvedQuestionsSet = <int>{};
if (solvedQRes != null && solvedQRes is List) {
  for (var submission in solvedQRes) {
    final qid = submission['question_id'];
    if (qid != null) {
      solvedQuestionsSet.add(qid as int);
    }
  }
}
solvedQuestions = solvedQuestionsSet.length;


subjectSolved = {"physics": 0, "chemistry": 0, "maths": 0};

final solvedQuestionIdSet = <int>{};
if (solvedQRes != null && (solvedQRes as List).isNotEmpty) {
  // Make a set of unique question IDs solved by the user
  for (var entry in (solvedQRes as List)) {
    final qid = entry['question_id'];
    if (qid != null) solvedQuestionIdSet.add(qid as int);
  }
}
// Query subject for these unique question IDs only
if (solvedQuestionIdSet.isNotEmpty) {
  final questionsRes = await client
      .from('questions')
      .select('id, subject')
      .filter('id', 'in', solvedQuestionIdSet.toList());
  // One question per subject per subjectSolved count
  for (var row in (questionsRes as List)) {
    final subj = (row['subject'] ?? '').toString().toLowerCase();
    if (subjectSolved.containsKey(subj)) {
      subjectSolved[subj] = (subjectSolved[subj] ?? 0) + 1;
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


String getRankName(int solved) {
  if (solved < 50) return "Recruit";
  if (solved < 100) return "Cadet";
  if (solved < 200) return "Sergeant";
  if (solved < 500) return "Commander";
  if (solved < 1000) return "Major";
  return "Marshal";
}

@override
Widget build(BuildContext context) {
  return StreamBuilder<AuthState>(
    stream: Supabase.instance.client.auth.onAuthStateChange,
    builder: (context, snapshot) {
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

      if (userId == null) {
        userId = session.user.id;
        _getUserIdAndFetchStats();
      }

      if (isLoading) {
        return Scaffold(
          body: Center(
            child: CircularProgressIndicator(color: const Color(0xFFE57C23)),
          ),
        );
      }

      return Scaffold(
        appBar: AppBar(
          toolbarHeight: 50,
          elevation: 0,
          backgroundColor: const Color(0xFF0A0E21),
          title: const Text('Home'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Logout',
              onPressed: () async {
                await Supabase.instance.client.auth.signOut();
                if (mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/login',
                    (route) => false,
                  );
                }
              },
            ),
          ],
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/pexels-marek-piwnicki-3907296-11513053.jpg',
                fit: BoxFit.cover,
                color: Colors.black.withOpacity(0.5),
                colorBlendMode: BlendMode.darken,
              ),
            ),
            SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 60, top: 0, left: 14, right: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                      child: Text(
                        '"The best way to predict the future is to create it."',
                        style: TextStyle(
                          fontSize: 15,
                          color: Color.fromARGB(255, 176, 137, 39),
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildLeetCodeStyleStatus(),
                  const SizedBox(height: 40),
                  Text('Submissions in the past year',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 12),
                  ActivityHeatmap(activityMap: activityMap),
                  const SizedBox(height: 28),
                  Text('Explore Core Features',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 14),
                  _buildFeatureCardsGrid(context),
                  const SizedBox(height: 28),
                  Text('Community Feed',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 12),
                  _buildActivityFeedItem(context, 'Welcome! Start your first challenge.'),
                  _buildActivityFeedItem(context, 'Connect with your first mentor!'),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}



Widget _buildLeetCodeStyleStatus() {
  const double circleSize = 105;
  const double ringStroke = 8;

  final double percentSolved =
      totalQuestions > 0 ? solvedQuestions / totalQuestions : 0.0;
  final int safeSolved = solvedQuestions == 0 ? 1 : solvedQuestions;
  final double physicsPct = (subjectSolved["physics"] ?? 0) / safeSolved;
  final double chemistryPct = (subjectSolved["chemistry"] ?? 0) / safeSolved;
  final double mathsPct = (subjectSolved["maths"] ?? 0) / safeSolved;

  const Map<String, Color> subjectColors = {
    "physics": Color(0xFF12D6E8),
    "chemistry": Color(0xFFFF6B3D),
    "maths": Color(0xFF7D3EFF),
  };

  String getRankName(int solved) {
    if (solved < 50) return "Recruit";
    if (solved < 100) return "Cadet";
    if (solved < 200) return "Sergeant";
    if (solved < 500) return "Commander";
    if (solved < 1000) return "Major";
    return "Marshal";
  }

  return SingleChildScrollView(
    scrollDirection: Axis.vertical,
    physics: const NeverScrollableScrollPhysics(),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0A0A0C), Color(0xFF0F0F12)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withOpacity(0.06),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B3D).withOpacity(0.2),
            blurRadius: 12,
            spreadRadius: 0.5,
            offset: const Offset(0, 5),
          ),
          BoxShadow(
            color: const Color(0xFF7D3EFF).withOpacity(0.12),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // LEFT: Circle + Boxes
          Expanded(
            flex: 1,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Progress Circle
                SizedBox(
                  width: circleSize,
                  height: circleSize,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: circleSize,
                        height: circleSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Colors.grey[850]!,
                              Colors.grey[900]!,
                            ],
                            stops: const [0.6, 1.0],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 10,
                              spreadRadius: 1.5,
                            ),
                          ],
                        ),
                      ),
                      CustomPaint(
                        size: Size(circleSize, circleSize),
                        painter: MultiSegmentProgressPainter(
                          physicsPercent: physicsPct,
                          chemistryPercent: chemistryPct,
                          mathsPercent: mathsPct,
                          totalPercent: percentSolved,
                          strokeWidth: ringStroke,
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$solvedQuestions',
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFEDEDED),
                              letterSpacing: -0.5,
                            ),
                          ),
                          Text(
                            '/$totalQuestions',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFFA9A9A9),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 1),
                          const Text(
                            'Solved',
                            style: TextStyle(
                              fontSize: 9,
                              color: Color(0xFF00C878),
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                // Top Row: Physics + Chemistry - EQUAL WIDTH
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: _buildRectBox(
                        subject: "Physics",
                        solved: subjectSolved["physics"] ?? 0,
                        total: subjectTotals["physics"] ?? 0,
                        color: subjectColors["physics"]!,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildRectBox(
                        subject: "Chemistry",
                        solved: subjectSolved["chemistry"] ?? 0,
                        total: subjectTotals["chemistry"] ?? 0,
                        color: subjectColors["chemistry"]!,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 9),
                // Bottom Row: Maths (CENTERED, SMALLER)
                Center(
                  child: SizedBox(
                    width: 120,
                    child: _buildRectBox(
                      subject: "Maths",
                      solved: subjectSolved["maths"] ?? 0,
                      total: subjectTotals["maths"] ?? 0,
                      color: subjectColors["maths"]!,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          // RIGHT: Badge + Rank
          Expanded(
            flex: 1,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Badge with GOLDEN GLOW
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: Colors.black.withOpacity(0.4),
                    border: Border.all(
                      color: Colors.black.withOpacity(0.6),
                      width: 2,
                    ),
                    image: const DecorationImage(
                      image: AssetImage('assets/50_days_badge.png'),
                      fit: BoxFit.cover,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFD700).withOpacity(0.75),
                        blurRadius: 24,
                        spreadRadius: 4,
                        offset: const Offset(0, 0),
                      ),
                      BoxShadow(
                        color: const Color(0xFFFFD700).withOpacity(0.45),
                        blurRadius: 16,
                        spreadRadius: 2,
                        offset: const Offset(0, 0),
                      ),
                      BoxShadow(
                        color: const Color(0xFFFFED4E).withOpacity(0.35),
                        blurRadius: 10,
                        spreadRadius: 1,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Rank Text
                Text(
                  getRankName(solvedQuestions),
                  style: const TextStyle(
                    fontSize: 17,
                    color: Color(0xFFEDEDED),
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                // Rank Label
                Text(
                  'Rank',
                  style: TextStyle(
                    color: Color(0xFFA9A9A9).withOpacity(0.85),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

// Rectangular Box Helper
Widget _buildRectBox({
  required String subject,
  required int solved,
  required int total,
  required Color color,
}) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 8,
              spreadRadius: 0.5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Text(
          '$solved / $total',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: Colors.black,
            letterSpacing: -0.3,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        subject,
        style: const TextStyle(
          color: Color(0xFFA9A9A9),
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    ],
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
      itemCount: 3,
      itemBuilder: (context, index) {
        final feature = features[index];
    final onTapAction = feature['title'] == 'Mock Test'
        ? () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => MockTestListScreen())
            );
          }
        : feature['title'] == 'PYQ Mains'
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
}).reversed.toList(); // latest month last/right



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
        reverse: true, 
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


class PaperTodoList extends StatefulWidget {
  final List<String> initialTasks;
  final Function(List<bool>, List<String>, String, String) onSave;
  final VoidCallback onClose;
  final String dontForget;
  final String notes;

  const PaperTodoList({
    required this.initialTasks,
    required this.onSave,
    required this.onClose,
    required this.dontForget,
    required this.notes,
    Key? key,
  }) : super(key: key);

  @override
  State<PaperTodoList> createState() => _PaperTodoListState();
}

class _PaperTodoListState extends State<PaperTodoList> {
  List<String> tasks = [];
  List<bool> checked = List.filled(5, false);
  late TextEditingController dontForgetCtrl;
  late TextEditingController notesCtrl;

  @override
  void initState() {
    super.initState();
    tasks = List<String>.from(widget.initialTasks);
    dontForgetCtrl = TextEditingController(text: widget.dontForget);
    notesCtrl = TextEditingController(text: widget.notes);
  }

  @override
  void dispose() {
    dontForgetCtrl.dispose();
    notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 390,
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 2,
            right: 2,
            child: IconButton(
              icon: Icon(Icons.close, color: Colors.black),
              tooltip: 'Close',
              onPressed: widget.onClose,
              splashRadius: 18,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Text(
                'To-Do List',
                style: TextStyle(
                  fontFamily: 'PermanentMarker', // Add to pubspec.yaml for handwriting look
                  fontSize: 28,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.5,
                ),
              ),
              SizedBox(height: 8),
              Divider(color: Colors.black, thickness: 1.5),
              ...List.generate(5, (i) => Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Checkbox(
                      value: checked[i],
                      onChanged: (val) => setState(() => checked[i] = val ?? false),
                      activeColor: Colors.black,
                      checkColor: Colors.white,
                      side: BorderSide(color: Colors.black, width: 2),
                    ),
                    Expanded(
                      child: TextField(
                        style: TextStyle(fontSize: 17, color: Colors.black),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Task ${i + 1}',
                          hintStyle: TextStyle(fontStyle: FontStyle.italic),
                        ),
                        controller: TextEditingController(text: tasks.length > i ? tasks[i] : ''),
                        onChanged: (val) => tasks[i] = val,
                      ),
                    ),
                  ],
                ),
              )),
              Divider(color: Colors.black, thickness: 1.2),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 1.1),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 7, vertical: 5),
                      margin: EdgeInsets.only(right: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Don\'t forget:', style: TextStyle(fontWeight: FontWeight.bold)),
                          TextField(
                            controller: dontForgetCtrl,
                            style: TextStyle(fontSize: 14, color: Colors.black),
                            decoration: InputDecoration(
                              isDense: true,
                              border: InputBorder.none,
                              hintText: 'Important...',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 1.1),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 7, vertical: 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Notes:', style: TextStyle(fontWeight: FontWeight.bold)),
                          TextField(
                            controller: notesCtrl,
                            style: TextStyle(fontSize: 14, color: Colors.black),
                            decoration: InputDecoration(
                              isDense: true,
                              border: InputBorder.none,
                              hintText: 'Extra notes...',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  widget.onSave(checked, tasks, dontForgetCtrl.text, notesCtrl.text);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text('Save', style: TextStyle(fontSize: 17)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

