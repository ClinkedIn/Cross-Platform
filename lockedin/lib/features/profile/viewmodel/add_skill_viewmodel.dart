import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/features/profile/model/skill_model.dart';
import 'package:lockedin/features/profile/service/skill_service.dart';

final addSkillViewModelProvider =
    StateNotifierProvider<AddSkillViewModel, AsyncValue<void>>((ref) {
      return AddSkillViewModel(ref);
    });

class AddSkillViewModel extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  AddSkillViewModel(this.ref) : super(const AsyncValue.data(null));

  Future<bool> addSkill(Skill skill, BuildContext context) async {
    state = const AsyncValue.loading();
    try {
      final response = await SkillService.addSkill(skill);

      if (response.statusCode == 200 || response.statusCode == 201) {
        state = const AsyncValue.data(null);
        return true;
      } else {
        throw Exception('Failed to add skill: ${response.body}');
      }
    } catch (e, stack) {
      print("Error in addSkill: $e");
      state = AsyncValue.error(e, stack);
      return false;
    }
  }
}
