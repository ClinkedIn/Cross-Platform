import 'package:flutter/material.dart';

class ConnectionsPage extends StatelessWidget {
  const ConnectionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
        ),
        title: Text('Connections', style: TextStyle(fontSize: 24)),
        centerTitle: true,
        iconTheme: theme.iconTheme,
      ),
    );
  }
}
