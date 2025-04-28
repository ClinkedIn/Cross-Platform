import 'package:flutter/material.dart';

class ActionCard extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback onTap;

  const ActionCard({
    super.key,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
        trailing: IconButton(icon: const Icon(Icons.add), onPressed: onTap),
      ),
    );
  }
}
