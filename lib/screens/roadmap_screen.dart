
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/app_state.dart';

class RoadmapScreen extends StatelessWidget {
  const RoadmapScreen({super.key});

  static const Color primary = Color(0xFF16845B);
  static const Color dark = Color(0xFF102A21);
  static const Color background = Color(0xFFF5F8F6);

  Future<void> _showTopicDialog(
    BuildContext context,
    AppState state,
    String subject, {
    int? topicId,
    String? existingTitle,
    int existingWeek = 1,
  }) async {
    final titleController = TextEditingController(
      text: existingTitle ?? '',
    );
    final weekController = TextEditingController(
      text: existingWeek.toString(),
    );
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.menu_book_rounded,
                    color: primary,
                    size: 25,
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  topicId == null
                      ? 'Add learning topic'
                      : 'Edit learning topic',
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: dark,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subject,
                  style: const TextStyle(
                    fontSize: 13,
                    color: primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: titleController,
                  autofocus: true,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: 'Topic title',
                    hintText: 'e.g. SQL joins and relationships',
                    prefixIcon: const Icon(
                      Icons.edit_note_rounded,
                      color: primary,
                    ),
                    filled: true,
                    fillColor: background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(13),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter a topic title';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 14),

                TextFormField(
                  controller: weekController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Week number',
                    hintText: 'e.g. 1',
                    prefixIcon: const Icon(
                      Icons.calendar_month_rounded,
                      color: primary,
                    ),
                    filled: true,
                    fillColor: background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(13),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    final week = int.tryParse(value ?? '');
                    if (week == null || week < 1) {
                      return 'Enter a valid week number';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 22),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () =>
                            Navigator.pop(dialogContext),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: primary,
                        ),
                        onPressed: () {
                          if (!formKey.currentState!.validate()) {
                            return;
                          }

                          Navigator.pop(dialogContext, {
                            'title': titleController.text.trim(),
                            'week': int.parse(
                              weekController.text.trim(),
                            ),
                          });
                        },
                        child: const Text('Save topic'),
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

    titleController.dispose();
    weekController.dispose();

    if (result == null || !context.mounted) return;

    try {
      if (topicId == null) {
        await state.addTopic(
          subject: subject,
          title: result['title'] as String,
          week: result['week'] as int,
        );
      } else {
        await state.updateTopic(
          id: topicId,
          subject: subject,
          title: result['title'] as String,
          week: result['week'] as int,
        );
      }

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            topicId == null
                ? 'Topic added successfully'
                : 'Topic updated successfully',
          ),
          backgroundColor: primary,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not save topic: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteTopic(
    BuildContext context,
    AppState state,
    int id,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Delete topic?',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: dark,
          ),
        ),
        content: const Text(
          'This learning topic and its completion status will be removed.',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () =>
                Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await state.deleteTopic(id);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Topic deleted successfully'),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not delete topic: $e'),
        ),
      );
    }
  }

  Widget _header({
    required int completed,
    required int total,
    required double progress,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF16845B),
            Color(0xFF0D6243),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'YOUR LEARNING JOURNEY',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(height: 9),
                    Text(
                      'Build skills, one topic at a time.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 58,
                width: 58,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.route_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Overall progress',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              Text(
                '${(progress * 100).round()}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 9,
              backgroundColor: Colors.white24,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            '$completed of $total learning topics completed',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _subjectCard(
    BuildContext context,
    AppState state,
    String subject,
  ) {
    final subjectTopics = state.topics
        .where((topic) => topic.subject == subject)
        .toList();

    final completed = subjectTopics
        .where((topic) => topic.completed)
        .length;

    final total = subjectTopics.length;

    final progress = total == 0 ? 0.0 : completed / total;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 7,
          ),
          childrenPadding: const EdgeInsets.fromLTRB(
            16,
            0,
            16,
            14,
          ),
          leading: Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              color: primary,
              size: 23,
            ),
          ),
          title: Text(
            subject,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: dark,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(
              '$completed of $total topics completed',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 11,
              ),
            ),
          ),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Subject progress',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: dark,
                  ),
                ),
                Text(
                  '${(progress * 100).round()}%',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: primary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 7,
                backgroundColor: Colors.grey.shade200,
                color: primary,
              ),
            ),

            const SizedBox(height: 12),

            if (subjectTopics.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'No learning topics yet. Add your first topic below.',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ),

            for (final topic in subjectTopics)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.only(
                    left: 8,
                    right: 4,
                  ),
                  leading: Checkbox(
                    value: topic.completed,
                    activeColor: primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    onChanged: (value) {
                      state.toggleTopic(
                        topic,
                        value ?? false,
                      );
                    },
                  ),
                  title: Text(
                    topic.title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: topic.completed
                          ? Colors.grey
                          : dark,
                      decoration: topic.completed
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 11,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Week ${topic.week}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  trailing: PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      color: Colors.grey.shade600,
                    ),
                    onSelected: (action) {
                      if (action == 'edit') {
                        _showTopicDialog(
                          context,
                          state,
                          subject,
                          topicId: topic.id,
                          existingTitle: topic.title,
                          existingWeek: topic.week,
                        );
                      } else if (action == 'delete') {
                        _deleteTopic(
                          context,
                          state,
                          topic.id,
                        );
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined, size: 18),
                            SizedBox(width: 10),
                            Text('Edit topic'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                              size: 18,
                            ),
                            SizedBox(width: 10),
                            Text('Delete topic'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 8),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showTopicDialog(
                  context,
                  state,
                  subject,
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: primary,
                  side: const BorderSide(color: primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                ),
                icon: const Icon(Icons.add_rounded),
                label: const Text(
                  'Add learning topic',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptySubjects() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Container(
            height: 70,
            width: 70,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.library_books_rounded,
              size: 35,
              color: primary,
            ),
          ),
          const SizedBox(height: 15),
          const Text(
            'Your roadmap is waiting',
            style: TextStyle(
              color: dark,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            'Add your first subject through Manage Subjects to start building your learning roadmap.',
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

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        if (state.loading) {
          return const Center(
            child: CircularProgressIndicator(color: primary),
          );
        }

        final total = state.topics.length;

        final completed = state.topics
            .where((topic) => topic.completed)
            .length;

        final progress = total == 0
            ? 0.0
            : completed / total;

        if (state.subjects.isEmpty) {
          return Container(
            color: background,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: _emptySubjects(),
              ),
            ),
          );
        }

        return Container(
          color: background,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _header(
                completed: completed,
                total: total,
                progress: progress,
              ),

              const SizedBox(height: 24),

              const Text(
                'Your subjects',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: dark,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                'Expand a subject to view and manage its learning topics.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 15),

              for (final subject in state.subjects)
                _subjectCard(context, state, subject),

              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF4EF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.tips_and_updates_outlined,
                      color: primary,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Stay consistent',
                            style: TextStyle(
                              color: dark,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Complete a few topics every day. Small, consistent steps build strong technical skills.',
                            style: TextStyle(
                              color: Color(0xFF49665A),
                              fontSize: 12,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}
