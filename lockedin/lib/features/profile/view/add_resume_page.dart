import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/features/profile/viewmodel/add_resume_viewmodel.dart';
import 'package:lockedin/shared/theme/colors.dart';
import 'package:path/path.dart' as path;

class AddResumePage extends ConsumerStatefulWidget {
  const AddResumePage({Key? key}) : super(key: key);

  @override
  ConsumerState<AddResumePage> createState() => _AddResumePageState();
}

class _AddResumePageState extends ConsumerState<AddResumePage> {
  @override
  void initState() {
    super.initState();
    // Reset the state when the page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(addResumeViewModelProvider.notifier).resetState();
    });
  }

  @override
  Widget build(BuildContext context) {
    final resumeState = ref.watch(addResumeViewModelProvider);
    final viewModel = ref.read(addResumeViewModelProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Resume',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Upload your resume', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Add your resume to help potential employers learn more about your skills and experience.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),

            // File selection area
            _buildFileSelection(context, resumeState, viewModel, theme),

            const SizedBox(height: 16),

            if (resumeState.errorMessage != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        resumeState.errorMessage!,
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),

            if (resumeState.uploadSuccess)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Resume uploaded successfully!',
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                  ],
                ),
              ),

            const Spacer(),

            // Upload button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    resumeState.isLoading || resumeState.selectedFile == null
                        ? null
                        : () async {
                          final success = await viewModel.uploadResume();
                          if (success && context.mounted) {
                            // Show success message then navigate back after a delay
                            Future.delayed(Duration(seconds: 2), () {
                              if (context.mounted) {
                                Navigator.pop(context);
                              }
                            });
                          }
                        },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  disabledBackgroundColor: Colors.grey,
                ),
                child:
                    resumeState.isLoading
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : const Text(
                          'Upload Resume',
                          style: TextStyle(
                            color: Colors.white,
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

  Widget _buildFileSelection(
    BuildContext context,
    ResumeState resumeState,
    AddResumeViewModel viewModel,
    ThemeData theme,
  ) {
    return GestureDetector(
      onTap: () => viewModel.pickResumeFile(),
      child: Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          border: Border.all(color: theme.dividerColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child:
            resumeState.selectedFile == null
                ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.upload_file,
                      size: 48,
                      color: theme.iconTheme.color,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Click to select a PDF file',
                      style: theme.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 8),
                    Text('Maximum size: 5MB', style: theme.textTheme.bodySmall),
                  ],
                )
                : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.picture_as_pdf, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      path.basename(resumeState.selectedFile!.path),
                      style: theme.textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => viewModel.pickResumeFile(),
                      child: Text('Select a different file'),
                    ),
                  ],
                ),
      ),
    );
  }
}
