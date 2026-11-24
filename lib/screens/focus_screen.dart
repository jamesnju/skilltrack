
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/app_state.dart';
import '../services/notification_service.dart';

class FocusScreen extends StatefulWidget {
  const FocusScreen({super.key});

  @override
  State<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen> {
  static const Color primary = Color(0xFF16845B);
  static const Color dark = Color(0xFF102A21);
  static const Color background = Color(0xFFF5F8F6);

  String? subject;

  int phase = 0;
  int seconds = 0;

  Timer? timer;

  bool running = false;
  bool timerInitialized = false;
  bool saving = false;

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  List<(String, int)> _getPhases(AppState state) {
    return [
      ('Learn', state.learnMinutes),
      ('Practise', state.practiseMinutes),
      ('Recall', state.recallMinutes),
    ];
  }

  String get clock {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:'
        '${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _initializeTimer(List<(String, int)> phases) {
    if (timerInitialized || phases.isEmpty) return;

    seconds = phases[0].$2 * 60;
    timerInitialized = true;
  }

  void start(String selectedSubject) {
    if (running || selectedSubject.isEmpty || saving) return;

    final state = context.read<AppState>();
    final phases = _getPhases(state);

    if (seconds <= 0) {
      seconds = phases[phase].$2 * 60;
    }

    setState(() {
      subject = selectedSubject;
      running = true;
    });

    timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) async {
        if (!mounted) return;

        if (seconds > 1) {
          setState(() {
            seconds--;
          });
        } else {
          timer?.cancel();

          setState(() {
            seconds = 0;
            running = false;
          });

          await NotificationService.instance.showSessionComplete();

          if (mounted) {
            await _phaseComplete();
          }
        }
      },
    );
  }

  void pause() {
    timer?.cancel();

    setState(() {
      running = false;
    });
  }

  void reset() {
    timer?.cancel();

    final phases = _getPhases(context.read<AppState>());

    setState(() {
      running = false;
      seconds = phases[phase].$2 * 60;
    });
  }

  void selectPhase(int index, List<(String, int)> phases) {
    if (saving) return;

    timer?.cancel();

    setState(() {
      phase = index;
      seconds = phases[index].$2 * 60;
      running = false;
    });
  }

  Future<void> _phaseComplete() async {
    if (saving) return;

    final state = context.read<AppState>();
    final phases = _getPhases(state);

    if (phase < phases.length - 1) {
      final finished = phases[phase].$1;

      setState(() {
        phase++;
        seconds = phases[phase].$2 * 60;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            '$finished complete! Next: ${phases[phase].$1}.',
          ),
        ),
      );
    } else {
      setState(() {
        saving = true;
      });

      try {
        final totalMinutes = phases.fold<int>(
          0,
          (total, item) => total + item.$2,
        );

        final completedSubject = subject;

        if (completedSubject != null && completedSubject.isNotEmpty) {
          await state.addSession(
            completedSubject,
            totalMinutes,
          );
        }

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: primary,
            content: Text(
              'Amazing! Your $totalMinutes-minute session has been saved.',
            ),
          ),
        );

        setState(() {
          phase = 0;
          seconds = phases[0].$2 * 60;
          running = false;
          timerInitialized = true;
        });
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Unable to save your study session.'),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            saving = false;
          });
        }
      }
    }
  }

  double _progress(List<(String, int)> phases) {
    final duration = phases[phase].$2 * 60;

    if (duration <= 0) return 0;

    return (1 - seconds / duration).clamp(0.0, 1.0);
  }

  Color _phaseColor(int index) {
    switch (index) {
      case 0:
        return const Color(0xFF16845B);
      case 1:
        return const Color(0xFF3979C6);
      default:
        return const Color(0xFFD69A2D);
    }
  }

  IconData _phaseIcon(int index) {
    switch (index) {
      case 0:
        return Icons.menu_book_rounded;
      case 1:
        return Icons.code_rounded;
      default:
        return Icons.psychology_alt_rounded;
    }
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

        final subjects = state.subjects;
        final phases = _getPhases(state);

        _initializeTimer(phases);

        final activeSubject = subjects.contains(subject)
            ? subject
            : subjects.isNotEmpty
                ? subjects.first
                : null;

        final totalMinutes = phases.fold<int>(
          0,
          (total, item) => total + item.$2,
        );

        final progress = _progress(phases);

        return ListView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
          children: [
            _buildHeader(),

            const SizedBox(height: 20),

            _buildSubjectSelector(subjects, activeSubject),

            const SizedBox(height: 20),

            _buildTimerCard(
              phases,
              activeSubject,
              progress,
            ),

            const SizedBox(height: 20),

            _buildSessionStats(totalMinutes),

            const SizedBox(height: 25),

            _buildSectionHeading(
              'Your session plan',
              'Follow each phase to complete your study session.',
            ),

            const SizedBox(height: 13),

            _buildPhaseCards(phases),

            const SizedBox(height: 22),

            _buildFocusRule(),

            if (subjects.isEmpty) ...[
              const SizedBox(height: 15),
              _buildEmptySubjects(),
            ],
          ],
        );
      },
    );
  }

  // HEADER

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 11,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F3EA),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bolt_rounded, color: primary, size: 15),
                  SizedBox(width: 5),
                  Text(
                    'FOCUS SESSION',
                    style: TextStyle(
                      color: primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 10,
                      letterSpacing: 0.7,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            if (running)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F3EA),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.circle, color: primary, size: 8),
                    SizedBox(width: 6),
                    Text(
                      'ACTIVE',
                      style: TextStyle(
                        color: primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),

        const SizedBox(height: 13),

        const Text(
          'One thing at a time.',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w900,
            color: dark,
            letterSpacing: -0.8,
          ),
        ),

        const SizedBox(height: 5),

        const Text(
          'Protect your attention. Build your knowledge. '
          'Make every minute count.',
          style: TextStyle(
            fontSize: 12,
            height: 1.5,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  // SUBJECT SELECTOR

  Widget _buildSubjectSelector(
    List<String> subjects,
    String? activeSubject,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFE3F3EA),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.school_rounded,
              color: primary,
              size: 24,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'What are you learning?',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 5),
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: activeSubject,
                    isExpanded: true,
                    hint: const Text(
                      'Add a subject first',
                      style: TextStyle(fontSize: 13),
                    ),
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: primary,
                    ),
                    style: const TextStyle(
                      color: dark,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                    items: subjects.map((item) {
                      return DropdownMenuItem<String>(
                        value: item,
                        child: Text(
                          item,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: running || subjects.isEmpty || saving
                        ? null
                        : (value) {
                            if (value == null) return;
                            setState(() {
                              subject = value;
                            });
                          },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // MAIN TIMER CARD

  Widget _buildTimerCard(
    List<(String, int)> phases,
    String? activeSubject,
    double progress,
  ) {
    final color = _phaseColor(phase);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 23, 20, 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF102A21),
            Color(0xFF176C4B),
            Color(0xFF16845B),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(27),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(0.17),
            blurRadius: 20,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                'CURRENT PHASE',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.13),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  '${phase + 1} / ${phases.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 220,
                width: 220,
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(
                    begin: 0,
                    end: progress,
                  ),
                  duration: const Duration(milliseconds: 500),
                  builder: (context, value, child) {
                    return CircularProgressIndicator(
                      value: value,
                      strokeWidth: 9,
                      strokeCap: StrokeCap.round,
                      backgroundColor: Colors.white.withOpacity(0.13),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF72E2AC),
                      ),
                    );
                  },
                ),
              ),

              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _phaseIcon(phase),
                    color: Colors.white70,
                    size: 25,
                  ),

                  const SizedBox(height: 12),

                  Text(
                    clock,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 43,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1.5,
                      fontFeatures: [],
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    phases[phase].$1.toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFF9BEBC1),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          Text(
            activeSubject ?? 'No subject selected',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            running
                ? 'Stay focused. You are making progress.'
                : 'Ready when you are. Start your focus session.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 11,
            ),
          ),

          const SizedBox(height: 23),

          Row(
            children: [
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 51,
                  child: FilledButton.icon(
                    onPressed: activeSubject == null || saving
                        ? null
                        : running
                            ? pause
                            : () => start(activeSubject),
                    icon: Icon(
                      running
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                    ),
                    label: Text(
                      running ? 'Pause session' : 'Start focusing',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF72E2AC),
                      foregroundColor: dark,
                      disabledBackgroundColor: Colors.white24,
                      disabledForegroundColor: Colors.white54,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              SizedBox(
                height: 51,
                width: 52,
                child: OutlinedButton(
                  onPressed: saving ? null : reset,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white38),
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Icon(Icons.refresh_rounded),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // SESSION STATISTICS

  Widget _buildSessionStats(int totalMinutes) {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            Icons.schedule_rounded,
            '$totalMinutes min',
            'Total session',
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: _statCard(
            Icons.layers_rounded,
            '3 phases',
            'Study structure',
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: _statCard(
            Icons.track_changes_rounded,
            '1 subject',
            'Stay focused',
          ),
        ),
      ],
    );
  }

  Widget _statCard(
    IconData icon,
    String value,
    String label,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 14,
        horizontal: 7,
      ),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Icon(icon, color: primary, size: 21),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(
                color: dark,
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  // SECTION HEADING

  Widget _buildSectionHeading(
    String title,
    String subtitle,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: dark,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  // PHASE CARDS

  Widget _buildPhaseCards(List<(String, int)> phases) {
    return Column(
      children: List.generate(phases.length, (index) {
        final selected = phase == index;
        final color = _phaseColor(index);

        return Padding(
          padding: const EdgeInsets.only(bottom: 11),
          child: InkWell(
            borderRadius: BorderRadius.circular(19),
            onTap: running || saving
                ? null
                : () => selectPhase(index, phases),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFFE5F4EB)
                    : Colors.white,
                borderRadius: BorderRadius.circular(19),
                border: Border.all(
                  color: selected
                      ? primary
                      : const Color(0xFFE9EEEA),
                  width: selected ? 1.5 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    height: 45,
                    width: 45,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      _phaseIcon(index),
                      color: color,
                      size: 22,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          phases[index].$1,
                          style: TextStyle(
                            color: dark,
                            fontSize: 14,
                            fontWeight: selected
                                ? FontWeight.w900
                                : FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          selected
                              ? running
                                  ? 'Currently in progress'
                                  : 'Selected phase'
                              : 'Tap to select this phase',
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${phases[index].$2} min',
                        style: const TextStyle(
                          color: dark,
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Icon(
                        selected
                            ? Icons.check_circle_rounded
                            : Icons.radio_button_unchecked_rounded,
                        color: selected ? primary : Colors.grey,
                        size: 19,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  // FOCUS RULE

  Widget _buildFocusRule() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5E4),
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: const Color(0xFFF6E6C5),
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lightbulb_outline_rounded,
            color: Color(0xFFD69A2D),
            size: 25,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your focus rule',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: dark,
                    fontSize: 13,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'If another subject or task comes to mind, '
                  'write it down for later. Do not switch tasks '
                  'during this session.',
                  style: TextStyle(
                    color: Color(0xFF786746),
                    fontSize: 11,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // EMPTY SUBJECTS

  Widget _buildEmptySubjects() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: const Column(
        children: [
          Icon(
            Icons.menu_book_rounded,
            size: 40,
            color: primary,
          ),
          SizedBox(height: 12),
          Text(
            'No subjects yet',
            style: TextStyle(
              color: dark,
              fontWeight: FontWeight.w900,
              fontSize: 15,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Open Manage Subjects from the app menu '
            'to add your first learning subject.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black54,
              fontSize: 11,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: const Color(0xFFEBF0EC),
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
