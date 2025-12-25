import 'package:flutter/material.dart';
import 'package:saas_new/question_screen.dart';
import 'package:saas_new/question_list_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// --- Subject and Chapter Data Models ---
enum SubjectEnum { physics, chemistry, maths }

class Chapter {
  final String name;
  final IconData icon;
  final Color iconColor;
  final String completionStats;

  Chapter({
    required this.name,
    required this.icon,
    required this.iconColor,
    required this.completionStats,
  });
}

// --- PYQ Chapter List Widget ---
class PyqChapterListScreen extends StatefulWidget {
  const PyqChapterListScreen({super.key});

  @override
  State<PyqChapterListScreen> createState() => _PyqChapterListScreenState();
}

class _PyqChapterListScreenState extends State<PyqChapterListScreen> {
  SubjectEnum _selectedSubject = SubjectEnum.physics;
  String _selectedYear = '2025';

final TextEditingController _searchController = TextEditingController();
String _searchQuery = '';

  final List<String> _availableYears =
      List.generate(11, (i) => (2025 - i).toString());

  // ==================== COMPLETE CHAPTERS FROM ALL SCREENSHOTS ====================
  final Map<SubjectEnum, List<Chapter>> _allChapters = {
    // ==================== MATHS - 32 CHAPTERS ====================
    SubjectEnum.maths: [
        Chapter(
          name: 'Sets & Relations',
          icon: Icons.category,
          iconColor: Colors.purple,
          completionStats: '0/107 Qs'),
        Chapter(
          name: 'Functions',
          icon: Icons.functions,
          iconColor: Colors.deepOrange,
          completionStats: '0/205 Qs'),
      Chapter(
          name: 'Quadratic Equations',
          icon: Icons.functions_outlined,
          iconColor: Colors.blue,
          completionStats: '0/180 Qs'),
      Chapter(
          name: 'Complex Numbers',
          icon: Icons.category_outlined,
          iconColor: Colors.deepOrange,
          completionStats: '0/203 Qs'),
      Chapter(
          name: 'Permutations & Combinations',
          icon: Icons.swap_horiz_outlined,
          iconColor: Colors.lightGreen,
          completionStats: '0/193 Qs'),
      Chapter(
          name: 'Sequences & Series',
          icon: Icons.trending_up_outlined,
          iconColor: Colors.orange,
          completionStats: '7/328 Qs'),
      Chapter(
          name: 'Mathematical Induction',
          icon: Icons.psychology_outlined,
          iconColor: Colors.deepPurple,
          completionStats: '0/3 Qs'),
      Chapter(
          name: 'Binomial Theorem',
          icon: Icons.expand_outlined,
          iconColor: Colors.cyan,
          completionStats: '0/254 Qs'),

      // Trigonometry
      Chapter(
          name: 'Trigonometry',
          icon: Icons.view_in_ar_outlined,
          iconColor: Colors.pink,
          completionStats: '0/54 Qs'),
      Chapter(
          name: 'Trigonometric Equations',
          icon: Icons.functions,
          iconColor: Colors.pinkAccent,
          completionStats: '0/73 Qs'),
      Chapter(
          name: 'Inverse Trigonometric Functions',
          icon: Icons.autorenew_outlined,
          iconColor: Colors.purple,
          completionStats: '0/79 Qs'),

      // Coordinate Geometry
      Chapter(
          name: 'Straight Lines',
          icon: Icons.show_chart,
          iconColor: Colors.green,
          completionStats: '4/203 Qs'),
      Chapter(
          name: 'Circle',
          icon: Icons.radio_button_unchecked,
          iconColor: Colors.indigo,
          completionStats: '0/183 Qs'),
      Chapter(
          name: 'Parabola',
          icon: Icons.analytics,
          iconColor: Colors.orange,
          completionStats: '0/134 Qs'),
      Chapter(
          name: 'Ellipse',
          icon: Icons.lens,
          iconColor: Colors.green.shade400,
          completionStats: '0/115 Qs'),
      Chapter(
          name: 'Hyperbola',
          icon: Icons.waves,
          iconColor: Colors.blue,
          completionStats: '0/97 Qs'),

      // Calculus
      Chapter(
          name: 'Limits',
          icon: Icons.trending_flat,
          iconColor: Colors.purple,
          completionStats: '0/138 Qs'),
      Chapter(
          name: 'Continuity & Differentiability',
          icon: Icons.timeline_outlined,
          iconColor: Colors.indigo,
          completionStats: '0/141 Qs'),
      Chapter(
          name: 'Differentiation',
          icon: Icons.show_chart,
          iconColor: Colors.teal,
          completionStats: '0/71 Qs'),
      Chapter(
          name: 'Application of Derivatives',
          icon: Icons.analytics_outlined,
          iconColor: Colors.green,
          completionStats: '2/271 Qs'),
      Chapter(
          name: 'Indefinite Integration',
          icon: Icons.functions,
          iconColor: Colors.orange,
          completionStats: '0/99 Qs'),
      Chapter(
          name: 'Definite Integration',
          icon: Icons.integration_instructions,
          iconColor: Colors.red,
          completionStats: '0/284 Qs'),
      Chapter(
          name: 'Area Under Curves',
          icon: Icons.area_chart,
          iconColor: Colors.blue,
          completionStats: '0/166 Qs'),
      Chapter(
          name: 'Differential Equations',
          icon: Icons.functions_outlined,
          iconColor: Colors.purple,
          completionStats: '0/237 Qs'),

      // Vectors & 3D
      Chapter(
          name: 'Vector Algebra',
          icon: Icons.arrow_forward,
          iconColor: Colors.blueAccent,
          completionStats: '0/282 Qs'),
      Chapter(
          name: '3D Geometry',
          icon: Icons.view_in_ar,
          iconColor: Colors.blue.shade600,
          completionStats: '0/386 Qs'),
      Chapter(
          name: 'Matrices',
          icon: Icons.grid_on,
          iconColor: Colors.teal,
          completionStats: '0/199 Qs'),
      Chapter(
          name: 'Determinants',
          icon: Icons.border_clear,
          iconColor: Colors.indigo,
          completionStats: '0/188 Qs'),
      Chapter(
          name: 'Statistics',
          icon: Icons.bar_chart,
          iconColor: Colors.amber,
          completionStats: '0/148 Qs'),
      Chapter(
          name: 'Probability',
          icon: Icons.casino,
          iconColor: Colors.pink,
          completionStats: '0/227 Qs'),
      Chapter(
          name: 'Heights & Distances',
          icon: Icons.terrain,
          iconColor: Colors.green,
          completionStats: '0/47 Qs'),
      Chapter(
          name: 'Properties of Triangles',
          icon: Icons.change_history,
          iconColor: Colors.purple,
          completionStats: '0/31 Qs'),
      Chapter(
          name: 'Mathematical Reasoning',
          icon: Icons.lightbulb_outline,
          iconColor: Colors.deepPurple,
          completionStats: '0/135 Qs'),
      Chapter(
          name: 'Linear Programming',
          icon: Icons.insights,
          iconColor: Colors.brown,
          completionStats: '0/0 Qs'),
    ],

    // ==================== CHEMISTRY - 35 CHAPTERS ====================
    SubjectEnum.chemistry: [
      // Physical Chemistry
      Chapter(
          name: 'Mole Concept',
          icon: Icons.science_outlined,
          iconColor: Colors.orange,
          completionStats: '0/192 Qs'),
      Chapter(
          name: 'Atomic Structure',
          icon: Icons.opacity_sharp,
          iconColor: Colors.blue,
          completionStats: '0/225 Qs'),
      Chapter(
          name: 'Periodic Table',
          icon: Icons.table_chart,
          iconColor: Colors.teal,
          completionStats: '0/168 Qs'),
      Chapter(
          name: 'Chemical Bonding',
          icon: Icons.link,
          iconColor: Colors.purple,
          completionStats: '46/289 Qs'),
      Chapter(
          name: 'States of Matter',
          icon: Icons.cloud,
          iconColor: Colors.cyan,
          completionStats: '0/84 Qs'),
      Chapter(
          name: 'Solid State',
          icon: Icons.view_in_ar,
          iconColor: Colors.brown,
          completionStats: '0/86 Qs'),
      Chapter(
          name: 'Solutions',
          icon: Icons.opacity,
          iconColor: Colors.lightBlue,
          completionStats: '0/206 Qs'),
      Chapter(
          name: 'Thermodynamics',
          icon: Icons.local_fire_department,
          iconColor: Colors.red,
          completionStats: '12/242 Qs'),
      Chapter(
          name: 'Chemical Equilibrium',
          icon: Icons.balance,
          iconColor: Colors.lightGreen,
          completionStats: '0/110 Qs'),
      Chapter(
          name: 'Ionic Equilibrium',
          icon: Icons.water_drop,
          iconColor: Colors.purple,
          completionStats: '1/141 Qs'),
      Chapter(
          name: 'Redox Reactions',
          icon: Icons.repeat,
          iconColor: Colors.blueGrey,
          completionStats: '3/99 Qs'),
      Chapter(
          name: 'Electrochemistry',
          icon: Icons.battery_full,
          iconColor: Colors.yellow,
          completionStats: '12/215 Qs'),
      Chapter(
          name: 'Chemical Kinetics',
          icon: Icons.speed,
          iconColor: Colors.deepOrange,
          completionStats: '4/206 Qs'),
      Chapter(
          name: 'Surface Chemistry',
          icon: Icons.layers,
          iconColor: Colors.grey,
          completionStats: '0/123 Qs'),

      // Inorganic Chemistry
      Chapter(
          name: 'Hydrogen',
          icon: Icons.cloud_outlined,
          iconColor: Colors.lightBlue,
          completionStats: '0/94 Qs'),
      Chapter(
          name: 's Block',
          icon: Icons.filter_1,
          iconColor: Colors.lime,
          completionStats: '0/132 Qs'),
      Chapter(
          name: 'p Block',
          icon: Icons.filter_2,
          iconColor: Colors.indigo,
          completionStats: '8/86 Qs'),
      Chapter(
          name: 'd & f Block',
          icon: Icons.dashboard,
          iconColor: Colors.deepPurple,
          completionStats: '0/235 Qs'),
      Chapter(
          name: 'Coordination Compounds',
          icon: Icons.hub,
          iconColor: Colors.green,
          completionStats: '0/340 Qs'),
      Chapter(
          name: 'Metallurgy',
          icon: Icons.factory,
          iconColor: Colors.brown,
          completionStats: '0/120 Qs'),
      Chapter(
          name: 'Environmental Chemistry',
          icon: Icons.eco,
          iconColor: Colors.green,
          completionStats: '0/113 Qs'),

      // Organic Chemistry
      Chapter(
          name: 'General Organic Chemistry',
          icon: Icons.hexagon_outlined,
          iconColor: Colors.amber,
          completionStats: '0/410 Qs'),
      Chapter(
          name: 'Hydrocarbons',
          icon: Icons.whatshot,
          iconColor: Colors.orange,
          completionStats: '19/214 Qs'),
      Chapter(
          name: 'Haloalkanes & Haloarenes',
          icon: Icons.opacity_outlined,
          iconColor: Colors.cyan,
          completionStats: '58/175 Qs'),
      Chapter(
          name: 'Alcohols, Phenols & Ethers',
          icon: Icons.local_bar,
          iconColor: Colors.purpleAccent,
          completionStats: '0/182 Qs'),
      Chapter(
          name: 'Aldehydes & Ketones',
          icon: Icons.science,
          iconColor: Colors.deepOrange,
          completionStats: '2/155 Qs'),
      Chapter(
          name: 'Carboxylic Acids',
          icon: Icons.water,
          iconColor: Colors.blue,
          completionStats: '0/72 Qs'),
      Chapter(
          name: 'Amines',
          icon: Icons.bubble_chart,
          iconColor: Colors.pink,
          completionStats: '0/190 Qs'),
      Chapter(
          name: 'Biomolecules',
          icon: Icons.healing,
          iconColor: Colors.lightGreen,
          completionStats: '0/194 Qs'),
      Chapter(
          name: 'Polymers',
          icon: Icons.polymer,
          iconColor: Colors.brown,
          completionStats: '0/92 Qs'),
      Chapter(
          name: 'Everyday Chemistry',
          icon: Icons.home,
          iconColor: Colors.pinkAccent,
          completionStats: '0/96 Qs'),
      Chapter(
          name: 'Practical Chemistry',
          icon: Icons.biotech,
          iconColor: Colors.orange,
          completionStats: '0/35 Qs'),

      // Additional (from combined images)
      Chapter(
          name: 'Chemistry in Everyday Life',
          icon: Icons.favorite_outline,
          iconColor: Colors.pinkAccent,
          completionStats: '0/96 Qs'),
    ],

    // ==================== PHYSICS - 32 CHAPTERS (Already Complete) ====================
    SubjectEnum.physics: [
      Chapter(
          name: 'Units & Dimensions',
          icon: Icons.straighten,
          iconColor: Colors.green.shade400,
          completionStats: '0/133 Qs'),
      Chapter(
          name: 'Motion in 1D',
          icon: Icons.arrow_right_alt,
          iconColor: Colors.blue.shade400,
          completionStats: '0/168 Qs'),
      Chapter(
          name: 'Motion in 2D',
          icon: Icons.alt_route,
          iconColor: Colors.red.shade400,
          completionStats: '1/118 Qs'),
      Chapter(
          name: 'Laws of Motion',
          icon: Icons.sync_alt,
          iconColor: Colors.orange.shade400,
          completionStats: '0/191 Qs'),
      Chapter(
          name: 'Work Power Energy',
          icon: Icons.power,
          iconColor: Colors.yellow.shade700,
          completionStats: '0/168 Qs'),
      Chapter(
          name: 'Rotational Motion',
          icon: Icons.rotate_right,
          iconColor: Colors.purple.shade500,
          completionStats: '0/250 Qs'),
      Chapter(
          name: 'Gravitation',
          icon: Icons.public,
          iconColor: Colors.deepOrange.shade400,
          completionStats: '0/210 Qs'),
      Chapter(
          name: 'Properties of Solids',
          icon: Icons.block,
          iconColor: Colors.green.shade600,
          completionStats: '0/101 Qs'),
      Chapter(
          name: 'Properties of Fluids',
          icon: Icons.waves,
          iconColor: Colors.blue.shade600,
          completionStats: '14/171 Qs'),
      Chapter(
          name: 'Thermal Properties',
          icon: Icons.thermostat_outlined,
          iconColor: Colors.red.shade600,
          completionStats: '9/129 Qs'),
      Chapter(
          name: 'Thermodynamics',
          icon: Icons.local_fire_department,
          iconColor: Colors.orange.shade700,
          completionStats: '20/211 Qs'),
      Chapter(
          name: 'KTG',
          icon: Icons.bubble_chart,
          iconColor: Colors.lightGreen.shade400,
          completionStats: '4/155 Qs'),
      Chapter(
          name: 'Oscillations',
          icon: Icons.waves_sharp,
          iconColor: Colors.blueGrey.shade400,
          completionStats: '8/176 Qs'),
      Chapter(
          name: 'Waves & Sound',
          icon: Icons.volume_up,
          iconColor: Colors.purple.shade400,
          completionStats: '0/169 Qs'),
      Chapter(
          name: 'Electrostatics',
          icon: Icons.electric_bolt,
          iconColor: Colors.indigo.shade400,
          completionStats: '11/279 Qs'),
      Chapter(
          name: 'Capacitance',
          icon: Icons.battery_charging_full,
          iconColor: Colors.teal.shade400,
          completionStats: '0/163 Qs'),
      Chapter(
          name: 'Current Electricity',
          icon: Icons.flash_on,
          iconColor: Colors.red.shade700,
          completionStats: '0/374 Qs'),
      Chapter(
          name: 'Magnetic Properties',
          icon: Icons.compass_calibration,
          iconColor: Colors.cyan.shade700,
          completionStats: '0/77 Qs'),
      Chapter(
          name: 'Magnetism & Current',
          icon: Icons.electrical_services,
          iconColor: Colors.orange.shade600,
          completionStats: '23/258 Qs'),
      Chapter(
          name: 'EMI',
          icon: Icons.bolt,
          iconColor: Colors.blue.shade600,
          completionStats: '0/132 Qs'),
      Chapter(
          name: 'AC Circuits',
          icon: Icons.network_check,
          iconColor: Colors.lightBlue.shade400,
          completionStats: '0/183 Qs'),
      Chapter(
          name: 'EM Waves',
          icon: Icons.wifi,
          iconColor: Colors.purple.shade600,
          completionStats: '0/145 Qs'),
      Chapter(
          name: 'Ray Optics',
          icon: Icons.travel_explore,
          iconColor: Colors.lightBlueAccent.shade400,
          completionStats: '0/266 Qs'),
      Chapter(
          name: 'Wave Optics',
          icon: Icons.waving_hand,
          iconColor: Colors.green.shade500,
          completionStats: '0/165 Qs'),
      Chapter(
          name: 'Dual Nature',
          icon: Icons.devices_other,
          iconColor: Colors.indigo.shade300,
          completionStats: '0/190 Qs'),
      Chapter(
          name: 'Atomic Physics',
          icon: Icons.radio_button_checked,
          iconColor: Colors.pink.shade400,
          completionStats: '0/145 Qs'),
      Chapter(
          name: 'Nuclear Physics',
          icon: Icons.radio_button_checked,
          iconColor: Colors.deepOrange.shade700,
          completionStats: '8/151 Qs'),
      Chapter(
          name: 'Semiconductors',
          icon: Icons.memory,
          iconColor: Colors.teal.shade700,
          completionStats: '62/228 Qs'),
      Chapter(
          name: 'Communication System',
          icon: Icons.speaker_phone,
          iconColor: Colors.blueGrey.shade700,
          completionStats: '0/107 Qs'),
      Chapter(
          name: 'Experimental Physics',
          icon: Icons.query_builder,
          iconColor: Colors.deepPurple.shade700,
          completionStats: '0/63 Qs'),
    ],
  };

  @override
  void initState() {
    super.initState();
    _selectedYear = _availableYears.first;
  }


Future<Map<String, int>> _getChapterStats(Chapter chapter, String? userId) async {
  final client = Supabase.instance.client;
  print('[DEBUG] Checking chapter: "${chapter.name}"');

  // 1. Questions available in DB
  final questionsList = await client
    .from('questions')
    .select('id')
    .eq('chapter', chapter.name);

  final questionIds = (questionsList as List).map((x) => x['id'] as int).toList();
  final total = questionIds.length;
  print('[DEBUG] Total questions: $total | IDs: $questionIds');

  // 2. Submissions by user for this chapter
  int solved = 0;
  if (userId != null && questionIds.isNotEmpty) {
    final idStr = '(${questionIds.join(",")})';
    final submissionsList = await client
      .from('submissions')
      .select('question_id')
      .eq('user_id', userId)
      .filter('question_id', 'in', idStr);

    final solvedSet = Set<int>.from((submissionsList as List).map((x) => x['question_id']));
    solved = solvedSet.length;
    print('[DEBUG] User submissions for chapter "$chapter.name": $solved | $solvedSet');
  }

  print('[DEBUG] Chapter: ${chapter.name} | total: $total | solved: $solved');
  return {'solved': solved, 'total': total};
}





@override
Widget build(BuildContext context) {
  // Filter logic for search bar
  final chaptersRaw = _allChapters[_selectedSubject] ?? [];
  final filteredChapters = _searchQuery.isEmpty
      ? chaptersRaw
      : chaptersRaw.where((ch) => ch.name.toLowerCase().contains(_searchQuery)).toList();

  return Scaffold(
    appBar: AppBar(
      title: const Text('JEE Mains PYQ Bank',
          style: TextStyle(fontWeight: FontWeight.bold)),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
    ),
    body: Column(
      children: [
        _buildSubjectSelector(context),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search, color: Color(0xFFE57C23)),
                    hintText: 'Search chapter...',
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.white12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.orange),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  onChanged: (query) {
                    setState(() => _searchQuery = query.trim().toLowerCase());
                  },
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedYear,
                    dropdownColor: Theme.of(context).cardColor,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    icon: const Icon(Icons.arrow_drop_down, color: Color(0xFFE57C23)),
                    items: _availableYears.map((String year) {
                      return DropdownMenuItem<String>(
                        value: year,
                        child: Text(year),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedYear = newValue;
                        });
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 16),
            itemCount: filteredChapters.length,
            itemBuilder: (context, index) {
              final chapter = filteredChapters[index];
              return _buildChapterListItem(context, chapter);
            },
          ),
        ),
      ],
    ),
  );
}


Widget _buildFilterRow(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    child: TextField(
      controller: _searchController,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search, color: Color(0xFFE57C23)),
        hintText: 'Search chapter...',
        filled: true,
        fillColor: Theme.of(context).cardColor,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.white12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.orange),
        ),
      ),
      style: const TextStyle(color: Colors.white),
      onChanged: (query) {
        setState(() => _searchQuery = query.trim().toLowerCase());
      },
    ),
  );
}



  Widget _buildFilterButton(BuildContext context, String label, IconData icon) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: Icon(icon, size: 18, color: Colors.white70),
      label: Text(label, style: const TextStyle(color: Colors.white70)),
      style: OutlinedButton.styleFrom(
        backgroundColor: Theme.of(context).cardColor,
        side: const BorderSide(color: Colors.white12),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildSubjectSelector(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSubjectButton(context, SubjectEnum.physics, 'Physics'),
          _buildSubjectButton(context, SubjectEnum.chemistry, 'Chemistry'),
          _buildSubjectButton(context, SubjectEnum.maths, 'Maths'),
        ],
      ),
    );
  }

  Widget _buildSubjectButton(
      BuildContext context, SubjectEnum subject, String label) {
    final isSelected = _selectedSubject == subject;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: ElevatedButton(
          onPressed: () {
            setState(() {
              _selectedSubject = subject;
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).cardColor,
            foregroundColor: isSelected ? Colors.white : Colors.white70,
            elevation: isSelected ? 8 : 2,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.white12,
              ),
            ),
          ),
          child:
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildChapterListItem(BuildContext context, Chapter chapter) {
    final user = Supabase.instance.client.auth.currentUser;

    return FutureBuilder<Map<String, int>>(
      future: _getChapterStats(chapter, user?.id),
      builder: (context, snapshot) {
        String statText = '--/-- Qs';
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          final solved = snapshot.data!['solved']!;
          final total = snapshot.data!['total']!;
          statText = '$solved/$total Qs';
        }
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
          child: Card(
            color: Colors.black,
            elevation: 4,
            shadowColor: Colors.orange.shade400.withOpacity(0.25),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuestionListScreen(
                      chapterName: chapter.name,
                    ),
                  ),
                );
              },
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 18),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.orange.shade400,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.all(10),
                      child: Icon(
                        chapter.icon,
                        color: Colors.black,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            chapter.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  fontSize: 17.5,
                                ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          statText,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        Container(
                          alignment: Alignment.centerRight,
                          margin: const EdgeInsets.only(top: 2),
                          child: const Text(
                            'Total Solved',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white38,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
