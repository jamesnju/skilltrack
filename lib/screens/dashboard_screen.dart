
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../services/app_state.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    super.key,
    required this.onStartFocus,
  });

  final VoidCallback onStartFocus;

  static const Color primary = Color(0xFF16845B);
  static const Color background = Color(0xFFF6F8F7);

  String _getTodaySubject(List<String> subjects) {
    if (subjects.isEmpty) return 'No subjects added';

    final index = (DateTime.now().weekday - 1) % subjects.length;
    return subjects[index];
  }

  String _formatStudyTime(int minutes) {
    return '${minutes ~/ 60}h ${minutes % 60}m';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        if (state.loading) {
          return const Center(
            child: CircularProgressIndicator(color: primary),
          );
        }

        final progress = state.totalTopics == 0
            ? 0.0
            : (state.completedTopics / state.totalTopics)
                .clamp(0.0, 1.0);

        final todaySubject = _getTodaySubject(state.subjects);

        final dailyGoal = state.dailyGoalMinutes;
        final todayMinutes = state.totalStudyMinutes;
        final dailyProgress = dailyGoal <= 0
            ? 0.0
            : (todayMinutes / dailyGoal).clamp(0.0, 1.0);

        final today = DateFormat('EEEE, d MMMM yyyy')
            .format(DateTime.now());

        return Container(
          color: background,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 30),
            children: [
              // WELCOME HEADER
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'WELCOME BACK 👋',
                          style: TextStyle(
                            color: primary,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Let’s keep growing.',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF18352A),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          today,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE1F2E9),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.school_rounded,
                      color: primary,
                      size: 27,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // TODAY'S FOCUS CARD
              _buildFocusCard(
                context,
                todaySubject,
                state,
              ),

              const SizedBox(height: 22),

              // DAILY GOAL
              _buildSectionTitle('Your daily goal', 'Keep going'),

              const SizedBox(height: 12),

              _buildDailyGoalCard(
                todayMinutes,
                dailyGoal,
                dailyProgress,
              ),

              const SizedBox(height: 22),

              // STATISTICS
              _buildSectionTitle('Your progress', 'All time'),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.check_circle_outline_rounded,
                      title: 'Topics done',
                      value:
                          '${state.completedTopics}/${state.totalTopics}',
                      color: const Color(0xFF16845B),
                      backgroundColor: const Color(0xFFE5F4EC),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.access_time_rounded,
                      title: 'Study time',
                      value: _formatStudyTime(state.totalStudyMinutes),
                      color: const Color(0xFF5576C7),
                      backgroundColor: const Color(0xFFEAF0FF),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              // ROADMAP PROGRESS
              _buildSectionTitle('Learning roadmap', 'Overall'),

              const SizedBox(height: 12),

              _buildRoadmapCard(
                progress,
                state.completedTopics,
                state.totalTopics,
              ),

              const SizedBox(height: 24),

              // SUBJECTS
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSectionTitle('My learning areas', null),
                  Text(
                    '${state.subjects.length} subjects',
                    style: const TextStyle(
                      color: primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              if (state.subjects.isEmpty)
                _buildEmptySubjects()
              else
                ...state.subjects.asMap().entries.map((entry) {
                  final index = entry.key;
                  final subject = entry.value;

                  final subjectTopics = state.topics
                      .where((topic) => topic.subject == subject)
                      .toList();

                  final completed = subjectTopics
                      .where((topic) => topic.completed)
                      .length;

                  final subjectProgress = subjectTopics.isEmpty
                      ? 0.0
                      : completed / subjectTopics.length;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildSubjectCard(
                      subject,
                      completed,
                      subjectTopics.length,
                      subjectProgress,
                      index,
                    ),
                  );
                }),

              const SizedBox(height: 12),

              // DAILY ROUTINE
              _buildRoutineCard(state),

              const SizedBox(height: 20),

              Center(
                child: Text(
                  'Small steps every day lead to big results.',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --------------------------------------------------
  // FOCUS CARD
  // --------------------------------------------------

  Widget _buildFocusCard(
    BuildContext context,
    String subject,
    AppState state,
  ) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF16845B),
            Color(0xFF0D6043),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(0.20),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.bolt_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 7),
              const Text(
                'TODAY’S LEARNING SESSION',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Text(
            subject,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 27,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 7),

          const Text(
            'Make today count. Focus on learning one thing well.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              _buildPhase(
                Icons.menu_book_rounded,
                'Learn',
                state.learnMinutes,
              ),
              _phaseDivider(),
              _buildPhase(
                Icons.code_rounded,
                'Practise',
                state.practiseMinutes,
              ),
              _phaseDivider(),
              _buildPhase(
                Icons.psychology_rounded,
                'Recall',
                state.recallMinutes,
              ),
            ],
          ),

          const SizedBox(height: 22),

          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: state.subjects.isEmpty
                  ? null
                  : onStartFocus,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: primary,
                disabledBackgroundColor: Colors.white54,
                disabledForegroundColor: Colors.grey,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text(
                'Start Focus Session',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhase(IconData icon, String title, int minutes) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 7),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            '$minutes min',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _phaseDivider() {
    return Container(
      width: 1,
      height: 43,
      color: Colors.white24,
    );
  }

  // --------------------------------------------------
  // DAILY GOAL
  // --------------------------------------------------

  Widget _buildDailyGoalCard(
    int minutes,
    int goal,
    double progress,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          SizedBox(
            width: 75,
            height: 75,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox.expand(
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 7,
                    backgroundColor: const Color(0xFFE9EFEB),
                    valueColor:
                        const AlwaysStoppedAnimation(primary),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Text(
                  '${(progress * 100).round()}%',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: Color(0xFF18352A),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 18),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Daily learning target',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$minutes minutes studied out of $goal minutes',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  goal <= 0
                      ? 'Set a daily goal in Settings'
                      : minutes >= goal
                          ? 'Amazing! Daily goal achieved 🎉'
                          : '${goal - minutes} minutes left to reach your goal',
                  style: const TextStyle(
                    color: primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // STATISTICS
  // --------------------------------------------------

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required Color backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 38,
            width: 38,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 21),
          ),
          const SizedBox(height: 15),
          Text(
            value,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w800,
              color: Color(0xFF18352A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // ROADMAP
  // --------------------------------------------------

  Widget _buildRoadmapCard(
    double progress,
    int completed,
    int total,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Overall completion',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                '${(progress * 100).round()}%',
                style: const TextStyle(
                  color: primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: const Color(0xFFE9EFEB),
              valueColor: const AlwaysStoppedAnimation(primary),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '$completed of $total learning topics completed',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // SUBJECT CARDS
  // --------------------------------------------------

  Widget _buildSubjectCard(
    String subject,
    int completed,
    int total,
    double progress,
    int index,
  ) {
    final colors = [
      const Color(0xFF16845B),
      const Color(0xFF5576C7),
      const Color(0xFFB47738),
      const Color(0xFF8B60B5),
      const Color(0xFF368E9A),
    ];

    final icons = [
      Icons.storage_rounded,
      Icons.code_rounded,
      Icons.data_object_rounded,
      Icons.account_balance_rounded,
      Icons.cloud_outlined,
    ];

    final color = colors[index % colors.length];
    final icon = icons[index % icons.length];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 24),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF18352A),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '$completed of $total topics completed',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 9),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: const Color(0xFFE9EFEB),
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          Text(
            '${(progress * 100).round()}%',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // DAILY ROUTINE
  // --------------------------------------------------

  Widget _buildRoutineCard(AppState state) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFE6F3EB),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_awesome_rounded, color: primary),
              SizedBox(width: 9),
              Text(
                'Your learning routine',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF18352A),
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _routineRow(
            '01',
            'Learn',
            '${state.learnMinutes} minutes',
            Icons.menu_book_rounded,
          ),
          _routineRow(
            '02',
            'Practise',
            '${state.practiseMinutes} minutes',
            Icons.code_rounded,
          ),
          _routineRow(
            '03',
            'Recall',
            '${state.recallMinutes} minutes',
            Icons.psychology_rounded,
          ),
        ],
      ),
    );
  }

  Widget _routineRow(
    String number,
    String title,
    String duration,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(
            number,
            style: const TextStyle(
              color: primary,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 12),
          Icon(icon, size: 18, color: primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Color(0xFF18352A),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          Text(
            duration,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // EMPTY STATE
  // --------------------------------------------------

  Widget _buildEmptySubjects() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Icon(
            Icons.menu_book_outlined,
            size: 42,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          const Text(
            'Your learning journey starts here',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            'Add your first subject in Manage Subjects to start tracking your progress.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // SHARED UI
  // --------------------------------------------------

  Widget _buildSectionTitle(String title, String? trailing) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF18352A),
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        if (trailing != null)
          Text(
            trailing,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 11,
            ),
          ),
      ],
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: const Color(0xFFEDF1EE),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.025),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}
