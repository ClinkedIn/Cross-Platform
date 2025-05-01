import 'dart:io';
import 'package:lockedin/features/chat/viewModel/chat_conversation_viewmodel.dart';

class ChatAttachment {
  final File file;
  final AttachmentType type;
  final String? previewUrl;
  final String? localId;
  final bool isUploading;
  final double uploadProgress;
  final String? error;
  final String? fileName; 

  ChatAttachment({
    required this.file,
    required this.type,
    this.previewUrl,
    this.localId,
    this.isUploading = false,
    this.uploadProgress = 0.0,
    this.error,
    this.fileName,  
  });

  ChatAttachment copyWith({
    File? file,
    AttachmentType? type,
    String? previewUrl,
    String? localId,
    bool? isUploading,
    double? uploadProgress,
    String? error,
    String? fileName, // Add this property
  }) {
    return ChatAttachment(
      file: file ?? this.file,
      type: type ?? this.type,
      previewUrl: previewUrl ?? this.previewUrl,
      localId: localId ?? this.localId,
      isUploading: isUploading ?? this.isUploading,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      error: error,
      fileName: fileName ?? this.fileName, // Add this property
    );
  }
}