import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lockedin/features/jobs/view/application_status.dart';

class ContactInfoPage extends StatefulWidget {
  final List<Map<String, dynamic>> screeningQuestions;
  final String userId;
  final String jobId; // Add jobId as a parameter

  const ContactInfoPage({
    Key? key,
    required this.screeningQuestions,
    required this.userId,
    required this.jobId, // Receive jobId from the previous page
  }) : super(key: key);

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

            // Dynamically generate screening questions
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
                  'userId': widget.userId,
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
