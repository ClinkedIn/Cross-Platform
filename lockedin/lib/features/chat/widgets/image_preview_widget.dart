import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/features/chat/model/attachment_model.dart';
import 'package:lockedin/features/chat/viewModel/chat_conversation_viewmodel.dart';

class ImagePreviewWidget extends ConsumerWidget {
  final ChatAttachment attachment;
  final String chatId;
  final Function onSend;
  
  const ImagePreviewWidget({
    Key? key,
    required this.attachment,
    required this.chatId,
    required this.onSend,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          SizedBox(height: 16),
          Expanded(
            child: Image.file(
              attachment.file,
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton.icon(
                onPressed: () {
                  ref.read(chatConversationProvider(chatId).notifier)
                    .clearSelectedAttachment();
                  Navigator.pop(context);
                },
                icon: Icon(Icons.delete, color: Colors.red),
                label: Text('Cancel', style: TextStyle(color: Colors.red)),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  onSend();
                },
                icon: Icon(Icons.send),
                label: Text('Send'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}