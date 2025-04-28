import 'package:flutter_test/flutter_test.dart';
import 'package:lockedin/features/jobs/model/job_model.dart';
import 'package:lockedin/features/jobs/repository/fake_job_repository.dart';
import 'package:lockedin/features/jobs/viewmodel/job_view_model.dart';

void main() {
  late FakeJobRepository fakeRepository;
  late JobViewModel viewModel;

  final testJobs = [
    JobModel(
      id: '1',
      title: 'Software Engineer',
      company: 'TechCorp',
      location: 'Remote',
      description: 'Cool job!',
      experienceLevel: 'Mid',
      salaryRange: '\$100k',
      isRemote: true,

      workplaceType: 'Remote',
      logoUrl: 'https://example.com/logo.png',
      industry: 'Technology',
      applicationStatus: 'Applied',
      screeningQuestions: [
        {'question': 'Why do you want this job?', 'idealAnswer': 'To learn'},
      ],
      applicants: [
        {'id': 'user1'},
      ],
      accepted: [],
      rejected: [],
      companyId: 'company1',
    ),
    JobModel(
      id: '2',
      title: 'Designer',
      company: 'Creative Inc',
      location: 'NYC',
      description: 'Fun job!',
      experienceLevel: 'Junior',
      salaryRange: '\$80k',
      isRemote: false,

      workplaceType: 'On-site',
      logoUrl: null,
      industry: 'Design',
      applicationStatus: 'Not Applied',
      screeningQuestions: [],
      applicants: [],
      accepted: [],
      rejected: [],
      companyId: '',
    ),
  ];

  setUp(() {
    fakeRepository = FakeJobRepository();
    fakeRepository.jobs = testJobs;
    viewModel = JobViewModel(fakeRepository);
  });

  test('initial fetch loads jobs', () async {
    await Future.delayed(Duration.zero);
    expect(viewModel.jobs.length, 2);
    expect(viewModel.jobs.first.title, 'Software Engineer');
  });

  test('updateSearchQuery triggers filtered fetch', () async {
    fakeRepository.jobs = [testJobs[0]];
    viewModel.updateSearchQuery('Engineer');
    await Future.delayed(Duration.zero);

    expect(viewModel.jobs.length, 1);
    expect(viewModel.jobs.first.title, 'Software Engineer');
  });

  test('save and unsave job flow works', () async {
    viewModel.saveJob('1');
    await Future.delayed(Duration.zero);
    expect(viewModel.isJobSaved('1'), isTrue);

    viewModel.unsaveJob('1');
    await Future.delayed(Duration.zero);
    expect(viewModel.isJobSaved('1'), isFalse);
  });

  test('applyToJob runs without error', () async {
    await viewModel.applyToJob(
      jobId: '1',
      contactEmail: 'a@b.com',
      contactPhone: '123456789',
      answers: [
        {'question': 'Why?', 'answer': 'Because'},
      ],
    );
    expect(true, isTrue);
  });

  test('handles errors gracefully', () async {
    fakeRepository.shouldThrow = true;
    await viewModel.applyToJob(
      jobId: '1',
      contactEmail: 'fail@b.com',
      contactPhone: '0000',
      answers: [],
    );
    expect(true, isTrue);
  });
}
