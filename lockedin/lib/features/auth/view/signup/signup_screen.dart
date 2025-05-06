import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:lockedin/features/auth/viewmodel/sign_up_viewmodel.dart';
import 'package:sizer/sizer.dart';
import 'signup_pages/name_page.dart';
import 'signup_pages/email_page.dart';
import 'signup_pages/password_page.dart';
import 'signup_pages/otp_page.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SignupViewModel(),
      child: const _SignupScreenContent(),
    );
  }
}

class _SignupScreenContent extends StatefulWidget {
  const _SignupScreenContent({Key? key}) : super(key: key);

  @override
  _SignupScreenContentState createState() => _SignupScreenContentState();
}

class _SignupScreenContentState extends State<_SignupScreenContent> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<SignupViewModel>(context);
    final theme = Theme.of(context);

    // Update the page controller when the viewModel's current page changes
    if (_pageController.hasClients &&
        _pageController.page?.round() != viewModel.currentPage) {
      _pageController.animateToPage(
        viewModel.currentPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading:
            viewModel.currentPage > 0
                ? IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black87),
                  onPressed: () => viewModel.previousPage(),
                )
                : null,
        title: Row(
          children: [
            Image.network(
              "https://upload.wikimedia.org/wikipedia/commons/c/ca/LinkedIn_logo_initials.png",
              height: 4.h, // Responsive height
            ),
            const SizedBox(width: 8),
            Text(
              'LockedIn',
              style: TextStyle(
                color: theme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Progress bar
          LinearProgressIndicator(
            value: viewModel.progressPercentage,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
            minHeight: 4,
          ),

          // Progress text
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  'Step ${viewModel.currentPage + 1} of 4',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Text(
                  '${(viewModel.progressPercentage * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Page content
          Expanded(
            child: PageView(
              physics: const NeverScrollableScrollPhysics(),
              controller: _pageController,
              onPageChanged: (index) {
                // Update viewModel if page changes by other means
                if (viewModel.currentPage != index) {
                  viewModel.setCurrentPage(index);
                }
              },
              children: const [
                NamePage(),
                EmailPage(),
                PasswordPage(),
                OtpPage(),
              ],
            ),
          ),

          // Error message
          if (viewModel.state == SignupState.error)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.red[50],
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      viewModel.errorMessage,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () => viewModel.resetError(),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
