import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:lockedin/features/post/repository/mock_create_post_api.dart';
import 'package:lockedin/features/post/viewmodel/post_viewmodel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late PostViewModel viewModel;
  late MockCreatePostApi mockApi;

  setUp(() {
    mockApi = MockCreatePostApi();
    viewModel = PostViewModel();
  });

  test('initial state is correct', () {
    expect(viewModel.state.content, '');
    expect(viewModel.state.isSubmitting, false);
    expect(viewModel.state.attachments, isNull);
    expect(viewModel.state.visibility, 'Anyone');
  });

  test('updates content correctly', () {
    viewModel.updateContent('Test post');
    expect(viewModel.state.content, 'Test post');
  });

  test('updates visibility correctly', () {
    viewModel.updateVisibility('Connections');
    expect(viewModel.state.visibility, 'Connections');
  });

  test('removes image', () {
    viewModel.removeImage();
    expect(viewModel.state.attachments, null);
  });

  // test('submits post successfully', () async {
  //   final file = File('dummy/path/image.jpg');
  //   viewModel.state = viewModel.state.copyWith(attachments: [file]);

  //   // Mock successful response
  //   final result = await viewModel.submitPost(
  //     content: 'Hello world',
  //     attachments: [file],
  //   );

  //   expect(result, isTrue);
  //   expect(viewModel.state.isSubmitting, isFalse);
  //   expect(viewModel.state.error, isNull);
  // });

  // test('submitPost handles failure', () async {
  //   final file = File('dummy/path/image.jpg');

  //   // Force an exception inside submitPost
  //   final result = await viewModel.submitPost(
  //     content: 'Bad request',
  //     attachments: [file],
  //   );

  //   expect(result, false);
  //   expect(viewModel.state.isSubmitting, false);
  //   expect(viewModel.state.error, isNotNull);
  // });
}
