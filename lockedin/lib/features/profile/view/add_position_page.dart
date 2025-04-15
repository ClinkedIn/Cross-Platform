import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:lockedin/shared/theme/colors.dart';
import 'package:lockedin/features/profile/model/position_model.dart';
import 'package:lockedin/features/profile/viewmodel/add_position_viewmodel.dart';

class AddPositionPage extends ConsumerStatefulWidget {
  @override
  ConsumerState<AddPositionPage> createState() => _AddPositionPageState();
}

class _AddPositionPageState extends ConsumerState<AddPositionPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  String? _employmentType;
  String? _locationType;
  String? _jobSource;
  bool _currentlyWorking = false;
  DateTime? _startDate;
  DateTime? _endDate;

  List<String> _skills = [];
  List<File> _mediaFiles = [];
  bool _isLoading = false;

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        isStart ? _startDate = picked : _endDate = picked;
      });
    }
  }

  Future<void> _addSkill() async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text("Add Skill"),
            content: TextField(
              controller: controller,
              decoration: InputDecoration(hintText: "Enter a skill"),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  if (controller.text.isNotEmpty && _skills.length < 5) {
                    setState(() => _skills.add(controller.text));
                    Navigator.pop(context);
                  }
                },
                child: Text("Add"),
              ),
            ],
          ),
    );
  }

  Future<void> _pickMedia() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _mediaFiles.add(File(picked.path)));
    }
  }

  void _savePosition(BuildContext context) async {
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

      final position = Position(
        jobTitle: _titleController.text,
        companyName: _companyController.text,
        employmentType: _employmentType,
        currentlyWorking: _currentlyWorking,
        fromDate: startDateStr,
        toDate: _currentlyWorking ? null : endDateStr,
        location:
            _locationController.text.isNotEmpty
                ? _locationController.text
                : null,
        locationType: _locationType,
        description:
            _descriptionController.text.isNotEmpty
                ? _descriptionController.text
                : null,
        foundVia: _jobSource,
        skills: _skills.isNotEmpty ? _skills : [],
        media: null, // Will be set by the ViewModel after file upload
      );

      final success = await ref
          .read(addPositionViewModelProvider.notifier)
          .addPosition(position, _mediaFiles, context);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Position added successfully'),
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
            content: Text('Failed to add position: $e'),
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
    final positionState = ref.watch(addPositionViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text("Add Position"),
        backgroundColor: theme.scaffoldBackgroundColor,
        iconTheme: IconThemeData(color: AppColors.primary),
      ),
      body:
          _isLoading || positionState.isLoading
              ? Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
              : Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      _buildSectionTitle("Title *"),
                      _buildTextField(
                        _titleController,
                        "Ex: Retail Sales Manager",
                        true,
                      ),

                      SizedBox(height: 16),
                      _buildSectionTitle("Employment Type"),
                      _buildDropdown(
                        _employmentType,
                        [
                          EmploymentTypes.fullTime,
                          EmploymentTypes.partTime,
                          EmploymentTypes.freelance,
                          EmploymentTypes.selfEmployed,
                          EmploymentTypes.contract,
                          EmploymentTypes.internship,
                          EmploymentTypes.apprenticeship,
                          EmploymentTypes.seasonal,
                        ],
                        (val) => setState(() => _employmentType = val),
                      ),

                      SizedBox(height: 16),
                      _buildSectionTitle("Company or Organization *"),
                      _buildTextField(
                        _companyController,
                        "Ex: Microsoft",
                        true,
                      ),

                      SizedBox(height: 16),
                      CheckboxListTile(
                        title: Text("I am currently working in this role"),
                        value: _currentlyWorking,
                        onChanged:
                            (val) => setState(
                              () => _currentlyWorking = val ?? false,
                            ),
                      ),

                      SizedBox(height: 16),
                      _buildSectionTitle("Time Period"),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDateSelector(
                              "Start Date",
                              _startDate,
                              () => _pickDate(true),
                            ),
                          ),
                          SizedBox(width: 16),
                          if (!_currentlyWorking)
                            Expanded(
                              child: _buildDateSelector(
                                "End Date",
                                _endDate,
                                () => _pickDate(false),
                              ),
                            ),
                        ],
                      ),

                      SizedBox(height: 16),
                      _buildSectionTitle("Location Type"),
                      _buildDropdown(_locationType, [
                        "Onsite",
                        "Hybrid",
                        "Remote",
                      ], (val) => setState(() => _locationType = val)),

                      SizedBox(height: 16),
                      _buildSectionTitle("Location"),
                      _buildTextField(
                        _locationController,
                        "Ex: New York, NY",
                        false,
                      ),

                      SizedBox(height: 16),
                      _buildSectionTitle("Description"),
                      _buildTextField(
                        _descriptionController,
                        "Unlock AI assistance with 20 words",
                        false,
                        maxLines: 5,
                      ),

                      SizedBox(height: 16),
                      _buildSectionTitle("Where did you find this job?"),
                      _buildDropdown(_jobSource, [
                        foundVia.indeed,
                        foundVia.linkedIn,
                        foundVia.companyWebsite,
                        foundVia.otherJobSites,
                        foundVia.referral,
                        foundVia.contractedByRecruiter,
                        foundVia.staffingAgency,
                        foundVia.other,
                      ], (val) => setState(() => _jobSource = val)),

                      SizedBox(height: 16),
                      _buildSectionTitle("Skills (up to 5)"),
                      Wrap(
                        spacing: 8,
                        children:
                            _skills
                                .map(
                                  (s) => Chip(
                                    label: Text(s),
                                    onDeleted:
                                        () => setState(() => _skills.remove(s)),
                                  ),
                                )
                                .toList(),
                      ),
                      OutlinedButton.icon(
                        onPressed: _addSkill,
                        icon: Icon(Icons.add),
                        label: Text("Add Skill"),
                      ),

                      SizedBox(height: 16),
                      _buildSectionTitle("Media"),
                      _mediaFiles.isEmpty
                          ? Text(
                            "Add photos, certificates, or documents",
                            style: TextStyle(color: Colors.grey),
                          )
                          : SizedBox(
                            height: 100,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _mediaFiles.length,
                              itemBuilder:
                                  (_, i) => Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: Stack(
                                      children: [
                                        Image.file(
                                          _mediaFiles[i],
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.cover,
                                        ),
                                        Positioned(
                                          top: 4,
                                          right: 4,
                                          child: GestureDetector(
                                            onTap:
                                                () => setState(
                                                  () => _mediaFiles.removeAt(i),
                                                ),
                                            child: CircleAvatar(
                                              radius: 12,
                                              backgroundColor: Colors.black54,
                                              child: Icon(
                                                Icons.close,
                                                color: Colors.white,
                                                size: 16,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                            ),
                          ),
                      OutlinedButton.icon(
                        onPressed: _pickMedia,
                        icon: Icon(Icons.attach_file),
                        label: Text("Add Media"),
                      ),

                      SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _savePosition(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          "Save Position",
                          style: TextStyle(fontSize: 16),
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
    child: Text(text, style: TextStyle(fontWeight: FontWeight.bold)),
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
              ? (val) => val == null || val.isEmpty ? 'Required' : null
              : null,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildDropdown(
    String? value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: value,
      items:
          items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildDateSelector(String label, DateTime? date, VoidCallback onTap) {
    final formatted =
        date != null ? DateFormat('MMM d, yyyy').format(date) : 'Select date';
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                formatted,
                style: TextStyle(
                  color: date != null ? Colors.black : Colors.grey,
                ),
              ),
            ),
            Icon(Icons.calendar_today, size: 18, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}

class EmploymentTypes {
  static const String fullTime = "Full Time";
  static const String partTime = "Part Time";
  static const String freelance = "Freelance";
  static const String selfEmployed = "Self Employed";
  static const String contract = "Contract";
  static const String internship = "Internship";
  static const String apprenticeship = "Apprenticeship";
  static const String seasonal = "Seasonal";
}

class foundVia {
  static const String indeed = "Indeed";
  static const String linkedIn = "LinkedIn";
  static const String companyWebsite = "Company Website";
  static const String otherJobSites = "Other job sites";
  static const String referral = "Referral";
  static const String contractedByRecruiter = "Contracted by Recruiter";
  static const String staffingAgency = "Staffing Agency";
  static const String other = "Other";
}
