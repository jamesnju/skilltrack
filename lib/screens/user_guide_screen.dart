
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/app_state.dart';

class UserGuideScreen extends StatelessWidget {
  const UserGuideScreen({super.key});

  static const Color primary = Color(0xFF16845B);
  static const Color dark = Color(0xFF102A21);
  static const Color background = Color(0xFFF5F8F6);

  static const List<String> weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final subjects = state.subjects;
        final todayIndex = DateTime.now().weekday - 1;

      return Scaffold(
  backgroundColor: background,

  // Top navigation bar
  appBar: AppBar(
    backgroundColor: background,
    elevation: 0,
    scrolledUnderElevation: 0,
    leading: IconButton(
      icon: const Icon(
        Icons.arrow_back_ios_new_rounded,
        color: dark,
        size: 20,
      ),
      onPressed: () {
        Navigator.pop(context);
      },
    ),
    title: const Text(
      'User Guide',
      style: TextStyle(
        color: dark,
        fontSize: 18,
        fontWeight: FontWeight.w800,
      ),
    ),
  ),

  // User guide content
  body: ListView(
    padding: const EdgeInsets.fromLTRB(18, 20, 18, 30),
    children: [
      _buildWelcomeCard(),

      const SizedBox(height: 22),

      _buildSectionHeading(
        'Your learning overview',
        'A quick look at your current learning activity.',
      ),

      const SizedBox(height: 12),

      _buildOverview(state),

      const SizedBox(height: 24),

      _buildSectionHeading(
        '1. Getting started',
        'Learn how to use the main features.',
      ),

      const SizedBox(height: 12),

      _guideCard(
        icon: Icons.home_rounded,
        title: 'Home Dashboard',
        description:
            'Your dashboard is your learning command centre. '
            'It displays your learning progress, study time, '
            'roadmap completion and recommended subject. '
            'Use Start Focus Session to begin studying.',
      ),

      _guideCard(
        icon: Icons.timer_rounded,
        title: 'Focus Timer',
        description:
            'Choose a subject and work through your configured '
            'learning routine. The timer has three stages: '
            'Learn, Practise and Recall. You can pause, resume, '
            'reset and move between phases. Your completed '
            'session is saved to your learning records.',
      ),

      _guideCard(
        icon: Icons.tune_rounded,
        title: 'Settings',
        description:
            'Configure your daily and weekly learning goals. '
            'You can also change the duration of Learn, '
            'Practise and Recall and configure your daily '
            'study reminder.',
      ),

      const SizedBox(height: 22),

      _buildSectionHeading(
        '2. Track your learning',
        'Keep your knowledge organised.',
      ),

      const SizedBox(height: 12),

      _guideCard(
        icon: Icons.route_rounded,
        title: 'Learning Roadmap',
        description:
            'Your roadmap contains learning topics organised '
            'by subject. Expand a subject to view its topics. '
            'Mark a topic as completed when you understand it. '
            'You can also add, edit and delete topics.',
      ),

      _guideCard(
        icon: Icons.edit_note_rounded,
        title: 'Learning Journal',
        description:
            'Reflect on your study sessions by recording what '
            'you learned, what you practised, what you struggled '
            'with and what you plan to do next. Your entries '
            'are stored locally on your device.',
      ),

      _guideCard(
        icon: Icons.bar_chart_rounded,
        title: 'Analytics',
        description:
            'Review your total study time, completed topics, '
            'journal entries and study time by subject. '
            'Use the charts to identify the subjects receiving '
            'your attention.',
      ),

      const SizedBox(height: 22),

      _buildSectionHeading(
        '3. Test your knowledge',
        'Turn learning into long-term understanding.',
      ),

      const SizedBox(height: 12),

      _guideCard(
        icon: Icons.style_rounded,
        title: 'Flashcards and Revision',
        description:
            'Create questions and answers for your subjects. '
            'Read the question, attempt to answer it from memory, '
            'then reveal the answer. Move through your cards '
            'to practise active recall.',
      ),

      _guideCard(
        icon: Icons.library_books_rounded,
        title: 'Manage Subjects',
        description:
            'Add subjects you want to learn, edit their names '
            'or remove subjects you no longer need. Your '
            'Roadmap, Journal and Revision screens use '
            'your saved subjects.',
      ),

      const SizedBox(height: 22),

      _buildSectionHeading(
        '4. Deep Focus',
        'Create a more focused study environment.',
      ),

      const SizedBox(height: 12),

      _guideCard(
        icon: Icons.headphones_rounded,
        title: 'Focus Sounds',
        description:
            'Choose a concentration sound such as background '
            'noise, rain or ambient audio. Connect headphones '
            'or earphones for a more immersive experience. '
            'Sound playback requires the corresponding audio '
            'files to be available in the app.',
      ),

      _guideCard(
        icon: Icons.notifications_off_rounded,
        title: 'Do Not Disturb',
        description:
            'Deep Focus can use Android Do Not Disturb to '
            'reduce notification distractions. Android requires '
            'you to grant notification policy access first. '
            'Your phone settings may still allow selected '
            'calls or other exceptions.',
      ),

      const SizedBox(height: 22),

      _buildSectionHeading(
        '5. Your configured study routine',
        'Your timer follows the durations selected in Settings.',
      ),

      const SizedBox(height: 12),

      _buildRoutineCard(state),

      const SizedBox(height: 22),

      _buildSectionHeading(
        '6. Your weekly timetable',
        'Your subjects are loaded from your saved subject list.',
      ),

      const SizedBox(height: 12),

      _buildTimetable(
        subjects: subjects,
        todayIndex: todayIndex,
      ),

      const SizedBox(height: 22),

      _buildSectionHeading(
        '7. Frequently asked questions',
        'Answers to common questions about FocusTech.',
      ),

      const SizedBox(height: 12),

      _faq(
        'Does FocusTech require internet?',
        'Your subjects, roadmap, journal, flashcards and '
            'learning records are stored locally on your phone. '
            'These features do not require internet. You need '
            'internet to access external online learning materials.',
      ),

      _faq(
        'Will my progress be saved?',
        'Your learning records are stored in the local SQLite '
            'database on your phone. Uninstalling the app or '
            'clearing its storage may erase locally stored data, '
            'so consider keeping backups.',
      ),

      _faq(
        'Can I change my study durations?',
        'Yes. Open Settings and adjust the Learn, Practise '
            'and Recall durations. Your Focus Timer uses '
            'those configured durations.',
      ),

      _faq(
        'What happens if I miss a study day?',
        'Do not give up or try to study everything at once. '
            'Continue with your next learning session and '
            'maintain your routine.',
      ),

      _faq(
        'What should I do when I do not understand a topic?',
        'Record the challenge in your Learning Journal. '
            'Break the topic into smaller parts, find another '
            'explanation and practise again.',
      ),

      _faq(
        'Can I study for longer than one hour?',
        'Yes. Your daily learning goal is configurable. '
            'You can adjust your goals and phase durations '
            'in Settings.',
      ),

      _faq(
        'Can Deep Focus block every distraction?',
        'No. Android Do Not Disturb reduces interruptions '
            'but cannot guarantee that every app or distraction '
            'will be blocked. Environmental distractions also '
            'depend on your surroundings.',
      ),

      const SizedBox(height: 22),

      _buildMotivationCard(),

      const SizedBox(height: 22),

      const Center(
        child: Text(
          'FocusTech • Your personal learning companion',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    ],
  ),
);



      },
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF16845B),
            Color(0xFF102A21),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.school_rounded,
            color: Colors.white,
            size: 42,
          ),
          SizedBox(height: 18),
          Text(
            'Welcome to FocusTech!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: 9),
          Text(
            'Your personal companion for learning, practising, '
            'revising and improving your technical skills.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.6,
            ),
          ),
          SizedBox(height: 18),
          Row(
            children: [
              Icon(
                Icons.check_circle_outline_rounded,
                color: Color(0xFFB7F7D8),
                size: 17,
              ),
              SizedBox(width: 7),
              Text(
                'Learn • Practise • Recall',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeading(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: dark,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildOverview(AppState state) {
    return Row(
      children: [
        Expanded(
          child: _overviewCard(
            icon: Icons.timer_outlined,
            label: 'Study minutes',
            value: '${state.totalStudyMinutes}',
            color: primary,
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: _overviewCard(
            icon: Icons.check_circle_outline_rounded,
            label: 'Topics done',
            value: '${state.completedTopics}',
            color: const Color(0xFF3976C5),
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: _overviewCard(
            icon: Icons.menu_book_rounded,
            label: 'Subjects',
            value: '${state.subjects.length}',
            color: const Color(0xFFB7791F),
          ),
        ),
      ],
    );
  }

  Widget _overviewCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 21),
          const SizedBox(height: 11),
          Text(
            value,
            style: const TextStyle(
              color: dark,
              fontSize: 21,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 2,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _guideCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      decoration: _cardDecoration(),
      child: Theme(
        data: ThemeData().copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          leading: Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: primary, size: 21),
          ),
          title: Text(
            title,
            style: const TextStyle(
              color: dark,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
          iconColor: primary,
          collapsedIconColor: Colors.grey,
          childrenPadding: const EdgeInsets.fromLTRB(17, 0, 17, 17),
          children: [
            Text(
              description,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 12,
                height: 1.7,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoutineCard(AppState state) {
    final phases = [
      (
        icon: Icons.lightbulb_outline_rounded,
        title: 'Learn',
        minutes: state.learnMinutes,
        description: 'Understand new concepts.',
      ),
      (
        icon: Icons.code_rounded,
        title: 'Practise',
        minutes: state.practiseMinutes,
        description: 'Apply what you have learned.',
      ),
      (
        icon: Icons.psychology_outlined,
        title: 'Recall',
        minutes: state.recallMinutes,
        description: 'Test your memory without notes.',
      ),
    ];

    final totalMinutes =
        state.learnMinutes + state.practiseMinutes + state.recallMinutes;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Your focus session',
                  style: TextStyle(
                    color: dark,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$totalMinutes min',
                  style: const TextStyle(
                    color: primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 17),
          for (var i = 0; i < phases.length; i++) ...[
            Row(
              children: [
                Container(
                  height: 42,
                  width: 42,
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.09),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(
                    phases[i].icon,
                    color: primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        phases[i].title,
                        style: const TextStyle(
                          color: dark,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        phases[i].description,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${phases[i].minutes} min',
                  style: const TextStyle(
                    color: primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            if (i != phases.length - 1)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Divider(
                  height: 1,
                  color: Colors.grey.shade200,
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimetable({
    required List<dynamic> subjects,
    required int todayIndex,
  }) {
    if (subjects.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: _cardDecoration(),
        child: Column(
          children: [
            Icon(
              Icons.calendar_month_rounded,
              size: 35,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 10),
            const Text(
              'No subjects added yet',
              style: TextStyle(
                color: dark,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Add your subjects from Manage Subjects to build your learning timetable.',
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

    return Container(
      decoration: _cardDecoration(),
      child: Column(
        children: [
          for (var i = 0; i < weekdays.length; i++)
            _scheduleRow(
              day: weekdays[i],
              subject: i == 6
                  ? 'Revision / Rest'
                  : subjects[i % subjects.length].toString(),
              isToday: i == todayIndex,
              isLast: i == weekdays.length - 1,
            ),
        ],
      ),
    );
  }

  Widget _scheduleRow({
    required String day,
    required String subject,
    required bool isToday,
    required bool isLast,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: isToday ? primary.withValues(alpha: 0.07) : Colors.transparent,
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: Colors.grey.withValues(alpha: 0.12),
                ),
              ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                if (isToday)
                  Container(
                    height: 7,
                    width: 7,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: const BoxDecoration(
                      color: primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                Text(
                  day,
                  style: TextStyle(
                    color: isToday ? primary : dark,
                    fontSize: 12,
                    fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            child: Text(
              subject,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isToday ? primary : Colors.grey.shade700,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (isToday) ...[
            const SizedBox(width: 7),
            const Icon(
              Icons.today_rounded,
              size: 16,
              color: primary,
            ),
          ],
        ],
      ),
    );
  }

  Widget _faq(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: _cardDecoration(),
      child: Theme(
        data: ThemeData().copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          title: Text(
            question,
            style: const TextStyle(
              color: dark,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          iconColor: primary,
          collapsedIconColor: Colors.grey,
          childrenPadding: const EdgeInsets.fromLTRB(17, 0, 17, 17),
          children: [
            Text(
              answer,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 12,
                height: 1.7,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMotivationCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: dark,
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.emoji_events_rounded,
            color: Color(0xFFFFD166),
            size: 38,
          ),
          SizedBox(height: 13),
          Text(
            'Consistency beats intensity.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 9),
          Text(
            'You do not need to understand everything in one day. '
            'Learn something, practise it, recall it and keep moving forward.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(
        color: Colors.black.withValues(alpha: 0.035),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.02),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}
