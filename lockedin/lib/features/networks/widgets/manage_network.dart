import 'package:flutter/material.dart';
import 'package:lockedin/features/networks/view/manage_page.dart';

class ManageNetwork extends StatelessWidget {
  const ManageNetwork({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      color: theme.cardColor,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            child: 
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Manage my network", style: theme.textTheme.bodyLarge),
                  Icon(Icons.arrow_forward, color: theme.iconTheme.color),
                ],
              ),

              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ManagePage(),
                  ),
                );
              },
          ),
        ],
      ),
    );
  }
}
