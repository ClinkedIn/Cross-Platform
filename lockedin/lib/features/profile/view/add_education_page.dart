import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lockedin/features/profile/model/education_model.dart';
import 'package:lockedin/features/profile/viewmodel/add_education_viewmodel.dart';
import 'package:lockedin/shared/theme/colors.dart';
import 'package:intl/intl.dart';

class AddEducationPage extends ConsumerStatefulWidget {
  @override
  ConsumerState<AddEducationPage> createState() => _AddEducationPageState();
}

class _AddEducationPageState extends ConsumerState<AddEducationPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _schoolController = TextEditingController();
  final TextEditingController _degreeController = TextEditingController();
  final TextEditingController _fieldController = TextEditingController();
  final TextEditingController _gradeController = TextEditingController();
  final TextEditingController _activitiesController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;

  List<String> _skills = [];
  List<File> _mediaFiles = [];

  Future<void> _pickDate(BuildContext context, bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime(2050),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        isStart ? _startDate = picked : _endDate = picked;
      });
    }
  }

  Future<void> _addSkill() async {
    final skillController = TextEditingController();
    await showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text("Add Skill"),
            content: TextField(
              controller: skillController,
              decoration: InputDecoration(
                hintText: "Enter a skill",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Cancel", style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                onPressed: () {
                  if (skillController.text.isNotEmpty) {
                    setState(() {
                      _skills.add(skillController.text);
                    });
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text("Add"),
              ),
            ],
          ),
    );
  }

  Future<void> _pickMedia() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() {
        _mediaFiles.add(File(picked.path));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final educationState = ref.watch(addEducationViewModelProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Add Education",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        iconTheme: IconThemeData(color: AppColors.primary),
      ),
      body:
          _isLoading || educationState.isLoading
              ? Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
              : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      const SizedBox(height: 20),
                      // School field
                      _buildSectionTitle("School *"),
                      _buildTextField(
                        controller: _schoolController,
                        hint: "Ex: Stanford University",
                        validator:
                            (value) =>
                                value!.isEmpty ? 'School is required' : null,
                        textCapitalization: TextCapitalization.words,
                      ),

                      const SizedBox(height: 20),
                      // Degree field
                      _buildSectionTitle("Degree"),
                      _buildTextField(
                        controller: _degreeController,
                        hint: "Ex: Bachelor's, Master's",
                        textCapitalization: TextCapitalization.words,
                      ),

                      const SizedBox(height: 20),
                      // Field of study
                      _buildSectionTitle("Field of Study"),
                      _buildTextField(
                        controller: _fieldController,
                        hint: "Ex: Computer Science",
                        textCapitalization: TextCapitalization.words,
                      ),

                      const SizedBox(height: 20),
                      // Dates
                      _buildSectionTitle("Time Period"),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDateSelector(
                              label: "Start Date",
                              date: _startDate,
                              onTap: () => _pickDate(context, true),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDateSelector(
                              label: "End Date",
                              date: _endDate,
                              onTap: () => _pickDate(context, false),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                      // Grade
                      _buildSectionTitle("Grade"),
                      _buildTextField(
                        controller: _gradeController,
                        hint: "Ex: 3.8 GPA",
                      ),

                      const SizedBox(height: 20),
                      // Activities
                      _buildSectionTitle("Activities & Societies"),
                      _buildTextField(
                        controller: _activitiesController,
                        hint: "Ex: Coding Club, Debate Team",
                        maxLines: 2,
                        textCapitalization: TextCapitalization.sentences,
                      ),

                      const SizedBox(height: 20),
                      // Description
                      _buildSectionTitle("Description"),
                      _buildTextField(
                        controller: _descriptionController,
                        hint: "Describe your experience, achievements, etc.",
                        maxLines: 4,
                        textCapitalization: TextCapitalization.sentences,
                      ),

                      const SizedBox(height: 24),
                      // Skills section
                      _buildSectionTitle("Skills"),
                      const SizedBox(height: 8),
                      if (_skills.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            "Add skills related to this education",
                            style: TextStyle(
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            _skills
                                .map(
                                  (skill) => Chip(
                                    label: Text(skill),
                                    backgroundColor: AppColors.gray,
                                    labelStyle: TextStyle(
                                      color: Colors.black87,
                                    ),
                                    deleteIconColor: Colors.black54,
                                    onDeleted:
                                        () => setState(
                                          () => _skills.remove(skill),
                                        ),
                                  ),
                                )
                                .toList(),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: _addSkill,
                        icon: Icon(Icons.add, size: 18),
                        label: Text("Add Skill"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),

                      const SizedBox(height: 24),
                      // Media section
                      _buildSectionTitle("Media"),
                      const SizedBox(height: 8),
                      if (_mediaFiles.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            "Add photos, certificates, or other documents",
                            style: TextStyle(
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      if (_mediaFiles.isNotEmpty)
                        Container(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _mediaFiles.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        _mediaFiles[index],
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      top: 4,
                                      right: 4,
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _mediaFiles.removeAt(index);
                                          });
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withOpacity(
                                              0.7,
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.close,
                                            color: Colors.white,
                                            size: 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: _pickMedia,
                        icon: Icon(Icons.attach_file, size: 18),
                        label: Text("Add Media"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),

                      const SizedBox(height: 32),
                      // Save button
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _saveEducation(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Save Education',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    String? Function(String?)? validator,
    int maxLines = 1,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      textCapitalization: textCapitalization,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey),
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

  Widget _buildDateSelector({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    final dateStr =
        date != null ? DateFormat('MMM d, yyyy').format(date) : 'Select date';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey.shade50,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                dateStr,
                style: TextStyle(
                  color: date != null ? Colors.black87 : Colors.grey,
                ),
              ),
            ),
            Icon(Icons.calendar_today, size: 18, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  void _saveEducation(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final startDateStr =
          _startDate != null
              ? "${_startDate!.year}-${_startDate!.month.toString().padLeft(2, '0')}-${_startDate!.day.toString().padLeft(2, '0')}"
              : null;

      final endDateStr =
          _endDate != null
              ? "${_endDate!.year}-${_endDate!.month.toString().padLeft(2, '0')}-${_endDate!.day.toString().padLeft(2, '0')}"
              : null;

      final education = Education(
        school: _schoolController.text,
        degree:
            _degreeController.text.isNotEmpty ? _degreeController.text : null,
        fieldOfStudy:
            _fieldController.text.isNotEmpty ? _fieldController.text : null,
        startDate: startDateStr,
        endDate: endDateStr,
        grade: _gradeController.text.isNotEmpty ? _gradeController.text : null,
        activities:
            _activitiesController.text.isNotEmpty
                ? _activitiesController.text
                : null,
        description:
            _descriptionController.text.isNotEmpty
                ? _descriptionController.text
                : null,
        skills: _skills.isNotEmpty ? _skills : null,
        media: null,
      );

      final success = await ref
          .read(addEducationViewModelProvider.notifier)
          .addEducation(education, _mediaFiles, context);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Education added successfully'),
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
            content: Text('Failed to add education: $e'),
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
}
