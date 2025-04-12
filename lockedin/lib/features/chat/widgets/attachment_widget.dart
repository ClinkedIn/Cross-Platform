import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class AttachmentWidget extends StatelessWidget {
  final VoidCallback onDocumentPressed;
  final VoidCallback onCameraPressed;
  final VoidCallback onMediaPressed;

  const AttachmentWidget({
    Key? key,
    required this.onDocumentPressed,
    required this.onCameraPressed,
    required this.onMediaPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildAttachmentButton(Icons.insert_drive_file, "Document", onDocumentPressed),
              _buildAttachmentButton(Icons.camera_alt, "Camera", onCameraPressed),
              _buildAttachmentButton(Icons.image, "Media", onMediaPressed),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentButton(IconData icon, String label, VoidCallback onPressed) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon, size: 9.w,),
          color: Colors.black54,
          onPressed: onPressed,
        ),
        Text(
          label,
          style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
