// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';
import 'package:ions_flutter/ball.dart';
import 'package:ions_flutter/brick.dart';
import 'package:ions_flutter/coverscreen.dart';
import 'package:ions_flutter/gameoverscreen.dart';
import 'package:ions_flutter/player.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

enum Direction { UP, DOWN, LEFT, RIGHT }

class HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late Ticker _ticker;
  final FocusNode _focusNode = FocusNode();
  bool hasGameStarted = false;
  bool isGameOver = false;

  double ballX = 0;
  double ballY = 0;
  double ballXincrements = 0.02;
  double ballYincrements = 0.01;
  var ballXDirection = Direction.LEFT;
  var ballYDirection = Direction.DOWN;


// player variables
  double playerX = -0.2;
  double playerWidth = 0.4;

  // brick variables
  static double firstBrickX = -1 + wallGap;
  static double firstBrickY = -0.9;
  static double brickWidth = 0.4;
  static double brickHeight = 0.05;
  static double brickGap = 0.01;
  static int numberOfBricksInRow = 5;
  static double wallGap = 0.5 * (2 - numberOfBricksInRow * brickWidth - (numberOfBricksInRow-1) * brickGap);
  bool brickBroken = false;

  List MyBricks = [
    // [x,y,broken =true/false]
    [firstBrickX + 0*(brickWidth + brickGap),firstBrickY,false],
    [firstBrickX + 1*(brickWidth + brickGap), firstBrickY,false],
    [firstBrickX + 2*(brickWidth + brickGap), firstBrickY,false],
  ];
  
@override
void initState() {
  super.initState();
  MyBricks = generateBricks(3); // Start with 3 rows
  _ticker = createTicker((Duration elapsed) {
    if (hasGameStarted && !isGameOver) {
      setState(() {
        updateDirection();
        moveBall();
        checkForBrokenBricks();

        if (isPlayerDead()) {
          isGameOver = true;
          _ticker.stop();
        }
      });
    }
  });
}


  void startGame() {
    setState(() {
      hasGameStarted = true;
    });
    _ticker.start();
  }

  void moveBall() {
    if (ballXDirection == Direction.LEFT) {
      ballX -= ballXincrements;
    } else if (ballXDirection == Direction.RIGHT) {
      ballX += ballXincrements;
    }

    if (ballYDirection == Direction.UP) {
      ballY -= ballYincrements;
    } else if (ballYDirection == Direction.DOWN) {
      ballY += ballYincrements;
    }
  }

  void updateDirection() {
    // Ball collision with the player
    if (ballY >= 0.9 && ballX >= playerX && ballX <= playerX + playerWidth) {
      ballYDirection = Direction.UP;
    } else if (ballY <= -1) {
      ballYDirection = Direction.DOWN;
    }

    // Ball collision with walls
    if (ballX >= 1) {
      ballXDirection = Direction.LEFT;
    } else if (ballX <= -1) {
      ballXDirection = Direction.RIGHT;
    }
  }

void checkForBrokenBricks() {
  for (int i = 0; i < MyBricks.length; i++) {
    if (ballX >= MyBricks[i][0] &&
        ballX <= MyBricks[i][0] + brickWidth &&
        ballY >= MyBricks[i][1] &&
        ballY <= MyBricks[i][1] + brickHeight &&
        MyBricks[i][2] == false) {
      setState(() {
        MyBricks[i][2] = true;

        double leftDist = (MyBricks[i][0] - ballX).abs();
        double rightDist = (MyBricks[i][0] + brickWidth - ballX).abs();
        double topDist = (MyBricks[i][1] - ballY).abs();
        double bottomDist = (MyBricks[i][1] + brickHeight - ballY).abs();

        String collisionSide =
            findMin(leftDist, rightDist, topDist, bottomDist);

        switch (collisionSide) {
          case 'left':
            ballXDirection = Direction.LEFT;
            break;
          case 'right':
            ballXDirection = Direction.RIGHT;
            break;
          case 'top':
            ballYDirection = Direction.UP;
            break;
          case 'bottom':
            ballYDirection = Direction.DOWN;
            break;
        }
      });
    }
  }

  // Check if all bricks are broken
  if (MyBricks.every((brick) => brick[2] == true)) {
    addBrickRow();
  }
}


  String findMin(double left, double right, double top, double bottom) {
    final distances = {'left': left, 'right': right, 'top': top, 'bottom': bottom};
    return distances.entries.reduce((a, b) => a.value < b.value ? a : b).key;
  }

  bool isPlayerDead() {
    return ballY >= 1; // Ball hits the top of the screen
  }

  void moveLeft() {
    setState(() {
      if (!(playerX - 0.1 <= -1)) {
        playerX -= 0.2;
      }
    });
  }

  void moveRight() {
    setState(() {
      if (!(playerX + playerWidth >= 1)) {
        playerX += 0.2;
      }
    });
  }

void resetGame() {
  setState(() {
    playerX = -0.2;
    ballX = 0;
    ballY = 0;
    isGameOver = false;
    hasGameStarted = false;
    MyBricks = generateBricks(3); // Start with 3 rows of bricks
  });
}

List<List<dynamic>> generateBricks() {
  return [
    [firstBrickX + 0 * (brickWidth + brickGap), firstBrickY, false],
    [firstBrickX + 1 * (brickWidth + brickGap), firstBrickY, false],
    [firstBrickX + 2 * (brickWidth + brickGap), firstBrickY, false],
    [firstBrickX + 3 * (brickWidth + brickGap), firstBrickY, false],
    [firstBrickX + 4 * (brickWidth + brickGap), firstBrickY, false],
    // Add more bricks as needed
  ];
}



  @override
  void dispose() {
    _focusNode.dispose();
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (event) {
        if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
          moveLeft();
        } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
          moveRight();
        }
        if (event.logicalKey == LogicalKeyboardKey.keyK) {
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
                CoverScreen(
                  hasGameStarted: hasGameStarted,
                  isGameOver: isGameOver,
                ),
                GameOverScreen(
                  isGameOver: isGameOver,
                  function: resetGame,
                ),
                MyBall(
                  ballX: ballX,
                  ballY: ballY,
                  hasGameStarted: hasGameStarted,
                  isGameOver: isGameOver,
                ),
                MyPlayer(
                  playerX: playerX,
                  playerWidth: playerWidth,
                ),
                for (var brick in MyBricks)
                  MyBrick(
                    brickX: brick[0],
                    brickY: brick[1],
                    brickBroken: brick[2],
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

