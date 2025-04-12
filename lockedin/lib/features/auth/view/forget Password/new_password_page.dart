// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:lockedin/features/auth/viewmodel/new_password_viewmodel.dart';
// import 'package:lockedin/shared/theme/colors.dart';
// import 'package:lockedin/shared/widgets/logo_appbar.dart';
// import 'package:sizer/sizer.dart';

// class NewPasswordScreen extends ConsumerStatefulWidget {
//   @override
//   _NewPasswordScreenState createState() => _NewPasswordScreenState();
// }

// class _NewPasswordScreenState extends ConsumerState<NewPasswordScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _passwordController = TextEditingController();
//   final TextEditingController _confirmPasswordController = TextEditingController();
//   bool _passwordVisible = false;
//   bool _confirmPasswordVisible = false;
//   bool _requireSignIn = true;

//   @override
//   void dispose() {
//     _passwordController.dispose();
//     _confirmPasswordController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     // final newPasswordViewModel = ref.read(newPasswordProvider.notifier);
//     // final newPasswordState = ref.watch(newPasswordProvider);

//     return Scaffold(
//       backgroundColor: theme.scaffoldBackgroundColor,
//       appBar: LogoAppbar(),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 SizedBox(height: 3.h),
        
//                 Text(
//                   'Choose a new password',
//                   style: theme.textTheme.headlineLarge?.copyWith(fontSize: 3.h),
//                 ),
        
//                 SizedBox(height: 1.5.h),
        
//                 Text(
//                   'To secure your account, choose a strong password you haven’t used before and is at least 8 characters long.',
//                   style: theme.textTheme.bodyMedium?.copyWith(fontSize: 1.8.h),
//                 ),
        
//                 SizedBox(height: 3.h),
        
//                 TextFormField(
//                   controller: _passwordController,
//                   obscureText: !_passwordVisible,
//                   decoration: InputDecoration(
//                     labelText: 'New Password',
//                     suffixIcon: IconButton(
//                       icon: Icon(_passwordVisible ? Icons.visibility : Icons.visibility_off),
//                       onPressed: () {
//                         setState(() {
//                           _passwordVisible = !_passwordVisible;
//                         });
//                       },
//                     ),
//                     labelStyle: theme.textTheme.bodyLarge?.copyWith(fontSize: 2.h),
//                   ),
//                   validator: (value) => newPasswordViewModel.validatePassword(value),
//                 ),
        
//                 SizedBox(height: 2.h),
        
//                 TextFormField(
//                   controller: _confirmPasswordController,
//                   obscureText: !_confirmPasswordVisible,
//                   decoration: InputDecoration(
//                     labelText: 'Retype Password',
//                     suffixIcon: IconButton(
//                       icon: Icon(_confirmPasswordVisible ? Icons.visibility : Icons.visibility_off),
//                       onPressed: () {
//                         setState(() {
//                           _confirmPasswordVisible = !_confirmPasswordVisible;
//                         });
//                       },
//                     ),
//                   ),
//                   validator: (value) => newPasswordViewModel.validateConfirmPassword(
//                     _passwordController.text,
//                     value,
//                   ),
//                 ),
        
//                 SizedBox(height: 2.h),
        
//                 Row(
//                   children: [
//                     SizedBox(
//                       width: 6.w,
//                       child: Checkbox(
//                         value: _requireSignIn,
//                         fillColor: WidgetStateProperty.resolveWith<Color>((states) {
//                           if (states.contains(WidgetState.selected)) {
//                             return AppColors.primary;
//                           }
//                           return AppColors.background;
//                         }),
//                         checkColor: Colors.white,
//                         onChanged: (value) {
//                           setState(() {
//                             _requireSignIn = value!;
//                           });
//                         },
//                       ),
//                     ),
        
//                     SizedBox(width: 2.w),
        
//                     Expanded(
//                       child: Text(
//                         "Require all devices to sign in with new password",
//                         style: theme.textTheme.bodySmall?.copyWith(fontSize: 1.8.h),
//                       ),
//                     ),
//                   ],
//                 ),
        
//                 SizedBox(height: 3.h),
        
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: newPasswordState.isLoading
//                         ? null
//                         : () async {
//                             print("Submit button pressed");
        
//                             if (_formKey.currentState!.validate()) {
//                               print("Validation passed. Calling resetPassword...");
        
//                               await newPasswordViewModel.resetPassword(
//                                 _passwordController.text,
//                                 _requireSignIn,
//                               );
        
//                               ref.invalidate(newPasswordProvider);
        
//                               final updatedState = ref.watch(newPasswordProvider);
        
//                               if (!updatedState.hasError) {
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   SnackBar(
//                                     content: Text('Password reset successful'),
//                                     backgroundColor: Colors.green,
//                                   ),
//                                 );
        
//                                 // TODO: Navigate to login screen
//                               } else {
//                                 print("Error: ${updatedState.error}");
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   SnackBar(
//                                     content: Text('Error: ${updatedState.error}'),
//                                     backgroundColor: Colors.red,
//                                   ),
//                                 );
//                               }
//                             }
//                           },
//                     child: newPasswordState.isLoading
//                         ? CircularProgressIndicator()
//                         : Text('Submit'),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
