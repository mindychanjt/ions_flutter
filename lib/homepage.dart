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

enum direction { UP, DOWN, LEFT, RIGHT }

class _HomePageState extends State<HomePage> {
  // ball variables
  double ballX = 0;
  double ballY = 0;
  double ballXincrements = 0.01;
  double ballYincrements = 0.01;
  var ballYDirection = direction.DOWN;
  var ballXDirection = direction.LEFT;

  // player variables
  double playerX = -0.2;
  double playerWidth = 0.4; // out of 2

  // brick variables
  static double firstbrickX = -0.5;
  static double firstbrickY = -0.9;
  static double brickWidth = 0.4; // out of 2
  static double brickHeight = 0.05; // out of 2
  bool brickBroken = false;

  List MyBricks = (
    // [x,y, broken = true/false]
    [firstbrickX, firstbrickY, false]
  ); 

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
    if (ballX >= MyBricks[0][0] && 
        ballX <= MyBricks[0][0] + brickWidth && 
        ballY >= MyBricks[0][1] + brickHeight && 
        brickBroken == false) {
      setState(() {
        brickBroken = true;
        ballYDirection = direction.DOWN;
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

      // move horizontally
      if (ballXDirection == direction.LEFT) {
        ballX -= ballXincrements;
      } else if (ballXDirection == direction.RIGHT) {
        ballX += ballXincrements;
      }

      //move vertically
      if (ballYDirection == direction.DOWN) {
        ballY += ballYincrements;
      } else if (ballYDirection == direction.UP) {
        ballY -= ballYincrements;
      }
    });
  }

  // update direction of the ball
  void updateDirection() {
    setState(() {

      // ball goes up when it hits player 
      if (ballY >= 0.9 && ballX >= playerX && ballX <= playerX + playerWidth) {
      ballYDirection = direction.UP;
      } 
      // ball goes down when it hits the top of screen
      else if (ballY <= -1) {
          ballYDirection = direction.DOWN;
      }

      // ball goes left when it hits right wall
      if(ballX >= 1) {
        ballXDirection = direction.LEFT;
      } 

      // ball goes right when it hits left wall
      else if (ballX <= -1){
        ballXDirection = direction.RIGHT;
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