import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/features/chat/model/attachment_model.dart';
import 'package:lockedin/features/chat/viewModel/chat_conversation_viewmodel.dart';

class DocumentPreviewWidget extends ConsumerWidget {
  final ChatAttachment attachment;
  final String chatId;
  final Function onSend;
  
  const DocumentPreviewWidget({
    Key? key,
    required this.attachment,
    required this.chatId,
    required this.onSend,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.4,
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.description, size: 40, color: Colors.blue),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        attachment.fileName ?? 'Document',
                        style: TextStyle(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${(attachment.file.lengthSync() / 1024).toStringAsFixed(2)} KB',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24),
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