import 'package:flutter/material.dart';
import 'package:avatar_glow/avatar_glow.dart';

class MyBall extends StatelessWidget {
  final double ballX;
  final double ballY;
  final bool isGameOver;
  final bool hasGameStarted;

  const MyBall({super.key,
    required this.ballX, 
    required this.ballY,
    required this.isGameOver,
    required this.hasGameStarted,});

  @override
  Widget build(BuildContext context) {
    return hasGameStarted 
        ? Container(
            alignment: Alignment(ballX,ballY),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isGameOver ? Colors.deepPurple[300] : Colors.deepPurple
              ),
              height: 10,
              width: 10,
            ),
          )
        : Container (
            alignment: Alignment(ballX,ballY),
            child: AvatarGlow(
              glowRadiusFactor: 60.0,
              child: Material(
                elevation : 8.0,
                shape: const CircleBorder(),
                child: CircleAvatar(
                  backgroundColor: Colors.deepPurple[100],
                  radius: 7.0,
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.deepPurple,
                    ),
                    width: 15,
                    height: 15,
                  ),
                ),
              ),
            ),
          );
  }          
}