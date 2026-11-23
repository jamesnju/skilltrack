
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    super.key,
    required this.onStartFocus,
  });

  final VoidCallback onStartFocus;

  String get todaySubject {
    switch (DateTime.now().weekday) {
      case 1:
        return 'SQL Server';
      case 2:
        return 'C#';
      case 3:
        return 'Oracle';
      case 4:
        return 'SQL Server';
      case 5:
        return 'Flexcube';
      case 6:
        return 'WCF';
      default:
        return 'Revision';
    }
  }

  @override
  Widget build(BuildContext context) =>
      Consumer<AppState>(builder: (context, state, _) {
        if (state.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        final progress = state.totalTopics == 0
            ? 0.0
            : state.completedTopics / state.totalTopics;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Your learning, one focused hour at a time.',
              style: Theme.of(context).textTheme.titleMedium,
            ),

            const SizedBox(height: 16),

            // Today's learning subject
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TODAY’S SUBJECT',
                      style: TextStyle(
                        fontSize: 12,
                        letterSpacing: 1.2,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      todaySubject,
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '25 min learn  •  25 min practise  •  10 min recall',
                    ),
                    const SizedBox(height: 14),

                    // Updated button
                    FilledButton.icon(
                      onPressed: onStartFocus,
                      icon: const Icon(Icons.timer_outlined),
                      label: const Text('Start Focus Session'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Learning statistics
            Row(
              children: [
                Expanded(
                  child: _Metric(
                    title: 'Topics completed',
                    value:
                        '${state.completedTopics}/${state.totalTopics}',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _Metric(
                    title: 'Study time',
                    value:
                        '${state.totalStudyMinutes ~/ 60}h ${state.totalStudyMinutes % 60}m',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Roadmap progress
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Roadmap progress',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: progress,
                      minHeight: 9,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${(progress * 100).round()}% of all learning topics completed',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              'Your five learning areas',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),

            for (final subject in [
              'SQL Server',
              'C#',
              'Oracle',
              'Flexcube',
              'WCF',
            ]) ...[
              const SizedBox(height: 8),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.menu_book_outlined),
                  title: Text(subject),
                  subtitle: Text(
                    '${state.topics.where((t) => t.subject == subject && t.completed).length} of ${state.topics.where((t) => t.subject == subject).length} topics complete',
                  ),
                ),
              ),
            ],
          ],
        );
      });
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
