import 'package:flutter/material.dart';
import 'package:lockedin/presentation/pages/verification_code_page.dart';

class ForgotPasswordScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Text(
              'Forgot password',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                labelText: 'Email or Phone',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 15),
            Text(
              "We'll send a verification code to this email or phone number if it matches an existing LinkedIn account.",
              style: TextStyle(fontSize: 14,
              color: Colors.black),
            ),
            SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VerificationCodeScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  backgroundColor: const Color.fromARGB(255, 1, 95, 171),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Text(
                  'Next',
                  style: TextStyle(fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
