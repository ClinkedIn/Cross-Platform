// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:lockedin/features/auth/repository/email_verification_repository.dart';
// import 'package:lockedin/features/auth/view/edit_email_view.dart';
// import 'package:lockedin/features/auth/view/main_page.dart';
// import 'package:lockedin/features/auth/viewmodel/sign_up_viewmodel.dart';
// import 'package:lockedin/features/auth/viewmodel/verification_email_viewmodel.dart';
// import 'package:lockedin/shared/theme/colors.dart';
// import 'package:lockedin/shared/theme/styled_buttons.dart';
// import 'package:lockedin/shared/theme/text_styles.dart';

// final verificationEmailViewModelProvider = ChangeNotifierProvider(
//   (ref) => VerificationEmailViewModel(EmailVerificationRepository()),
// );

// class VerificationEmailView extends ConsumerStatefulWidget {
//   final String email;
//   const VerificationEmailView({super.key, required this.email});

//   @override
//   _VerificationEmailViewState createState() => _VerificationEmailViewState();
// }

// class _VerificationEmailViewState extends ConsumerState<VerificationEmailView> {
//   final TextEditingController codeController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     Future.microtask(
//       () =>
//           ref.read(verificationEmailViewModelProvider).fetchVerificationCode(),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final viewModel = ref.watch(verificationEmailViewModelProvider);
//     final signupState = ref.watch(signupProvider);
//     return Scaffold(
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(20.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Header Section
//               Row(
//                 children: [
//                   Text(
//                     "Locked ",
//                     style: AppTextStyles.headline1.copyWith(
//                       color: AppColors.primary,
//                     ),
//                   ),
//                   Image.network(
//                     "https://upload.wikimedia.org/wikipedia/commons/c/ca/LinkedIn_logo_initials.png",
//                     height: 30,
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 28),
//               Text(
//                 "Enter the verification code",
//                 style: Theme.of(context).textTheme.headlineLarge,
//               ),
//               const SizedBox(height: 12),

//               RichText(
//                 text: TextSpan(
//                   style: Theme.of(context).textTheme.bodyLarge,
//                   children: [
//                     TextSpan(
//                       text:
//                           "We sent the verification code to ${signupState.email} ",
//                       style: Theme.of(context).textTheme.titleMedium,
//                     ),
//                     WidgetSpan(
//                       child: GestureDetector(
//                         onTap: () async {
//                           final updatedEmail = await Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => EditEmailView(),
//                             ),
//                           );

//                           if (updatedEmail != null) {
//                             ref
//                                 .read(signupProvider.notifier)
//                                 .setEmail(updatedEmail);
//                           }
//                         },
//                         child: Text(
//                           "Edit email",
//                           style: AppTextStyles.buttonText.copyWith(
//                             color: AppColors.primary,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 28),

//               // Debugging Code Display (Remove in production)
//               Text(
//                 "Received Code: ${viewModel.receivedCode}",
//                 style: Theme.of(context).textTheme.bodySmall,
//               ),
//               const SizedBox(height: 12),

//               // Verification Code Input
//               TextField(
//                 controller: codeController,
//                 keyboardType: TextInputType.number,
//                 maxLength: 15,
//                 style: Theme.of(context).textTheme.bodyLarge,

//                 decoration: InputDecoration(
//                   labelText: "code*",
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),

//                 onChanged:
//                     (value) => ref
//                         .read(verificationEmailViewModelProvider)
//                         .updateCode(value),
//               ),

//               const Spacer(),

//               // Buttons (Next & Resend)
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton(
//                       onPressed:
//                           viewModel.isCodeValid
//                               ? () {
//                                 viewModel.verifyCode(context);
//                                 Navigator.pushReplacement(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (context) => MainPage(),
//                                   ),
//                                 );
//                               }
//                               : null,
//                       style: AppButtonStyles.elevatedButton,
//                       child: const Text("Next"),
//                     ),
//                   ),

//                   const SizedBox(height: 10),

//                   TextButton(
//                     onPressed:
//                         viewModel.isResendDisabled
//                             ? null
//                             : () => viewModel.resendCode(),
//                     child: Text(
//                       viewModel.isResendDisabled ? "Wait..." : "Resend code",
//                       style: TextStyle(color: AppColors.primary),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
