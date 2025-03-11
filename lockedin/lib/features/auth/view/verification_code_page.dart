import 'package:flutter/material.dart';
import 'package:lockedin/features/auth/view/forgot_password_page.dart';
import 'package:lockedin/features/auth/view/new_password_page.dart';

class VerificationCodeScreen extends StatelessWidget {
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
              'Enter the 6-digit code',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Check *****@gmail.com for a verification code.',
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
            SizedBox(
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ForgotPasswordScreen(),
                    ),
                  );
                },
                style: TextButton.styleFrom(backgroundColor: Colors.white),
                child: Text(
                  'Change',
                  style: TextStyle(
                    color: Color.fromARGB(255, 1, 95, 171),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            //SizedBox(height: 20),
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: '6-digit code',
              ),
            ),
            SizedBox(
              child: TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(backgroundColor: Colors.white),
                child: Text(
                  'Resend code',
                  style: TextStyle(
                    color: Color.fromARGB(255, 1, 95, 171),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NewPasswordScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 1, 95, 171),
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Text(
                  'Submit',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              "If you don't see the email in your inbox, check your spam folder. If it's not there, the email address may not be confirmed, or it may not match an existing LinkedIn account.",
              style: TextStyle(fontSize: 14, color: Colors.black),
            ),
            SizedBox(
              child: TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(backgroundColor: Colors.white),
                child: Text(
                  "Can't access this email?",
                  style: TextStyle(
                    color: Color.fromARGB(255, 1, 95, 171),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
