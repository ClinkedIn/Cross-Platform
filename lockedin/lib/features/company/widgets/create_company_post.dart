import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/features/company/viewmodel/company_viewmodel.dart';
import 'package:sizer/sizer.dart';

class CreateCompanyPostWidget extends ConsumerStatefulWidget {
  final String companyId;
  const CreateCompanyPostWidget({super.key, required this.companyId});

  @override
  ConsumerState<CreateCompanyPostWidget> createState() =>
      _CreateCompanyPostWidgetState();
}

class _CreateCompanyPostWidgetState
    extends ConsumerState<CreateCompanyPostWidget> {
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();

  List<String> filePaths = [];
  List<Map<String, dynamic>> taggedUsers = [];

  Future<void> pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'jpeg', 'mp4', 'mov', 'avi'],
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        filePaths = result.paths.whereType<String>().toList();
      });
    }
  }

  void addTaggedUser() {
    final id = _tagController.text.trim();
    if (id.isNotEmpty) {
      setState(() {
        taggedUsers.add({"_id": id});
        _tagController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(companyViewModelProvider);

    return Padding(
      padding: EdgeInsets.all(2.h),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: EdgeInsets.all(4.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _descController,
                decoration: InputDecoration(
                  labelText: 'Post Description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 2.h),

              /// File Picker Button
              ElevatedButton.icon(
                onPressed: pickFiles,
                icon: Icon(Icons.attach_file),
                label: Text("Pick Files"),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 6.w),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              /// Display Picked File Names
              if (filePaths.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:
                      filePaths
                          .map(
                            (path) => Padding(
                              padding: EdgeInsets.symmetric(vertical: 1.h),
                              child: Text(path.split('/').last),
                            ),
                          )
                          .toList(),
                ),
              SizedBox(height: 2.h),

              /// Tagged Users Input
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _tagController,
                      decoration: InputDecoration(
                        labelText: 'User ID to tag',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  IconButton(icon: Icon(Icons.add), onPressed: addTaggedUser),
                ],
              ),

              /// Display Tagged Users as Chips
              if (taggedUsers.isNotEmpty)
                Wrap(
                  spacing: 8.0,
                  children:
                      taggedUsers
                          .map(
                            (u) => Chip(
                              label: Text(u['_id']),
                              backgroundColor: Colors.blue.shade100,
                            ),
                          )
                          .toList(),
                ),
              SizedBox(height: 2.h),

              /// Submit Post Button
              ElevatedButton(
                onPressed: () async {
                  if (_descController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Description cannot be empty")),
                    );
                    return;
                  }

                  final success = await ref
                      .read(companyViewModelProvider)
                      .createPost(
                        companyId: widget.companyId,
                        description: _descController.text,
                        whoCanSee: "anyone",
                        whoCanComment: "anyone",
                        taggedUsers: taggedUsers,
                        filePaths: filePaths,
                      );

                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Post created successfully")),
                    );
                    _descController.clear();
                    setState(() {
                      filePaths.clear();
                      taggedUsers.clear();
                    });
                  }
                },
                child: Text("Create Post"),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 1.5.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 2.h),

              /// Back Button (optional, can be added here or as Floating Action Button)
              TextButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: Icon(Icons.arrow_back),
                label: Text("Back to Company Profile"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
