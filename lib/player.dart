import 'package:flutter/material.dart';

class MyPlayer extends StatelessWidget {
  final double playerX;
  final double playerWidth; // out of 2

  const MyPlayer({super.key, required this.playerX, required this.playerWidth});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment(
        (2 * playerX + playerWidth) / (2 - playerWidth), 0.9
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 10,
          width: MediaQuery.of(context).size.width * playerWidth / 2,
          color: Colors.deepPurple,
        ),
      ),
    );
  }
}
