
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/app_state.dart';

class ManageSubjectsScreen extends StatelessWidget {
  const ManageSubjectsScreen({super.key});

  Future<void> _showSubjectDialog(
    BuildContext context, {
    String? existingName,
  }) async {
    final isEditing = existingName != null;

    final result = await showDialog<String>(
      context: context,
      builder: (_) => _SubjectDialog(
        existingName: existingName,
      ),
    );

    if (result == null || !context.mounted) return;

    final state = context.read<AppState>();

    try {
      if (isEditing) {
        await state.updateSubject(
          oldName: existingName,
          newName: result,
        );
      } else {
        await state.addSubject(result);
      }

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing
                ? 'Subject updated successfully.'
                : 'Subject added successfully.',
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> _deleteSubject(
    BuildContext context,
    String subject,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete subject?'),
        content: Text(
          'Delete "$subject" and its roadmap topics? '
          'Historical journal entries, sessions and flashcards '
          'will remain saved with the old subject name.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true || !context.mounted) return;

    try {
      await context.read<AppState>().deleteSubject(subject);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Subject deleted.')),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Subjects'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showSubjectDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Subject'),
      ),
      body: Consumer<AppState>(
        builder: (context, state, child) {
          if (state.loading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state.subjects.isEmpty) {
            return const Center(
              child: Text('No subjects added yet. Add your first subject.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.subjects.length,
            itemBuilder: (context, index) {
              final subject = state.subjects[index];

              final topicCount = state.topics
                  .where((topic) => topic.subject == subject)
                  .length;

              return Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.menu_book),
                  ),
                  title: Text(subject),
                  subtitle: Text('$topicCount roadmap topics'),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showSubjectDialog(
                          context,
                          existingName: subject,
                        );
                      } else if (value == 'delete') {
                        _deleteSubject(context, subject);
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: 'edit',
                        child: Text('Edit'),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _SubjectDialog extends StatefulWidget {
  final String? existingName;

  const _SubjectDialog({
    this.existingName,
  });

  @override
  State<_SubjectDialog> createState() => _SubjectDialogState();
}

class _SubjectDialogState extends State<_SubjectDialog> {
  late final TextEditingController controller;
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(
      text: widget.existingName ?? '',
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingName != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit Subject' : 'Add Subject'),
      content: Form(
        key: formKey,
        child: TextFormField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Subject name',
            hintText: 'e.g. Flutter Development',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Enter a subject name';
            }
            return null;
          },
          onFieldSubmitted: (_) => _submit(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(isEditing ? 'Update' : 'Save'),
        ),
      ],
    );
  }

  void _submit() {
    if (!formKey.currentState!.validate()) return;

    Navigator.pop(context, controller.text.trim());
  }
}
