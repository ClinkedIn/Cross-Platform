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

  test('updates visibility correctly', () {
    viewModel.updateVisibility('Connections');
    expect(viewModel.state.visibility, 'Connections');
  });

  test('removes image', () {
    viewModel.removeImage();
    expect(viewModel.state.attachments, null);
  });
}
