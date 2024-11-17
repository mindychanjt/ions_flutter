import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GameOverScreen extends StatelessWidget {
  final bool isGameOver;
  final void Function()? function;  // Explicitly typed callback

  // font
  static var gameFont = GoogleFonts.pressStart2p(
    textStyle: TextStyle(
      color: Colors.deepPurple[600], letterSpacing: 0, fontSize: 20));

  const GameOverScreen({super.key, required this.isGameOver, this.function});

  @override
  Widget build(BuildContext context) {
    return isGameOver 
      ? Stack(children: [
          Container(
            alignment: const Alignment(0,-0.3), // Use const here
            child: Text(
              'GAME  OVER', 
              style: gameFont,
            ),
          ),
          Container(
            alignment: const Alignment(0,0), // Use const here
            child: GestureDetector(
              onTap: function,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(10), // Use const here
                  color: Colors.deepPurple,
                  child: const Text(
                    'PLAY AGAIN', 
                    style: TextStyle(color: Colors.white),
                  ), // Use const here
                ),
              ),
            ),
          )
      ])
      : const SizedBox();  // Use const here for empty container when no game over
  }
}

