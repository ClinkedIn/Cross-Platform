import 'package:flutter/material.dart';
import 'package:lockedin/features/networks/widgets/connect_card.dart';

class ConnectCardsGridView extends StatelessWidget {
  final List<ConnectCard> connectCards;

  const ConnectCardsGridView({required this.connectCards, Key? key})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calculate the height based on the number of cards
    // Each row has 2 cards, so divide the total by 2 and round up
    int rowCount = (connectCards.length / 2).ceil();

    // Each card has a fixed height of around 220-250 pixels
    // Adding spacing between rows (16.0)
    double gridHeight = rowCount * 240.0 + (rowCount - 1) * 16.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: SizedBox(
        height: gridHeight,
        child: GridView.builder(
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Two cards per row
            childAspectRatio: 0.75, // Adjusted for card proportions
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 16.0,
          ),
          itemCount: connectCards.length,
          itemBuilder: (context, index) {
            final card = connectCards[index];
            return ConnectCard(
              backgroundImage: card.backgroundImage,
              profileImage: card.profileImage,
              name: card.name,
              headline: card.headline,
              onCardTap: card.onCardTap,
              onConnectTap: card.onConnectTap,
              isPending: card.isPending,
            );
          },
        ),
      ),
    );
  }
}
