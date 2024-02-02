import 'package:chain_reaction/constants/common.dart';
import 'package:chain_reaction/utils/common.dart';
import 'package:flutter/material.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final numberOfRows = 6;
  final numberOfColumns = 3;
  List<String> players = ['X', 'Y'];
  List<Color> playerColors = [Colors.green, Colors.orange];
  int currentPlayerIndex = 0;
  List<List<CellItem>> matrix = [];
  List<Dot> dotsList = [];

  int currentId = 1;

  int getNewId() {
    return currentId++;
  }

  @override
  void initState() {
    matrix = List<List<CellItem>>.generate(
        numberOfRows,
        (x) => List<CellItem>.generate(numberOfColumns, (y) => CellItem([], -1),
            growable: false),
        growable: false);
    super.initState();
  }

  handlePendingTasks(List<List<int>> pendingActionCells) {
    final List<List<int>> newPendingItems = [];
    for (var pendingCell in pendingActionCells) {
      final row = pendingCell[0];
      final column = pendingCell[1];
      final possibleMovements = getNumberOfPossibleMovementDirections(
          row, numberOfRows - 1, column, numberOfColumns - 1);
      for (int i = 0; i < possibleMovements.length; i++) {
        final possibleMovement = possibleMovements[i];
        final newRow = possibleMovement[0];
        final newColumn = possibleMovement[1];
        final currentMovingDotId = matrix[row][column].dotIds[i];
        final dotsInNewLocation = matrix[newRow][newColumn].dotIds;
        Future.delayed(const Duration(milliseconds: 500), () {
          for(var dotId in dotsInNewLocation) {
            final newLocationCollegueDotIndex =  dotsList.indexWhere((element) => element.id == dotId);
            dotsList[newLocationCollegueDotIndex].player = matrix[row][column].user;
          }
          setState(() {});
        });
        matrix[newRow][newColumn].dotIds.add(currentMovingDotId);
        final movingDotIndex =
            dotsList.indexWhere((element) => element.id == currentMovingDotId);
        final xDirection = newColumn;
        final yDirection = newRow;
        final xOffset = xDirection * 100.0 + 40;
        final yOffset = yDirection * 100.0 + 40;
        dotsList[movingDotIndex].x = xOffset;
        dotsList[movingDotIndex].y = yOffset;
        dotsList[movingDotIndex].player = currentPlayerIndex;
        matrix[newRow][newColumn].user = currentPlayerIndex;

        if (isCellOverflowing(newRow, newColumn)) {
          newPendingItems.add([newRow, newColumn]);
        }
      }
      matrix[row][column].dotIds = [];
      setState(() {});
      handleDelayedPendingTasks(newPendingItems, false);
    }
  }

  handleDelayedPendingTasks(List<List<int>> pendingActionCells, bool short) {
    if (pendingActionCells.isNotEmpty) {
      Future.delayed(
        Duration(milliseconds: short ? 100 : 1000),
        () => handlePendingTasks(pendingActionCells),
      );
    } else {
      currentPlayerIndex = (currentPlayerIndex + 1) % players.length;
      setState(() {});
    }
  }

  isCellOverflowing(x, y) {
    final possibleMovements = getNumberOfPossibleMovementDirections(
        x, numberOfRows - 1, y, numberOfColumns - 1);
    return matrix[x][y].dotsCount >= possibleMovements.length;
  }

  handleAddDot(int row, int column) {
    final newDotId = getNewId().toString();
    matrix[row][column].dotIds.add(newDotId);
    matrix[row][column].user = currentPlayerIndex;
    final xDirection = column;
    final yDirection = row;
    final xOffset = xDirection * 100.0 + 40;
    final yOffset = yDirection * 100.0 + 40;
    dotsList.add(Dot(newDotId, xOffset, yOffset, currentPlayerIndex));
    setState(() {});
  }

  handleIndexTap(int x, int y) {
    handleAddDot(x, y);
    if (isCellOverflowing(x, y)) {
      handleDelayedPendingTasks([
        [x, y]
      ], true);
    } else {
      handleDelayedPendingTasks([], false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Game Screen')),
      body: Center(
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...matrix.asMap().entries.map(
                      (row) => Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ...row.value.asMap().entries.map(
                                (column) => SizedBox(
                                  height: 100,
                                  width: 100,
                                  child: ElevatedButton(
                                    style: ButtonStyle(
                                      shape: MaterialStatePropertyAll(
                                          RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            3.0), // Adjust the radius as needed
                                      )),
                                      side: MaterialStatePropertyAll(BorderSide(
                                          width: 1,
                                          color: playerColors[
                                              currentPlayerIndex])),
                                      elevation:
                                          const MaterialStatePropertyAll(0.0),
                                      backgroundColor:
                                          const MaterialStatePropertyAll(
                                              Colors.white),
                                      foregroundColor: MaterialStatePropertyAll(
                                          playerColors[matrix[row.key]
                                                          [column.key]
                                                      .user ==
                                                  -1
                                              ? 0
                                              : matrix[row.key][column.key]
                                                  .user]),
                                    ),
                                    onPressed: (matrix[row.key][column.key]
                                                    .user ==
                                                -1 ||
                                            matrix[row.key][column.key].user ==
                                                currentPlayerIndex)
                                        ? () => handleIndexTap(
                                              row.key,
                                              column.key,
                                            )
                                        : null,
                                    child: const Text(''),
                                  ),
                                ),
                              ),
                        ],
                      ),
                    )
              ],
            ),
            ...dotsList.map(
              (dot) => AnimatedPositioned(
                  key: ValueKey(dot.id),
                  left: dot.x,
                  top: dot.y,
                  duration: const Duration(milliseconds: 500),
                  child: Icon(
                    Icons.circle_sharp,
                    size: 20,
                    color: playerColors[dot.player],
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
