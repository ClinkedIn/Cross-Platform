import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/features/chat/viewModel/chat_conversation_viewmodel.dart';
import 'package:lockedin/features/chat/widgets/block_dialog_widget.dart';

class BlockButtonWidget extends ConsumerWidget {
  final String chatId;
  
  const BlockButtonWidget({
    Key? key,
    required this.chatId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final receiverId = ref.read(chatConversationProvider(chatId).notifier).getReceiverUserId();
    
    // Only show block button if we have a valid receiver ID
    if (receiverId == null || receiverId.isEmpty) {
      return SizedBox.shrink(); // Hide button if no receiver ID
    }
    
    return FutureBuilder<bool>(
      future: ref.read(chatConversationProvider(chatId).notifier).isUserBlocked(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: null,
          );
        }
        
        final isBlocked = snapshot.data ?? false;
        
        return IconButton(
          icon: Icon(
            isBlocked ? Icons.block : Icons.block_outlined,
            color: isBlocked ? Colors.red : null,
          ),
          onPressed: () {
            showDialog(
              context: context,
              builder: (dialogContext) => BlockDialogWidget(
                chatId: chatId,
                isBlocked: isBlocked,
              ),
            );
          },
        );
      },
    );
  }
}