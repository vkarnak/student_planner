import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/suggestion_provider.dart';

class SuggestionScreen extends StatefulWidget {
  const SuggestionScreen({super.key});

  @override
  _SuggestionScreenState createState() => _SuggestionScreenState();
}

class _SuggestionScreenState extends State<SuggestionScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(
      () => Provider.of<SuggestionProvider>(
        context,
        listen: false,
      ).loadSuggestions(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SuggestionProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text("AI Suggestions")),

      body: provider.isLoading
          ? Center(child: CircularProgressIndicator())
          : provider.suggestions.isEmpty
          ? Center(child: Text("No suggestions yet"))
          : ListView.builder(
              itemCount: provider.suggestions.length,
              itemBuilder: (context, index) {
                final s = provider.suggestions[index];

                return ListTile(
                  leading: Icon(Icons.lightbulb, color: Colors.amber),

                  title: Text(s['title']),

                  subtitle: Text(s['description']),
                );
              },
            ),
    );
  }
}
