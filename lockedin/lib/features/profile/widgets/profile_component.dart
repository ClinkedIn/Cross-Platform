import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lockedin/features/profile/model/profile_item_model.dart';

class ProfileComponent extends StatelessWidget {
  final String sectionTitle;
  final List<ProfileItemModel> items;
  final VoidCallback onAdd;
  final VoidCallback onEdit;

  const ProfileComponent({
    Key? key,
    required this.sectionTitle,
    required this.items,
    required this.onAdd,
    required this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final iconColor = theme.iconTheme.color;
    final cardColor = theme.cardTheme.color;

    return Card(
      margin: const EdgeInsets.all(10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 3,
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Row with Buttons
            Row(
              children: [
                Text(sectionTitle, style: textTheme.headlineMedium),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.add, color: iconColor),
                  onPressed: onAdd,
                ),
                IconButton(
                  icon: Icon(Icons.edit, color: iconColor),
                  onPressed: onEdit,
                ),
              ],
            ),
            const Divider(),
            Column(
              children: items.map((item) => ProfileItem(item: item)).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileItem extends StatelessWidget {
  final ProfileItemModel item;

  const ProfileItem({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          buildImageWidget(item.logoUrl, 50, 50),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                item.subtitle,
                style: textTheme.bodyMedium?.copyWith(
                  color: textTheme.bodyMedium?.color, // Ensures adaptive color
                ),
              ),
              Text(
                item.duration,
                style: textTheme.bodySmall?.copyWith(
                  color: textTheme.bodySmall?.color?.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Widget buildImageWidget(String? imageUrl, double width, double height) {
  // If null or empty, use default asset
  if (imageUrl == null || imageUrl.isEmpty) {
    return Image.asset(
      'assets/images/experience.jpg',
      width: width,
      height: height,
      fit: BoxFit.cover,
    );
  }

  // If it's a network URL (starts with http or https)
  if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
    return Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(
          'assets/images/experience.jpg',
          width: width,
          height: height,
          fit: BoxFit.cover,
        );
      },
    );
  }

  // If it's a file path (starts with file:// or /)
  if (imageUrl.startsWith('file://') || imageUrl.startsWith('/')) {
    return Image.file(
      File(imageUrl.replaceFirst('file://', '')),
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(
          'assets/images/experience.jpg',
          width: width,
          height: height,
          fit: BoxFit.cover,
        );
      },
    );
  }

  // If it's just a filename, assume it's an asset
  return Image.asset(
    imageUrl,
    width: width,
    height: height,
    fit: BoxFit.cover,
    errorBuilder: (context, error, stackTrace) {
      return Image.asset(
        'assets/images/experience.jpg',
        width: width,
        height: height,
        fit: BoxFit.cover,
      );
    },
  );
}
