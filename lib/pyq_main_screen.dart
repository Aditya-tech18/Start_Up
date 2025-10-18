// File: lib/pyq_main_screen.dart

import 'package:flutter/material.dart';
import 'question_screen.dart'; // Import the Question Screen

// --- Subject and Chapter Data Models ---
enum SubjectEnum { physics, chemistry, maths }

class Chapter {
  final String name;
  final IconData icon;
  final Color iconColor;
  final String year2025Stats;
  final String year2024Stats;
  final String completionStats; // e.g., '0/118 Qs'

  Chapter({
    required this.name,
    required this.icon,
    required this.iconColor,
    required this.year2025Stats,
    required this.year2024Stats,
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

  final List<String> _availableYears = List.generate(11, (i) => (2025 - i).toString());

  // --- FULL 31 PHYSICS CHAPTER DATA ---
  final Map<SubjectEnum, List<Chapter>> _allChapters = {
    SubjectEnum.physics: [
      Chapter(name: 'Math in Physics', icon: Icons.functions, iconColor: Colors.purple.shade300, year2025Stats: '7 Qs ↑', year2024Stats: '19 Qs', completionStats: '0/118 Qs'),
      Chapter(name: 'Units & Dimensions', icon: Icons.straighten, iconColor: Colors.green.shade400, year2025Stats: '25 Qs ↓', year2024Stats: '16 Qs', completionStats: '0/133 Qs'),
      Chapter(name: 'Motion in 1D', icon: Icons.arrow_right_alt, iconColor: Colors.blue.shade400, year2025Stats: '11 Qs ↓', year2024Stats: '22 Qs', completionStats: '0/168 Qs'),
      Chapter(name: 'Motion in 2D', icon: Icons.alt_route, iconColor: Colors.red.shade400, year2025Stats: '9 Qs ↓', year2024Stats: '11 Qs', completionStats: '1/118 Qs'),
      Chapter(name: 'Laws of Motion', icon: Icons.sync_alt, iconColor: Colors.orange.shade400, year2025Stats: '8 Qs ↓', year2024Stats: '24 Qs', completionStats: '0/191 Qs'),
      Chapter(name: 'Work Power Energy', icon: Icons.power, iconColor: Colors.yellow.shade700, year2025Stats: '18 Qs ↓', year2024Stats: '20 Qs', completionStats: '0/168 Qs'),
      Chapter(name: 'COM & Collisions', icon: Icons.blur_circular, iconColor: Colors.cyan.shade400, year2025Stats: '8 Qs ↓', year2024Stats: '11 Qs', completionStats: '0/123 Qs'),
      Chapter(name: 'Rotational Motion', icon: Icons.rotate_right, iconColor: Colors.purple.shade500, year2025Stats: '29 Qs ↑', year2024Stats: '21 Qs', completionStats: '0/250 Qs'),
      Chapter(name: 'Gravitation', icon: Icons.public, iconColor: Colors.deepOrange.shade400, year2025Stats: '12 Qs ↓', year2024Stats: '23 Qs', completionStats: '0/210 Qs'),
      Chapter(name: 'Properties of Solids', icon: Icons.block, iconColor: Colors.green.shade600, year2025Stats: '9 Qs ↓', year2024Stats: '15 Qs', completionStats: '0/101 Qs'),
      Chapter(name: 'Properties of Fluids', icon: Icons.waves, iconColor: Colors.blue.shade600, year2025Stats: '22 Qs ↓', year2024Stats: '25 Qs', completionStats: '14/171 Qs'),
      Chapter(name: 'Thermal Properties', icon: Icons.thermostat_outlined, iconColor: Colors.red.shade600, year2025Stats: '11 Qs ↑', year2024Stats: '5 Qs', completionStats: '9/129 Qs'),
      Chapter(name: 'Thermodynamics', icon: Icons.local_fire_department, iconColor: Colors.orange.shade700, year2025Stats: '27 Qs ↑', year2024Stats: '16 Qs', completionStats: '20/211 Qs'),
      Chapter(name: 'KTG', icon: Icons.bubble_chart, iconColor: Colors.lightGreen.shade400, year2025Stats: '7 Qs ↓', year2024Stats: '4 Qs', completionStats: '4/155 Qs'),
      Chapter(name: 'Oscillations', icon: Icons.waves_sharp, iconColor: Colors.blueGrey.shade400, year2025Stats: '11 Qs ↓', year2024Stats: '13 Qs', completionStats: '8/176 Qs'),
      Chapter(name: 'Waves & Sound', icon: Icons.volume_up, iconColor: Colors.purple.shade400, year2025Stats: '11 Qs ↑', year2024Stats: '10 Qs', completionStats: '0/169 Qs'),
      Chapter(name: 'Electrostatics', icon: Icons.electric_bolt, iconColor: Colors.indigo.shade400, year2025Stats: '36 Qs ↑', year2024Stats: '32 Qs', completionStats: '11/279 Qs'),
      Chapter(name: 'Capacitance', icon: Icons.battery_charging_full, iconColor: Colors.teal.shade400, year2025Stats: '16 Qs ↑', year2024Stats: '15 Qs', completionStats: '0/163 Qs'),
      Chapter(name: 'Current Electricity', icon: Icons.flash_on, iconColor: Colors.red.shade700, year2025Stats: '20 Qs ↓', year2024Stats: '47 Qs', completionStats: '0/374 Qs'),
      Chapter(name: 'Magnetic Properties', icon: Icons.compass_calibration, iconColor: Colors.cyan.shade700, year2025Stats: '5 Qs ↓', year2024Stats: '5 Qs', completionStats: '0/77 Qs'),
      
      Chapter(name: 'EMI', icon: Icons.bolt, iconColor: Colors.blue.shade600, year2025Stats: '8 Qs ↓', year2024Stats: '16 Qs', completionStats: '0/132 Qs'),
      Chapter(name: 'AC Circuits', icon: Icons.network_check, iconColor: Colors.lightBlue.shade400, year2025Stats: '10 Qs ↓', year2024Stats: '10 Qs', completionStats: '0/183 Qs'),
      Chapter(name: 'EM Waves', icon: Icons.wifi, iconColor: Colors.purple.shade600, year2025Stats: '10 Qs ↓', year2024Stats: '16 Qs', completionStats: '0/145 Qs'),
      Chapter(name: 'Ray Optics', icon: Icons.travel_explore, iconColor: Colors.lightBlueAccent.shade400, year2025Stats: '43 Qs ↑', year2024Stats: '21 Qs', completionStats: '0/266 Qs'),
      Chapter(name: 'Wave Optics', icon: Icons.waving_hand, iconColor: Colors.green.shade500, year2025Stats: '19 Qs ↓', year2024Stats: '22 Qs', completionStats: '0/165 Qs'),
      Chapter(name: 'Dual Nature', icon: Icons.devices_other, iconColor: Colors.indigo.shade300, year2025Stats: '18 Qs ↓', year2024Stats: '22 Qs', completionStats: '0/190 Qs'),
      Chapter(name: 'Atomic Physics', icon: Icons.radio_button_checked, iconColor: Colors.pink.shade400, year2025Stats: '12 Qs ↓', year2024Stats: '23 Qs', completionStats: '0/145 Qs'),
      Chapter(name: 'Nuclear Physics', icon: Icons.radio_button_checked, iconColor: Colors.deepOrange.shade700, year2025Stats: '8 Qs ↓', year2024Stats: '18 Qs', completionStats: '8/151 Qs'),
      Chapter(name: 'Semiconductors', icon: Icons.memory, iconColor: Colors.teal.shade700, year2025Stats: '18 Qs ↓', year2024Stats: '22 Qs', completionStats: '62/228 Qs'),
      Chapter(name: 'Communication System', icon: Icons.speaker_phone, iconColor: Colors.blueGrey.shade700, year2025Stats: '0 Qs', year2024Stats: '0 Qs', completionStats: '0/107 Qs'),
      Chapter(name: 'Experimental Physics', icon: Icons.query_builder, iconColor: Colors.deepPurple.shade700, year2025Stats: '4 Qs ↓', year2024Stats: '12 Qs', completionStats: '0/63 Qs'),
    ],
    // Placeholders for Chemistry and Maths chapters
    SubjectEnum.chemistry: [
      Chapter(name: 'Chemical Kinetics', icon: Icons.link, iconColor: Colors.blue, year2025Stats: '30 Qs ↑', year2024Stats: '25 Qs', completionStats: '0/200 Qs'),
      Chapter(name: 'Coordination Compounds', icon: Icons.all_inclusive, iconColor: Colors.green, year2025Stats: '22 Qs ↓', year2024Stats: '28 Qs', completionStats: '0/180 Qs'),
      Chapter(name: 'Organic Chemistry Basic', icon: Icons.local_fire_department, iconColor: Colors.orange, year2025Stats: '15 Qs', year2024Stats: '15 Qs', completionStats: '0/150 Qs'),
    ],
    SubjectEnum.maths: [
      Chapter(name: 'Sets, Relations & Functions', icon: Icons.numbers, iconColor: Colors.purple, year2025Stats: '30 Qs ↓', year2024Stats: '35 Qs', completionStats: '0/200 Qs'),
      Chapter(name: 'Coordinate Geometry', icon: Icons.square_foot, iconColor: Colors.red, year2025Stats: '25 Qs ↑', year2024Stats: '20 Qs', completionStats: '0/150 Qs'),
      Chapter(name: 'Differential Equations', icon: Icons.show_chart, iconColor: Colors.teal, year2025Stats: '35 Qs ↑', year2024Stats: '30 Qs', completionStats: '0/250 Qs'),
    ],
  };

  @override
  void initState() {
    super.initState();
    _selectedYear = _availableYears.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('JEE Mains PYQ Bank', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Corrected line
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildSubjectSelector(context),
          _buildFilterRow(context),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 16),
              itemCount: _allChapters[_selectedSubject]?.length ?? 0,
              itemBuilder: (context, index) {
                final chapter = _allChapters[_selectedSubject]![index];
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
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
          _buildFilterButton(context, 'Difficulty', Icons.filter_list),
          _buildFilterButton(context, 'Sort', Icons.sort),
        ],
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

  Widget _buildSubjectButton(BuildContext context, SubjectEnum subject, String label) {
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
            backgroundColor: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).cardColor,
            foregroundColor: isSelected ? Colors.white : Colors.white70,
            elevation: isSelected ? 8 : 2,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(
                color: isSelected ? Theme.of(context).colorScheme.primary : Colors.white12,
              ),
            ),
          ),
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildChapterListItem(BuildContext context, Chapter chapter) {
    Color trendColor = Colors.white70;
    IconData trendIcon = Icons.arrow_right_alt;
    if (chapter.year2025Stats.contains('↑')) {
      trendColor = Colors.green;
      trendIcon = Icons.arrow_upward;
    } else if (chapter.year2025Stats.contains('↓')) {
      trendColor = Colors.red;
      trendIcon = Icons.arrow_downward;
    }

    Color completionColor = chapter.completionStats.startsWith('0/') ? Colors.white54 : const Color(0xFF00C0A4);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Card(
        color: Theme.of(context).cardColor,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: InkWell(
          onTap: () {
            // Navigate to the QuestionScreen, passing the chapter name and current selected year
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => QuestionScreen(
                  chapterName: chapter.name,
                  subjectName: _selectedSubject.toString().split('.').last,
                  selectedYear: _selectedYear, // Pass the selected year
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(chapter.icon, color: chapter.iconColor, size: 24),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          chapter.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                Row(
                  children: [
                    SizedBox(
                      width: 100,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('2025: ${chapter.year2025Stats.split(' ')[0]}', style: TextStyle(fontSize: 12, color: trendColor)),
                              Icon(trendIcon, size: 12, color: trendColor),
                            ],
                          ),
                          Text('2024: ${chapter.year2024Stats}', style: const TextStyle(fontSize: 10, color: Colors.white54)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(chapter.completionStats, style: TextStyle(fontSize: 14, color: completionColor, fontWeight: FontWeight.bold)),
                        const Text('Total Solved', style: TextStyle(fontSize: 10, color: Colors.white54)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}