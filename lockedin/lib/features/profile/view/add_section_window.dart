import 'package:flutter/material.dart';

class AddToProfilePage extends StatelessWidget {
  final List<String> coreItems = [
    "Add education",
    "Add position",
    "Add services",
    "Add career break",
    "Add skills",
  ];

  final List<String> recommendedItems = [
    "Example recommended item 1",
    "Example recommended item 2",
  ];

  final List<String> additionalItems = [
    "Example additional item 1",
    "Example additional item 2",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Add to profile', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        elevation: 0,
      ),
      body: ListView(
        children: [
          ExpansionTile(
            title: Text(
              'Core',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            collapsedIconColor: Colors.white,
            iconColor: Colors.white,
            childrenPadding: EdgeInsets.symmetric(horizontal: 16),
            children: [
              Text(
                'Start with the basics. Filling out these sections will help you be discovered by recruiters and people you may know',
                style: TextStyle(color: Colors.grey[400]),
              ),
              SizedBox(height: 12),
              ...coreItems.map(
                (item) => Column(
                  children: [
                    ListTile(
                      title: Text(item, style: TextStyle(color: Colors.white)),
                      onTap: () {}, // Navigation or action
                    ),
                    Divider(color: Colors.grey[800]),
                  ],
                ),
              ),
            ],
          ),
          ExpansionTile(
            title: Text(
              'Recommended',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            collapsedIconColor: Colors.white,
            iconColor: Colors.white,
            childrenPadding: EdgeInsets.symmetric(horizontal: 16),
            children:
                recommendedItems
                    .map(
                      (item) => ListTile(
                        title: Text(
                          item,
                          style: TextStyle(color: Colors.white),
                        ),
                        onTap: () {},
                      ),
                    )
                    .toList(),
          ),
          ExpansionTile(
            title: Text(
              'Additional',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            collapsedIconColor: Colors.white,
            iconColor: Colors.white,
            childrenPadding: EdgeInsets.symmetric(horizontal: 16),
            children:
                additionalItems
                    .map(
                      (item) => ListTile(
                        title: Text(
                          item,
                          style: TextStyle(color: Colors.white),
                        ),
                        onTap: () {},
                      ),
                    )
                    .toList(),
          ),
        ],
      ),
    );
  }
}
