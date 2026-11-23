import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';

class RevisionScreen extends StatefulWidget { const RevisionScreen({super.key}); @override State<RevisionScreen> createState() => _RevisionScreenState(); }
class _RevisionScreenState extends State<RevisionScreen> {
  String subject = 'SQL Server';
  final question = TextEditingController(), answer = TextEditingController();
  int index = 0; bool reveal = false;
  @override void dispose() { question.dispose(); answer.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) => Consumer<AppState>(builder: (context, state, _) {
    final cards = state.flashcards.where((c) => c['subject'] == subject).toList();
    if (index >= cards.length) index = 0;
    return ListView(padding: const EdgeInsets.all(16), children: [DropdownButtonFormField<String>(value: subject, decoration: const InputDecoration(labelText: 'Subject'), items: ['SQL Server', 'C#', 'Oracle', 'Flexcube', 'WCF'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(), onChanged: (v) => setState(() { subject = v ?? subject; index = 0; reveal = false; })), const SizedBox(height: 14), Card(child: Padding(padding: const EdgeInsets.all(18), child: Column(children: [Text('FLASHCARDS  •  ${cards.isEmpty ? 0 : index + 1}/${cards.length}', style: const TextStyle(color: Colors.grey, letterSpacing: 1)), const SizedBox(height: 18), Text(cards.isEmpty ? 'No cards yet. Create your first question below.' : cards[index]['question'] as String, style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center), if (reveal && cards.isNotEmpty) ...[const Divider(height: 28), Text(cards[index]['answer'] as String, textAlign: TextAlign.center)], const SizedBox(height: 14), if (cards.isNotEmpty) Wrap(alignment: WrapAlignment.center, spacing: 8, children: [OutlinedButton(onPressed: () => setState(() => reveal = !reveal), child: Text(reveal ? 'Hide answer' : 'Reveal answer')), FilledButton(onPressed: () => setState(() { index = (index + 1) % cards.length; reveal = false; }), child: const Text('Next card'))])]))), const SizedBox(height: 16), Text('Create a flashcard', style: Theme.of(context).textTheme.titleMedium), const SizedBox(height: 8), TextField(controller: question, decoration: const InputDecoration(labelText: 'Question', border: OutlineInputBorder())), const SizedBox(height: 8), TextField(controller: answer, maxLines: 3, decoration: const InputDecoration(labelText: 'Answer', border: OutlineInputBorder())), const SizedBox(height: 8), FilledButton(onPressed: () async { if (question.text.trim().isEmpty || answer.text.trim().isEmpty) return; await state.addFlashcard(subject, question.text.trim(), answer.text.trim()); question.clear(); answer.clear(); setState(() { index = 0; reveal = false; }); }, child: const Text('Save flashcard'))]);
  });
}
