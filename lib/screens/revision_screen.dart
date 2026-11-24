
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/app_state.dart';

class RevisionScreen extends StatefulWidget {
  const RevisionScreen({super.key});

  @override
  State<RevisionScreen> createState() => _RevisionScreenState();
}

class _RevisionScreenState extends State<RevisionScreen> {
  static const Color primary = Color(0xFF16845B);
  static const Color dark = Color(0xFF102A21);
  static const Color background = Color(0xFFF5F8F6);

  String? subject;

  final question = TextEditingController();
  final answer = TextEditingController();

  int index = 0;
  bool reveal = false;
  bool saving = false;

  @override
  void dispose() {
    question.dispose();
    answer.dispose();
    super.dispose();
  }

  void _nextCard(int length) {
    if (length == 0) return;

    setState(() {
      index = (index + 1) % length;
      reveal = false;
    });
  }

  void _previousCard(int length) {
    if (length == 0) return;

    setState(() {
      index = (index - 1 + length) % length;
      reveal = false;
    });
  }

  Future<void> _saveFlashcard(
    AppState state,
    String selectedSubject,
  ) async {
    if (question.text.trim().isEmpty ||
        answer.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter both a question and answer'),
        ),
      );
      return;
    }

    if (saving) return;

    setState(() => saving = true);

    try {
      await state.addFlashcard(
        selectedSubject,
        question.text.trim(),
        answer.text.trim(),
      );

      if (!mounted) return;

      question.clear();
      answer.clear();

      setState(() {
        index = 0;
        reveal = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Flashcard created successfully!'),
          backgroundColor: primary,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not save flashcard: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => saving = false);
      }
    }
  }

  Widget _header() {
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
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SMART REVISION',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.3,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Test your memory.\nStrengthen your skills.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  'Practice active recall and make what you learn stick.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            height: 76,
            width: 76,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.style_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: dark,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _flashcard({
    required Map<String, Object?>? card,
    required int current,
    required int total,
  }) {
    final cardQuestion =
        card?['question']?.toString() ?? '';

    final cardAnswer =
        card?['answer']?.toString() ?? '';

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(
              begin: 0.96,
              end: 1,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: Container(
        key: ValueKey('$current-$reveal-$total'),
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 290),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: reveal
                ? const [
                    Color(0xFF16845B),
                    Color(0xFF0D6243),
                  ]
                : const [
                    Color(0xFF183D30),
                    Color(0xFF102A21),
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: primary.withValues(alpha: 0.13),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  reveal ? 'ANSWER' : 'QUESTION',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.13),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$current / $total',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            Icon(
              reveal
                  ? Icons.check_circle_outline_rounded
                  : Icons.help_outline_rounded,
              color: Colors.white70,
              size: 36,
            ),

            const SizedBox(height: 20),

            Text(
              reveal ? cardAnswer : cardQuestion,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 21,
                height: 1.5,
                fontWeight: FontWeight.w600,
              ),
            ),

            const Spacer(),

            if (!reveal)
              Text(
                'Think of the answer before revealing it',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.65),
                  fontSize: 11,
                ),
              )
            else
              const Text(
                'Great work! Keep practising.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                ),
              ),

            const SizedBox(height: 16),

            if (card != null)
              SizedBox(
                width: double.infinity,
                height: 46,
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() => reveal = !reveal);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(
                      color: Colors.white54,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                  icon: Icon(
                    reveal
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                  ),
                  label: Text(
                    reveal ? 'Hide Answer' : 'Reveal Answer',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _navigationControls(int length) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: length <= 1
                ? null
                : () => _previousCard(length),
            icon: const Icon(Icons.arrow_back_rounded),
            label: const Text('Previous'),
            style: OutlinedButton.styleFrom(
              foregroundColor: primary,
              minimumSize: const Size(0, 48),
              side: const BorderSide(color: primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton.icon(
            onPressed: length <= 1
                ? null
                : () => _nextCard(length),
            icon: const Icon(Icons.arrow_forward_rounded),
            label: const Text('Next card'),
            style: FilledButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(0, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _inputField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    int maxLines = 2,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        minLines: 2,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Padding(
            padding: const EdgeInsets.only(bottom: 25),
            child: Icon(icon, color: primary),
          ),
          filled: true,
          fillColor: background,
          contentPadding: const EdgeInsets.all(15),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: BorderSide(
              color: Colors.grey.shade200,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: const BorderSide(
              color: primary,
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _emptyCards() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Container(
            height: 65,
            width: 65,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.style_outlined,
              color: primary,
              size: 34,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'No flashcards yet',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: dark,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            'Create your first question and answer below to start practising.',
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

        final selectedSubject = state.subjects.contains(subject)
            ? subject!
            : state.subjects.isNotEmpty
                ? state.subjects.first
                : null;

        final cards = selectedSubject == null
            ? <Map<String, Object?>>[]
            : state.flashcards
                .where((card) => card['subject'] == selectedSubject)
                .toList();

        final safeIndex = cards.isEmpty
            ? 0
            : index.clamp(0, cards.length - 1);

        final currentCard =
            cards.isEmpty ? null : cards[safeIndex];

        final progress = cards.isEmpty
            ? 0.0
            : (safeIndex + 1) / cards.length;

        return Container(
          color: background,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _header(),

              const SizedBox(height: 23),

              _sectionTitle(
                'Your revision space',
                'Choose a subject and test what you remember.',
              ),

              const SizedBox(height: 14),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'SELECT SUBJECT',
                      style: TextStyle(
                        color: dark,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 10),

                    if (state.subjects.isEmpty)
                      const Text(
                        'No subjects available. Add a subject before creating flashcards.',
                        style: TextStyle(fontSize: 13),
                      )
                    else
                      DropdownButtonFormField<String>(
                        value: selectedSubject,
                        isExpanded: true,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.menu_book_rounded,
                            color: primary,
                          ),
                          filled: true,
                          fillColor: background,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        items: state.subjects.map((s) {
                          return DropdownMenuItem<String>(
                            value: s,
                            child: Text(s),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            subject = value;
                            index = 0;
                            reveal = false;
                          });
                        },
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Flashcard practice',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: dark,
                      ),
                    ),
                  ),
                  Text(
                    '${cards.length} cards',
                    style: const TextStyle(
                      color: primary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              if (cards.isEmpty)
                _emptyCards()
              else ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: Colors.grey.shade200,
                    color: primary,
                  ),
                ),

                const SizedBox(height: 14),

                _flashcard(
                  card: currentCard,
                  current: safeIndex + 1,
                  total: cards.length,
                ),

                const SizedBox(height: 14),

                _navigationControls(cards.length),
              ],

              const SizedBox(height: 26),

              _sectionTitle(
                'Create a flashcard',
                'Turn your lessons into questions you can practise.',
              ),

              const SizedBox(height: 13),

              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _inputField(
                      label: 'Question',
                      hint: 'e.g. What is a SQL JOIN?',
                      icon: Icons.help_outline_rounded,
                      controller: question,
                    ),

                    _inputField(
                      label: 'Answer',
                      hint: 'Write the explanation or answer...',
                      icon: Icons.lightbulb_outline_rounded,
                      controller: answer,
                      maxLines: 4,
                    ),

                    const SizedBox(height: 5),

                    SizedBox(
                      height: 50,
                      child: FilledButton.icon(
                        onPressed: selectedSubject == null || saving
                            ? null
                            : () => _saveFlashcard(
                                  state,
                                  selectedSubject,
                                ),
                        style: FilledButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13),
                          ),
                        ),
                        icon: saving
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.add_rounded),
                        label: Text(
                          saving ? 'Saving...' : 'Save Flashcard',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              Container(
                padding: const EdgeInsets.all(16),
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
                            'Revision tip',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: dark,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Try answering each question from memory before revealing the answer. This helps strengthen recall.',
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.5,
                              color: Color(0xFF49665A),
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
