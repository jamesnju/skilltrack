
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final formKey = GlobalKey<FormState>();

  final learned = TextEditingController();
  final practised = TextEditingController();
  final struggled = TextEditingController();
  final next = TextEditingController();

  String subject = 'SQL Server';

  final List<String> subjects = [
    'SQL Server',
    'C#',
    'Oracle',
    'Flexcube',
    'WCF',
  ];

  @override
  void dispose() {
    learned.dispose();
    practised.dispose();
    struggled.dispose();
    next.dispose();
    super.dispose();
  }

  Widget field(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        maxLines: 2,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Please complete this field';
          }
          return null;
        },
      ),
    );
  }

  Future<void> saveJournal(AppState state) async {
    if (!formKey.currentState!.validate()) return;

    try {
      await state.addJournal(
        subject: subject,
        learned: learned.text.trim(),
        practised: practised.text.trim(),
        struggled: struggled.text.trim(),
        nextStep: next.text.trim(),
      );

      if (!mounted) return;

      learned.clear();
      practised.clear();
      struggled.clear();
      next.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Journal entry saved successfully'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save journal: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, child) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Record today’s learning',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),

                      const SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        initialValue: subject,
                        decoration: const InputDecoration(
                          labelText: 'Subject',
                          border: OutlineInputBorder(),
                        ),
                        items: subjects.map((s) {
                          return DropdownMenuItem<String>(
                            value: s,
                            child: Text(s),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              subject = value;
                            });
                          }
                        },
                      ),

                      const SizedBox(height: 16),

                      field('What did I learn?', learned),
                      field('What did I practise?', practised),
                      field('What did I struggle with?', struggled),
                      field('What is my next step?', next),

                      FilledButton(
                        onPressed: () => saveJournal(state),
                        child: const Text('Save journal entry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            Text(
              'Previous entries (${state.journals.length})',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),

            const SizedBox(height: 8),

            if (state.journals.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No journal entries yet. Start recording your learning!'),
                ),
              ),

            ...state.journals.map((row) {
              final createdAt = row['created_at']?.toString() ?? '';

              final date = createdAt.length >= 10
                  ? createdAt.substring(0, 10)
                  : 'Unknown date';

              return Card(
                child: ExpansionTile(
                  title: Text(
                    row['subject']?.toString() ?? 'Unknown subject',
                  ),
                  subtitle: Text(date),
                  children: [
                    for (final key in [
                      'learned',
                      'practised',
                      'struggled',
                      'next_step',
                    ])
                      ListTile(
                        title: Text({
                          'learned': 'Learned',
                          'practised': 'Practised',
                          'struggled': 'Struggled with',
                          'next_step': 'Next step',
                        }[key]!),
                        subtitle: Text(
                          row[key]?.toString() ?? '',
                        ),
                      ),
                  ],
                ),
              );
            }),
          ],
        );
      },
    );
  }
}
