// import 'dart:convert'; // For JSON encoding/decoding
// import 'package:http/http.dart' as http;
// import '../model/user_model.dart';

// class UpdateUserProfileService {
//   static Future<void> updateUserProfile(UpdateUserModel user) async {
//     final url = Uri.parse("");

//     final headers = {
//       "Content-Type": "application/json",
//       "Accept": "application/json", // Add token if required
//     };

//     final body = jsonEncode(user.toJson());

//     try {
//       final response = await http.put(url, headers: headers, body: body);

//       if (response.statusCode == 200) {
//         print("Profile updated successfully: ${response.body}");
//       } else {
//         print(
//           "Failed to update profile. Status code: ${response.statusCode}, Error: ${response.body}",
//         );
//       }
//     } catch (error) {
//       print("Error updating profile: $error");
//     }
//   }
// }
