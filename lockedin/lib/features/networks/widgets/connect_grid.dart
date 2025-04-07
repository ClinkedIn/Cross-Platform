import 'package:flutter/material.dart';
import 'package:lockedin/features/networks/widgets/connect_card.dart';

class ConnectCardsGridView extends StatelessWidget {
  final List<ConnectCard> connectCards;

  const ConnectCardsGridView({required this.connectCards, Key? key})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      // Wrap GridView in Expanded if it's inside a Column/Row, or use a fixed height
      child: SizedBox(
        height: MediaQuery.of(context).size.height, // Or a fixed height
        child: GridView.builder(
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Two cards per row
            childAspectRatio: 0.95, // Adjusted for card proportions
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
            );
          },
        ),
      ),
    );
  }
}
