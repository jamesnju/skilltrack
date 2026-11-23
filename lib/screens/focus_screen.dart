import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../services/notification_service.dart';

class FocusScreen extends StatefulWidget { const FocusScreen({super.key}); @override State<FocusScreen> createState() => _FocusScreenState(); }
class _FocusScreenState extends State<FocusScreen> {
  final subjects = const ['SQL Server', 'C#', 'Oracle', 'Flexcube', 'WCF'];
  String subject = 'SQL Server';
  final phases = const [('Learn', 25), ('Practise', 25), ('Recall', 10)];
  int phase = 0, seconds = 25 * 60, elapsed = 0;
  Timer? timer;
  bool running = false;
  @override void dispose() { timer?.cancel(); super.dispose(); }
  String get clock => '${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';
  void start() { if (running) return; setState(() => running = true); timer = Timer.periodic(const Duration(seconds: 1), (_) async { if (seconds > 1) { setState(() { seconds--; elapsed++; }); } else { timer?.cancel(); setState(() { seconds = 0; running = false; }); await NotificationService.instance.showSessionComplete(); if (mounted) _phaseComplete(); } }); }
  void pause() { timer?.cancel(); setState(() => running = false); }
  void reset() { timer?.cancel(); setState(() { running = false; seconds = phases[phase].$2 * 60; }); }
  Future<void> _phaseComplete() async {
    if (phase < 2) {
      final finished = phases[phase].$1;
      setState(() { phase++; seconds = phases[phase].$2 * 60; });
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$finished complete. Next: ${phases[phase].$1}.')));
    } else {
      await context.read<AppState>().addSession(subject, 60);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('One-hour study session saved!')));
      setState(() { phase = 0; seconds = 25 * 60; });
    }
  }
  @override Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(20), children: [Text('Protect your attention. One subject at a time.', style: Theme.of(context).textTheme.titleMedium), const SizedBox(height: 18), DropdownButtonFormField<String>(value: subject, decoration: const InputDecoration(labelText: 'Active subject', border: OutlineInputBorder()), items: subjects.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(), onChanged: running ? null : (v) => setState(() => subject = v ?? subject)), const SizedBox(height: 26), Center(child: Text(phases[phase].$1.toUpperCase(), style: const TextStyle(letterSpacing: 2, color: Colors.grey))), const SizedBox(height: 10), Center(child: Text(clock, style: Theme.of(context).textTheme.displayLarge?.copyWith(fontWeight: FontWeight.w300, fontFeatures: const []))), const SizedBox(height: 12), Center(child: Text('Phase ${phase + 1} of 3  •  $subject')), const SizedBox(height: 24), Row(children: [Expanded(child: FilledButton.icon(onPressed: running ? pause : start, icon: Icon(running ? Icons.pause : Icons.play_arrow), label: Text(running ? 'Pause' : 'Start'))), const SizedBox(width: 10), OutlinedButton(onPressed: reset, child: const Text('Reset'))]), const SizedBox(height: 28), const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('Focus rule: if another subject comes to mind, write it down for later. Do not switch tasks during this session.'))), const SizedBox(height: 12), const Text('Session plan', style: TextStyle(fontWeight: FontWeight.bold)), for (var i = 0; i < phases.length; i++) ListTile(leading: Icon(i < phase ? Icons.check_circle : i == phase ? Icons.radio_button_checked : Icons.radio_button_unchecked), title: Text(phases[i].$1), trailing: Text('${phases[i].$2} min'))]);
}
