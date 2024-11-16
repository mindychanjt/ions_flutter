import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ions_flutter/ball.dart';
import 'package:ions_flutter/brick.dart';
import 'package:ions_flutter/coverscreen.dart';
import 'package:ions_flutter/gameoverscreen.dart';
import 'package:ions_flutter/player.dart';

class HomePage extends StatefulWidget {
  const HomePage ({Key? key}): super(key:key);

  @override
  _HomePageState createState() => _HomePageState();
}

enum direction { UP, DOWN, LEFT, RIGHT }

class _HomePageState extends State<HomePage> {
  // ball variables
  double ballX = 0;
  double ballY = 0;
  double ballXincrements = 0.02;
  double ballYincrements = 0.01;
  var ballYDirection = direction.DOWN;
  var ballXDirection = direction.LEFT;

  // player variables
  double playerX = -0.2;
  double playerWidth = 0.4; // out of 2

  // brick variables
  static double firstbrickX = -1 + wallGap;
  static double firstbrickY = -0.9;
  static double brickWidth = 0.4; // out of 2
  static double brickHeight = 0.08; // out of 2
  static double brickGap = 0.01;
  static int numberOfBricksInRow = 3;
  static double wallGap = 0.5 * 
      (2 - numberOfBricksInRow * brickWidth - 
          (numberOfBricksInRow-1) * brickGap);
  

  List MyBricks = [
    // [x,y, broken = true/false]
    [firstbrickX + 0 * (brickWidth + brickGap), firstbrickY, false],
    [firstbrickX + 1 * (brickWidth + brickGap), firstbrickY, false],
    [firstbrickX + 2 * (brickWidth + brickGap), firstbrickY, false],
  ]; 

  // game settings
  bool hasGameStarted = false;
  bool isGameOver = false;
  // bool brickBroken = false;

  // start game
  void startGame() {
    hasGameStarted = true;

    ballYDirection = direction.DOWN;
    ballXDirection = direction.LEFT;
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
    // checks for when ball isw inside the brick (aks hits brick)
    for(int i = 0; i < MyBricks.length; i++) {
      if (ballX >= MyBricks[i][0] && 
          ballX <= MyBricks[i][0] + brickWidth && 
          ballY >= MyBricks[i][1] + brickHeight && 
          MyBricks[i][2] == false) {
        setState(() {
          MyBricks[i][2] = true;

          // since brick is broken, update direction of ball based on which side of the brick it hit
          // to do this, calculate the distance of the ball from each of the 4 sides
          // the smallest distance is the side the ball has it
          
          double leftSideDist = (MyBricks[i][0] - ballX).abs();
          double rightSideDist = (MyBricks[i][0] + brickWidth - ballX).abs();
          double topSideDist = (MyBricks[i][1] - ballY).abs();
          double bottomSideDist = (MyBricks[i][1] + brickHeight - ballY).abs();

          String min = findMin(leftSideDist, rightSideDist, topSideDist, bottomSideDist);
          
          switch (min) {
            case 'left': ballXDirection = direction.LEFT;
              
              break;
            case 'right': ballXDirection = direction.RIGHT;
              
              break;
            case 'top': ballYDirection = direction.UP;
              
              break;
            case 'bottom': ballYDirection = direction.DOWN;
              
              break;
            default:
          }
        });
      }
    }
  }

  // returns the smallest side 
  String findMin(double a, double b, double c, double d) {
    List<double> myList = [
      a,
      b,
      c,
      d,
    ];
    double currentMin = a;
    for(int i=0; i < myList.length; i++) {
      if(myList[i] < currentMin) {
      currentMin = myList[i];
      }
    }

    if((currentMin - a).abs() < 0.01) {
      return 'left';
    } else if ((currentMin - b).abs() < 0.01) {
      return 'right';
    } else if ((currentMin - c).abs() < 0.01) {
      return 'top';
    } else if ((currentMin - d).abs() < 0.01) {
      return 'bottom';
    } 
    return '';
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
      if (!(playerX - 0.1 <= -1)) {
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

  // reset game back to initial values when user hits play again
  void resetGame() {
    setState(() {
      playerX = -0.2;
      ballX = 0;
      ballY = 0;
      isGameOver = false;
      hasGameStarted = false;
      MyBricks = [
        // [x,y, broken = true/false]
        [firstbrickX + 0 * (brickWidth + brickGap), firstbrickY, false],
        [firstbrickX + 1 * (brickWidth + brickGap), firstbrickY, false],
        [firstbrickX + 2 * (brickWidth + brickGap), firstbrickY, false],
      ]; 
    });
  }
  
@override
Widget build(BuildContext context) {
  return KeyboardListener(
    focusNode: FocusNode(),
    autofocus: true,
    onKeyEvent: (event) {
      // Use RawKeyDownEvent to detect the key press only once (avoiding repeated triggers)
        if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
          moveLeft();
        } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
          moveRight();
        }
        
        if(event.logicalKey == LogicalKeyboardKey.keyK) {
          isGameOver = true;
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
                  isGameOver: isGameOver,
                ), 

                // game over screen
                GameOverScreen(
                  isGameOver: isGameOver,
                  function: resetGame
                ),

                // ball
                MyBall(
                  ballX: ballX,
                  ballY: ballY,
                  hasGameStarted: hasGameStarted,
                  isGameOver: isGameOver,
                ), 
      
                // player
                MyPlayer(
                  playerX: playerX,
                  playerWidth: playerWidth,
                ),
                
                // bricks
                MyBrick(
                  brickX: MyBricks[0][0],
                  brickY: MyBricks[0][1],
                  brickBroken: MyBricks[0][2],
                  brickHeight: brickHeight,
                  brickWidth: brickWidth,
                ),
                MyBrick(
                  brickX: MyBricks[1][0],
                  brickY: MyBricks[1][1],
                  brickBroken: MyBricks[1][2],
                  brickHeight: brickHeight,
                  brickWidth: brickWidth,
                ),
                MyBrick(
                  brickX: MyBricks[2][0],
                  brickY: MyBricks[2][1],
                  brickBroken: MyBricks[2][2],
                  brickHeight: brickHeight,
                  brickWidth: brickWidth,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}