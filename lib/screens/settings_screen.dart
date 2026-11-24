
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/app_state.dart';
import '../services/notification_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _dailyGoal = 60;
  int _weeklyGoal = 420;

  int _learnMinutes = 25;
  int _practiseMinutes = 25;
  int _recallMinutes = 10;

  bool _remindersEnabled = false;
  TimeOfDay _reminderTime = const TimeOfDay(
    hour: 18,
    minute: 0,
  );

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSettings();
    });
  }

  Future<void> _loadSettings() async {
    if (!mounted) return;

    final appState = context.read<AppState>();

    final reminderSettings = await NotificationService.instance
        .getDailyReminderSettings();

    if (!mounted) return;

    setState(() {
      _dailyGoal = appState.dailyGoalMinutes;
      _weeklyGoal = appState.weeklyGoalMinutes;

      _learnMinutes = appState.learnMinutes;
      _practiseMinutes = appState.practiseMinutes;
      _recallMinutes = appState.recallMinutes;

      _remindersEnabled = reminderSettings['enabled'] == 1;

      _reminderTime = TimeOfDay(
        hour: reminderSettings['hour'] as int,
        minute: reminderSettings['minute'] as int,
      );

      _isLoading = false;
    });
  }

  Future<void> _selectReminderTime() async {
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
      helpText: 'Choose your daily study reminder time',
    );

    if (selectedTime == null || !mounted) return;

    setState(() {
      _reminderTime = selectedTime;
    });
  }

  Future<void> _saveSettings() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final appState = context.read<AppState>();

      // Save learning targets and session durations.
      await appState.updateSettings(
        dailyGoal: _dailyGoal,
        weeklyGoal: _weeklyGoal,
        learn: _learnMinutes,
        practise: _practiseMinutes,
        recall: _recallMinutes,
        reminders: _remindersEnabled,
      );

      // Save reminder time and schedule or cancel notification.
      await NotificationService.instance.setDailyReminder(
        enabled: _remindersEnabled,
        hour: _reminderTime.hour,
        minute: _reminderTime.minute,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _remindersEnabled
                ? 'Settings saved. Daily reminder set for ${_reminderTime.format(context)}.'
                : 'Settings saved. Daily reminders are disabled.',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not save settings: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Widget _buildSlider({
    required String title,
    required String description,
    required int value,
    required int min,
    required int max,
    required int divisions,
    required ValueChanged<int> onChanged,
    required IconData icon,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 23),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '$value min',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Slider(
              value: value.toDouble(),
              min: min.toDouble(),
              max: max.toDouble(),
              divisions: divisions,
              label: '$value minutes',
              onChanged: (newValue) {
                onChanged(newValue.round());
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$min min',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  '$max min',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderSettings() {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.notifications_active_outlined, size: 23),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Daily Study Reminder',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Receive a notification every day to remind you to study.',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Enable daily reminder'),
              subtitle: Text(
                _remindersEnabled
                    ? 'Your daily reminder is enabled.'
                    : 'Your daily reminder is disabled.',
              ),
              value: _remindersEnabled,
              onChanged: (value) {
                setState(() {
                  _remindersEnabled = value;
                });
              },
            ),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.access_time),
              title: const Text('Reminder time'),
              subtitle: Text(_reminderTime.format(context)),
              trailing: const Icon(Icons.edit),
              enabled: _remindersEnabled,
              onTap: _remindersEnabled
                  ? _selectReminderTime
                  : null,
            ),
            if (_remindersEnabled)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'FocusTech will remind you every day at '
                  '${_reminderTime.format(context)}.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green.shade700,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionPlan() {
    final totalMinutes =
        _learnMinutes + _practiseMinutes + _recallMinutes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Focus Session Plan',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Customize how much time you spend in each learning phase.',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 14),
        _buildSlider(
          title: 'Learn',
          description: 'Read, watch lessons and understand concepts.',
          value: _learnMinutes,
          min: 5,
          max: 90,
          divisions: 17,
          icon: Icons.menu_book,
          onChanged: (value) {
            setState(() {
              _learnMinutes = value;
            });
          },
        ),
        _buildSlider(
          title: 'Practise',
          description: 'Write code and solve practical exercises.',
          value: _practiseMinutes,
          min: 5,
          max: 90,
          divisions: 17,
          icon: Icons.code,
          onChanged: (value) {
            setState(() {
              _practiseMinutes = value;
            });
          },
        ),
        _buildSlider(
          title: 'Recall',
          description: 'Test yourself and remember what you learned.',
          value: _recallMinutes,
          min: 5,
          max: 60,
          divisions: 11,
          icon: Icons.psychology,
          onChanged: (value) {
            setState(() {
              _recallMinutes = value;
            });
          },
        ),
        Card(
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.timer_outlined),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Total focus session',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '$totalMinutes minutes',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLearningTargets() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Learning Targets',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Set how much time you want to spend learning.',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 14),
        _buildSlider(
          title: 'Daily Learning Target',
          description: 'Your daily study goal.',
          value: _dailyGoal,
          min: 15,
          max: 360,
          divisions: 23,
          icon: Icons.today,
          onChanged: (value) {
            setState(() {
              _dailyGoal = value;
            });
          },
        ),
        _buildSlider(
          title: 'Weekly Learning Target',
          description: 'Your total study goal for the week.',
          value: _weeklyGoal,
          min: 60,
          max: 1200,
          divisions: 19,
          icon: Icons.calendar_month,
          onChanged: (value) {
            setState(() {
              _weeklyGoal = value;
            });
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text(
                    'Personalize FocusTech',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Configure your learning goals, focus sessions '
                    'and daily reminders.',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildLearningTargets(),

                  const SizedBox(height: 24),

                  _buildSessionPlan(),

                  const SizedBox(height: 24),

                  const Text(
                    'Notifications',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  _buildReminderSettings(),

                  const SizedBox(height: 20),

                  SizedBox(
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: _isSaving ? null : _saveSettings,
                      icon: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.save),
                      label: Text(
                        _isSaving ? 'Saving...' : 'Save Settings',
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}
