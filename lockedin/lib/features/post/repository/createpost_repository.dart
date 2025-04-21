// import '../model/createpost_model.dart';


// abstract class CreatePostRepository {
//   Future<void> createPost(String content, String imagePath, String videoPath);
// }

import 'package:lockedin/features/post/repository/createpost_APi.dart';
import 'package:mockito/mockito.dart';

class MockCreatePostApi extends Mock implements CreatepostApi {}