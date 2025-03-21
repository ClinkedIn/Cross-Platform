import 'package:flutter/material.dart';
import 'package:lockedin/shared/theme/colors.dart';
import 'package:lockedin/shared/widgets/logo_appbar.dart';

class NewPasswordScreen extends StatefulWidget {
  @override
  _NewPasswordScreenState createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  bool _requireSignIn = true;

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context); // Fetch current theme

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: LogoAppbar(),

      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            SizedBox(height: 20),

            Text(
              'Choose a new password',
              style: theme.textTheme.headlineLarge,
            ),

            SizedBox(height: 10),

            Text(
              'To secure your account, choose a strong password you haven’t used before and is at least 8 characters long.',
              style: theme.textTheme.bodyMedium,
            ),

            SizedBox(height: 20),

            TextField(
              obscureText: !_passwordVisible,
              decoration: InputDecoration(
                labelText: "New password",
                suffixIcon: IconButton(
                  icon: Icon(
                    _passwordVisible ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _passwordVisible = !_passwordVisible;
                    });
                  },
                ),
              ),
            ),

            SizedBox(height: 15),

            TextField(
              obscureText: !_confirmPasswordVisible,
              decoration: InputDecoration(
                labelText: "Retype new password",
                suffixIcon: IconButton(
                  icon: Icon(
                    _confirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _confirmPasswordVisible = !_confirmPasswordVisible;
                    });
                  },
                ),
              ),
            ),

            SizedBox(height: 10),

            Row(
              children: [
                SizedBox(
                  width: 20,
                  child: Checkbox(
                    value: _requireSignIn,
                    fillColor: WidgetStateProperty.resolveWith<Color>((states) {
                      if (states.contains(WidgetState.selected)) {
                        return AppColors.primary; // Blue when checked
                      }
                      return AppColors.background; // Default background color
                    }),
                    checkColor: Colors.white, // Checkmark color
                    onChanged: (value) {
                      setState(() {
                        _requireSignIn = value!;
                      });
                    },
                  ),
                ),
                
                SizedBox(
                  width: 10,
                ),

                Text("Require all devices to sign in with new password",
                  style: theme.textTheme.bodySmall,),
              ],
            ),

            SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                child: Text(
                  'Submit',
                ),
              ),
            ),
            
          ],
        ),
      ),
    );
  }
}
