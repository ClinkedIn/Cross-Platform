import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/presentation/pages/main_page.dart';
import 'package:lockedin/presentation/pages/sign_up_view.dart';
import 'package:lockedin/presentation/pages/verification_email_view.dart';

void main() {
  runApp(ProviderScope(child: MyApp())); // Enable Riverpod
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LinkedIn Clone',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: SignUpView(),
    );
  }
}
