import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/features/company/model/company_post_model.dart';

final dashboardViewModelProvider = Provider<DashboardViewModel>((ref) {
  return DashboardViewModel();
});

class DashboardViewModel {
  List<PostModel> getPosts() {
    return [
      PostModel(
        title: "TCCD - Career Center",
        description: "Introducing one of Africa’s leading companies...",
        imageUrl: "assets/elsewedy_banner.png", // Placeholder for now
        likes: 39,
        comments: 3,
        reposts: 3,
        timeAgo: "20h",
      ),
      PostModel(
        title: "TCCD - Career Center",
        description: "We’re excited to sponsor...",
        imageUrl: "assets/elsewedy_banner.png", // Same placeholder
        likes: 32,
        comments: 3,
        reposts: 3,
        timeAgo: "3d",
      ),
    ];
  }
}
