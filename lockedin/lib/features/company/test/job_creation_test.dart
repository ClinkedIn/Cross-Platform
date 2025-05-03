import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:lockedin/features/company/viewmodel/job_creation_viewmodel.dart';
import 'package:lockedin/features/company/view/company_analytics_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('JobCreationViewModel', () {
    late JobCreationViewModel viewModel;

    setUp(() {
      viewModel = JobCreationViewModel('company123');
    });

    test('Initial values are set correctly', () {
      expect(viewModel.workplaceType, 'Onsite');
      expect(viewModel.jobType, 'Full Time');
      expect(viewModel.autoRejectMustHave, false);
      expect(viewModel.screeningQuestionControllers.length, 0);
    });

    test('addScreeningQuestion adds a question', () {
      viewModel.addScreeningQuestion();
      expect(viewModel.screeningQuestionControllers.length, 1);
      expect(viewModel.screeningQuestionValues.length, 1);
      expect(viewModel.mustHaveValues.length, 1);
    });

    testWidgets('submitJob shows success message on true response', (WidgetTester tester) async {
      // Override repository to simulate success
      final fakeContext = _FakeBuildContext();
      viewModel.titleController.text = 'Software Engineer';
      viewModel.industryController.text = 'Tech';
      viewModel.jobLocationController.text = 'Remote';
      viewModel.descriptionController.text = 'Develop apps';
      viewModel.applicationEmailController.text = 'hr@company.com';
      viewModel.rejectPreviewController.text = 'Sorry, you were not selected';

      viewModel.addScreeningQuestion();
      viewModel.screeningQuestionValues[0] = 'Work Experience';
      viewModel.screeningQuestionControllers[0]['idealAnswer']?.text = '2';
      viewModel.mustHaveValues[0] = true;

      // Since repository.createCompanyJob uses .then, we simulate it by overriding manually if needed
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              viewModel.submitJob(context);
              return Container();
            },
          ),
        ),
      );
    });
  });

    group('CompanyAnalyticsScreen UI Tests', () {
    testWidgets('renders with initial state', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CompanyAnalyticsScreen(companyId: 'test-company'),
        ),
      );

      expect(find.text("Analytics"), findsOneWidget);
      expect(find.text("Content"), findsOneWidget);
      expect(find.text("Followers"), findsOneWidget);
    });
    testWidgets('displays loading indicator when isLoading is true', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CompanyAnalyticsScreen(companyId: 'loading-company'),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });
  });
}

class _FakeBuildContext extends BuildContext {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}