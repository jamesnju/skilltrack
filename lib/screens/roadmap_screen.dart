import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';

class RoadmapScreen extends StatelessWidget {
  const RoadmapScreen({super.key});
  @override Widget build(BuildContext context) => Consumer<AppState>(builder: (context, state, _) {
    if (state.loading) return const Center(child: CircularProgressIndicator());
    return ListView(padding: const EdgeInsets.all(16), children: [for (final subject in ['SQL Server', 'C#', 'Oracle', 'Flexcube', 'WCF']) Card(child: ExpansionTile(title: Text(subject, style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Text('${state.topics.where((t) => t.subject == subject && t.completed).length}/${state.topics.where((t) => t.subject == subject).length} completed'), children: [for (final topic in state.topics.where((t) => t.subject == subject)) CheckboxListTile(value: topic.completed, title: Text(topic.title), subtitle: Text('Week ${topic.week}'), onChanged: (v) => state.toggleTopic(topic, v ?? false))]))]);
  });
}
