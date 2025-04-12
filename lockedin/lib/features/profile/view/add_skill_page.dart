import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/features/profile/model/skill_model.dart';
import 'package:lockedin/features/profile/viewmodel/add_skill_viewmodel.dart';
import 'package:lockedin/shared/theme/colors.dart';

class AddSkillPage extends ConsumerStatefulWidget {
  const AddSkillPage({Key? key}) : super(key: key);

  @override
  ConsumerState<AddSkillPage> createState() => _AddSkillPageState();
}

class _AddSkillPageState extends ConsumerState<AddSkillPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _skillNameController = TextEditingController();
  bool _isLoading = false;

  void _saveSkill(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final skill = Skill(name: _skillNameController.text);

      final success = await ref
          .read(addSkillViewModelProvider.notifier)
          .addSkill(skill, context);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Skill added successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add skill: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final skillState = ref.watch(addSkillViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text("Add Skill"),
        backgroundColor: theme.scaffoldBackgroundColor,
        iconTheme: IconThemeData(color: AppColors.primary),
        elevation: 0,
      ),
      body:
          _isLoading || skillState.isLoading
              ? Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
              : Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle("Skill Name *"),
                      _buildTextField(
                        _skillNameController,
                        "Ex: Python Programming",
                        true,
                      ),

                      const SizedBox(height: 16),
                      Text(
                        "Add skills that showcase your expertise and make you stand out to recruiters.",
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),

                      const Spacer(),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _saveSkill(context);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            "Save Skill",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildSectionTitle(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
    ),
  );

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    bool required, {
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator:
          required
              ? (val) =>
                  val == null || val.isEmpty ? 'Skill name is required' : null
              : null,
      maxLines: maxLines,
      textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
