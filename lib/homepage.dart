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

  // Game state variables
  final FocusNode _focusNode = FocusNode();
  bool hasGameStarted = false;
  bool isGameOver = false;

  // Ball variables
  double ballX = 0;
  double ballY = 0;
  static const double ballXIncrements = 0.02;
  static const double ballYIncrements = 0.01;
  Direction ballXDirection = Direction.LEFT;
  Direction ballYDirection = Direction.DOWN;

  // Player variables
  double playerX = -0.2;
  static const double playerWidth = 0.4;

  // STEP 4: configure the brick properties with values
  // Brick configuration
  static const double brickWidth = 0.4;
  static const double brickHeight = 0.05;
  static const double brickGap = 0.01;
  // go through the wallGap formula with the diagram 
  static const int numberOfBricksInRow = 1;
  static const double wallGap = 
      0.5 * (2 - numberOfBricksInRow * brickWidth - (numberOfBricksInRow - 1) * brickGap);
  static const double firstBrickX = -1 + wallGap;
  static const double firstBrickY = -0.7;

  // STEP 5: add an empty brick list
  // Brick list
  List<List<dynamic>> bricks = [];

  @override
  void initState() {
    super.initState();
    bricks = generateBricks(1); // Start with 3 rows
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
      ballX -= ballXIncrements;
    } else if (ballXDirection == Direction.RIGHT) {
      ballX += ballXIncrements;
    }

    if (ballYDirection == Direction.UP) {
      ballY -= ballYIncrements;
    } else if (ballYDirection == Direction.DOWN) {
      ballY += ballYIncrements;
    }
  }

  void updateDirection() {
    // Ball collision with player paddle
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

  /*
  STEP 7:
         Use a for loop; it iterates through all bricks to check for collisions
  brick[0] & brick[1] represents the x & y coordinates of the brick's top-left corner
  brick[2] indicates whether the brick is already broken; "true" if broken, "false" if not
    */
  void checkForBrokenBricks() {
    for (int i = 0; i < bricks.length; i++) {
      final brick = bricks[i];
      //ballX is within the brick's horizontal range so we type:
      if (ballX >= brick[0] &&
          ballX <= brick[0] + brickWidth &&
          // ball y is within the brick's vertical range hence we type:
          ballY >= brick[1] &&
          ballY <= brick[1] + brickHeight &&
          // this ensures we only process unbroken bricks 
          !brick[2]) {

        // setState is a flutter method to update the UI
        setState(() {
          brick[2] = true;

          // Determine collision side
          final collisionSide = findMin({
            'left': (brick[0] - ballX).abs(),
            'right': (brick[0] + brickWidth - ballX).abs(),
            'top': (brick[1] - ballY).abs(),
            'bottom': (brick[1] + brickHeight - ballY).abs(),
          });

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

    // Add a new row of bricks if all are broken
    if (bricks.every((brick) => brick[2])) {
      addBrickRow();
    }
  }

  //STEP 8: create a new brick when all bricks are broken
  void addBrickRow() {
    // this is to calculate the new row position
    final newRowY =
        firstBrickY - (bricks.length ~/ numberOfBricksInRow) * (brickHeight + brickGap);
    // iterate through a loop where each brick are space based on the width and gap values
    for (int col = 0; col < numberOfBricksInRow; col++) {
      final brickX = firstBrickX + col * (brickWidth + brickGap);
      // the false here means brick is unbroken
      bricks.add([brickX, newRowY, false]);
    }
  }

  String findMin(Map<String, double> distances) {
    return distances.entries.reduce((a, b) => a.value < b.value ? a : b).key;
  }

  bool isPlayerDead() {
    return ballY >= 1; // Ball falls below screen
  }

  void moveLeft() {
    if (playerX > -1) {
      setState(() {
        playerX -= 0.2;
      });
    }
  }

  void moveRight() {
    if (playerX + playerWidth < 1) {
      setState(() {
        playerX += 0.2;
      });
    }
  }

  void resetGame() {
    setState(() {
      playerX = -0.2;
      ballX = 0;
      ballY = 0;
      isGameOver = false;
      hasGameStarted = false;

      // STEP 9: generate 1 row of bricks when the game is reset
      bricks = generateBricks(1); // Reset with number of rows of bricks
    });
  }

  // STEP 10: CREATES A GRID OF BRICKS FOR THE GAME
  List<List<dynamic>> generateBricks(int rows) {
    // initialise all the bricks where the newbricks will be stored
    final List<List<dynamic>> newBricks = [];
    /* outer loop iterate through the rows
    "row": index through the current row
    "rows" total number of rows to generate
    "rowY" vertical position of the current row 
    */
    for (int row = 0; row < rows; row++) {
      final rowY = firstBrickY - row * (brickHeight + brickGap);
      /* inner loop iterate through bricks in the same row
      "col": index of the current brick in the row
      "numberOfBricksInRow": total number of bricks in a single row
      "brickX": horizontal position of the brick
      */
      for (int col = 0; col < numberOfBricksInRow; col++) {
        final brickX = firstBrickX + col * (brickWidth + brickGap);
        // add the bricks and each brick is represented as below:
        newBricks.add([brickX, rowY, false]);
      }
    }
    // return the completed grid
    return newBricks;
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _ticker.dispose();
    super.dispose();
  }

  /* STEP 6:
      EXPLAIN HERE, FOCUS ON THE BRICK PART
  1. flutter build method defines the UI and interaction logic for the game
  2. combines widgets to display and control game element
  3. Keyboard Listener is for Keyboard Input
  4. GestureDetector is for Tap Input
  5. Scaffold is the Base Structure
  6. Stack contains the game element
  7. the MyBrick is loop through the bricks list to display all bricks
  brick[0] & brick[1] represents the x & y coordinates of the brick's top-left corner
  brick[2] indicates whether the brick is already broken
  */

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
        } else if (event.logicalKey == LogicalKeyboardKey.keyK) {
          setState(() {
            isGameOver = true;
          });
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
                for (var brick in bricks)
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
