
import 'package:flutter/material.dart';

class UserGuideScreen extends StatelessWidget {
  const UserGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'FocusTech User Guide',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _welcomeCard(),
          const SizedBox(height: 20),

          _sectionTitle('1. Getting started'),
          _guideCard(
            icon: Icons.home_outlined,
            title: 'Home Dashboard',
            description:
                'Your dashboard is the starting point. '
                'It displays your scheduled subject, completed '
                'topics and total study time. Tap Start Focus '
                'Session to begin studying.',
          ),

          _guideCard(
            icon: Icons.timer_outlined,
            title: 'Focus Timer',
            description:
                'Choose your subject and begin your study session. '
                'The timer follows three stages: 25 minutes learning, '
                '25 minutes practising and 10 minutes recalling. '
                'You can pause, resume or reset your session. '
                'You can also finish early and save the time studied.',
          ),

          const SizedBox(height: 20),
          _sectionTitle('2. Track your learning'),

          _guideCard(
            icon: Icons.route_outlined,
            title: 'Learning Roadmap',
            description:
                'The roadmap contains learning topics for SQL Server, '
                'C#, Oracle, Flexcube and WCF. Expand a subject to '
                'see its topics. Tick a topic when you have completed '
                'studying it.',
          ),

          _guideCard(
            icon: Icons.edit_note,
            title: 'Learning Journal',
            description:
                'After studying, record four things: what you learned, '
                'what you practised, what you struggled with and '
                'your next learning step. You can also edit or delete '
                'previous entries.',
          ),

          const SizedBox(height: 20),
          _sectionTitle('3. Test your knowledge'),

          _guideCard(
            icon: Icons.style_outlined,
            title: 'Flashcards and Revision',
            description:
                'Create questions and answers for each subject. '
                'Read a question, try answering it from memory, '
                'then tap Reveal Answer. Use Next Card to continue. '
                'You can create, edit and delete your flashcards.',
          ),

          _guideCard(
            icon: Icons.bar_chart,
            title: 'Statistics',
            description:
                'The statistics page helps you measure your progress. '
                'It displays your total study time, study time this '
                'week, active study days, completed roadmap topics '
                'and recent study sessions.',
          ),

          const SizedBox(height: 20),
          _sectionTitle('4. Your daily study routine'),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _routineItem(
                    '1',
                    'Open Home',
                    'Check which subject is scheduled for today.',
                  ),
                  _routineItem(
                    '2',
                    'Start Focus',
                    'Complete your learning and practice session.',
                  ),
                  _routineItem(
                    '3',
                    'Update Roadmap',
                    'Mark topics you have successfully learned.',
                  ),
                  _routineItem(
                    '4',
                    'Write in Journal',
                    'Record your progress and challenges.',
                  ),
                  _routineItem(
                    '5',
                    'Create Flashcards',
                    'Save important concepts for revision.',
                  ),
                  _routineItem(
                    '6',
                    'Check Statistics',
                    'Review your progress and stay consistent.',
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),
          _sectionTitle('5. Your learning timetable'),

          Card(
            child: Column(
              children: const [
                _ScheduleRow(day: 'Monday', subject: 'SQL Server'),
                _ScheduleRow(day: 'Tuesday', subject: 'C#'),
                _ScheduleRow(day: 'Wednesday', subject: 'Oracle'),
                _ScheduleRow(day: 'Thursday', subject: 'SQL Server'),
                _ScheduleRow(day: 'Friday', subject: 'Flexcube'),
                _ScheduleRow(day: 'Saturday', subject: 'WCF'),
                _ScheduleRow(day: 'Sunday', subject: 'Revision / Rest'),
              ],
            ),
          ),

          const SizedBox(height: 20),
          _sectionTitle('6. Frequently asked questions'),

          _faq(
            'Does FocusTech require internet?',
            'Your learning records, roadmap, journal and flashcards '
                'are stored locally on your phone. Internet is not '
                'required for these features. You need internet if '
                'you want to access online learning materials.',
          ),

          _faq(
            'Will my progress be saved?',
            'Yes. Your learning records are saved in the local '
                'database on your phone. Timer information is also '
                'saved so the countdown can be recovered.',
          ),

          _faq(
            'What if I miss a study day?',
            'Do not give up or try to study everything at once. '
                'Continue with the next scheduled subject and '
                'maintain your routine.',
          ),

          _faq(
            'What should I do when I do not understand a topic?',
            'Write the challenge in your journal. Break the topic '
                'into smaller parts, find another explanation and '
                'practise again.',
          ),

          _faq(
            'Can I study for longer than one hour?',
            'Yes. The one-hour routine is a recommended starting '
                'point, not a restriction. You can take another '
                'session when you are ready.',
          ),

          const SizedBox(height: 20),
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: const Padding(
              padding: EdgeInsets.all(18),
              child: Column(
                children: [
                  Icon(Icons.emoji_events_outlined, size: 36),
                  SizedBox(height: 10),
                  Text(
                    'Consistency beats intensity.',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'You do not need to understand everything '
                    'in one day. Learn something, practise it, '
                    'revise it and keep moving forward.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 30),
          const Center(
            child: Text(
              'FocusTech • Your personal learning companion',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _welcomeCard() {
    return Card(
      color: const Color(0xFF16845B),
      child: const Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.school_outlined,
              color: Colors.white,
              size: 40,
            ),
            SizedBox(height: 14),
            Text(
              'Welcome to FocusTech!',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Your personal companion for learning, '
              'practising and improving your technical skills.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _guideCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ExpansionTile(
        leading: Icon(icon),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Text(description),
        ],
      ),
    );
  }

  Widget _faq(String question, String answer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Text(answer),
        ],
      ),
    );
  }

  Widget _routineItem(
    String number,
    String title,
    String description,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 15,
            child: Text(number),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(description),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScheduleRow extends StatelessWidget {
  const _ScheduleRow({
    required this.day,
    required this.subject,
  });

  final String day;
  final String subject;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      title: Text(day),
      trailing: Text(
        subject,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}
