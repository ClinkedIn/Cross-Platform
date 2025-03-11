import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color linkedInBlue = Colors.black;

class LoginPage extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView( // Wrap with SingleChildScrollView
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.start, // Align to the start (left)
                children: [
                  Text(
                    "Locked ",
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: linkedInBlue, // Matching LinkedIn's blue color
                    ),
                  ),
                  Image.network(
                    "https://upload.wikimedia.org/wikipedia/commons/c/ca/LinkedIn_logo_initials.png",
                    height: 30,
                  ),
                  SizedBox(width: 8), // Spacing between logo and "Locked"
                ],
              ),
              SizedBox(height: 42),
              Text(
                "Sign in",
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              GestureDetector(
                onTap: () {},
                child: Row(
                  children: [
                    Text(
                      "or ", // "or" in grey
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: const Color.fromARGB(255, 75, 74, 74),
                      ),
                    ),
                    SizedBox(width: 4), // Add spacing between "or" and "Join lockedIn"
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        "Join lockedIn", // "Join lockedIn" in blue
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: linkedInBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 34),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: "Email or Phone",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(width: 4, color: linkedInBlue),
                  ),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(width: 4, color: Colors.grey),
                  ),
                ),
              ),
              SizedBox(height: 24),
              TextButton(
                onPressed: () {},
                child: Text(
                  "Forgot password?",
                  style: TextStyle(
                    color: linkedInBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: linkedInBlue,
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {},
                child: Text("Sign in"),
              ),
              SizedBox(height: 32),
              Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text("or"),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              SizedBox(height: 32),
              _socialLoginButton("Sign in with Apple", Icons.apple),
              SizedBox(height: 12),
              _socialLoginButton("Sign in with Google", Icons.g_mobiledata),
            ],
          ),
        ),
      ),
    );
  }

  Widget _socialLoginButton(String text, IconData icon) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        minimumSize: Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      onPressed: () {},
      icon: Icon(icon, size: 24),
      label: Text(text),
    );
  }
}