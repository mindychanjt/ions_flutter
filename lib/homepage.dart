import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ions_flutter/ball.dart';
import 'package:ions_flutter/brick.dart';
import 'package:ions_flutter/coverscreen.dart';
import 'package:ions_flutter/gameoverscreen.dart';
import 'package:ions_flutter/player.dart';

class HomePage extends StatefulWidget {
  const HomePage ({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

enum direction { UP, DOWN }

class _HomePageState extends State<HomePage> {
  // ball variables
  double ballX = 0;
  double ballY = 0;
  var ballDirection = direction.DOWN;

  // player variables
  double playerX = -0.2;
  double playerWidth = 0.4; // out of 2

  // brick variables
  double brickX = 0;
  double brickY = -0.9;
  double brickWidth = 0.4; // out of 2
  double brickHeight = 0.05; // out of 2
  bool brickBroken = false;

  // game settings
  bool hasGameStarted = false;
  bool isGameOver = false;

  // start game
  void startGame() {
    hasGameStarted = true;
    Timer.periodic(const Duration(milliseconds: 10), (timer) {
      // update direction
      updateDirection();

      // move ball
      moveBall();

      // check if player dead
      if (isPlayerDead()) {
        timer.cancel();
        isGameOver = true;
      }

      // check if brick is hit
      checkForBrokenBricks();

    });
  }

  void checkForBrokenBricks() {
    // checks for when ball hits bottom of brick
    if (ballX >= brickX && ballX <= brickX + brickWidth 
      && ballY >= brickY + brickHeight
      && brickBroken == false) {
    setState(() {
      brickBroken = true;
      });
    }
  }

  // is  player dead
  bool isPlayerDead() {
    // player dies if ball reaches the bottom of screen
    if(ballY >= 1){
      return true;
    }
    
    return false;
  }

  // move ball
  void moveBall() {
    setState(() {
      if (ballDirection == direction.DOWN) {
        ballY += 0.01;
      } else if (ballDirection == direction.UP) {
        ballY -= 0.01;
      }
    });
  }

  // update direction of the ball
  void updateDirection() {
    setState(() {
      if (ballY >= 0.9 && ballX >= playerX && ballX <= playerX + playerWidth) {
      ballDirection = direction.UP;
    } else if (ballY <= -0.9) {
          ballDirection = direction.DOWN;
    }
    });
  }

  // move player left
  void moveLeft() {
    setState(() {
      // only move left if moving left doesn't move player off the screen
      if (!(playerX - 0.2 < -1)) {
          playerX -= 0.2;
        }
    });
  }

  // move player right
  void moveRight() {
    // only move right if moving right doesn't move player off the screen
      if (!(playerX + playerWidth >= 1)) {
          playerX += 0.2;
        }
  }
  
@override
Widget build(BuildContext context) {
  return KeyboardListener(
    focusNode: FocusNode(),
    autofocus: true,
    onKeyEvent: (event) {
      // Use RawKeyDownEvent to detect the key press only once (avoiding repeated triggers)
      if (event is KeyDownEvent) {
        if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
          moveLeft();
        } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
          moveRight();
        }
      }
    },
      child: GestureDetector(
        onTap: startGame,
        child: Scaffold(
          backgroundColor: Colors.deepPurple[100],
          body: Center(
            child: Stack(
              children: [
                // tap to play
                CoverScreen(
                  hasGameStarted: hasGameStarted,
                ), 
                // game over screen
                GameOverScreen(isGameOver: isGameOver),

                // ball
                MyBall(
                  ballX: ballX,
                  ballY: ballY,
                ), 
      
                // player
                MyPlayer(
                  playerX: playerX,
                  playerWidth: playerWidth,
                ),
                
                // bricks
                MyBrick(
                  brickX: brickX,
                  brickY: brickY,
                  brickHeight: brickHeight,
                  brickWidth: brickWidth,
                  brickBroken: brickBroken,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}