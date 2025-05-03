import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lockedin/features/company/view/create_company_view.dart';

class CreatePostScreen extends ConsumerStatefulWidget {
  final String companyId;
  final String? description; // Optional description to pre-fill

  const CreatePostScreen({Key? key, required this.companyId, this.description})
    : super(key: key);

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  late final TextEditingController _postController;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _postController = TextEditingController(text: widget.description ?? '');
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  Future<void> _submitPost() async {
    final postText = _postController.text.trim();

    if (postText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Post description is required")),
      );
      return;
    }

    final viewModel = ref.read(companyViewModelProvider);

    final success = await viewModel.createPost(
      companyId: widget.companyId,
      description: postText,
      filePaths: _selectedImage != null ? [_selectedImage!.path] : null,
    );

    if (success) {
      Navigator.pop(context, true);
    } else {
      final error = viewModel.errorMessage ?? 'Failed to create post.';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(companyViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Create Post")),
      body:
          viewModel.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _postController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: "What do you want to talk about?",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_selectedImage != null)
                      Stack(
                        children: [
                          Image.file(_selectedImage!),
                          Positioned(
                            right: 4,
                            top: 4,
                            child: IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  _selectedImage = null;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.image),
                          onPressed: _pickImage,
                        ),
                        ElevatedButton(
                          onPressed: _submitPost,
                          child: const Text("Post"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
    );
  }
}
