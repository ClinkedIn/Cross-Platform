import 'package:flutter/material.dart';

class ContactInfoPage extends StatefulWidget {
  final List<Map<String, dynamic>> screeningQuestions;
  const ContactInfoPage({Key? key, required this.screeningQuestions})
    : super(key: key);

  @override
  State<ContactInfoPage> createState() => _ContactInfoPageState();
}

class _ContactInfoPageState extends State<ContactInfoPage> {
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final Map<String, String> _answers = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Contact Information')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: 'Phone Number'),
            ),
            SizedBox(height: 24),

            // Dynamically build screening question fields
            ...widget.screeningQuestions.map((question) {
              final questionText = question['question'] ?? 'Unnamed Question';
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    questionText,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        _answers[questionText] = value;
                      });
                    },
                    decoration: InputDecoration(hintText: 'Your answer...'),
                  ),
                  SizedBox(height: 16),
                ],
              );
            }),

            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, {
                  'email': _emailController.text,
                  'phone': _phoneController.text,
                  'answers':
                      _answers.entries
                          .map((e) => {"question": e.key, "answer": e.value})
                          .toList(),
                });
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
