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

  randomizeDots(int row, int column) {
    final cellToRandomize = matrix[row][column];
    final dotsToRandomize = cellToRandomize.dotIds;

    final xDirection = column;
    final yDirection = row;
    final xOffset = xDirection * 100.0 + 40;
    final yOffset = yDirection * 100.0 + 40;

    for (var i = 0; i < dotsToRandomize.length; i++) {
      final offset = getRandomizedDotOffset(i, dotsToRandomize.length);
      final currentDotId = dotsToRandomize[i];
      final currentDotIndex =
          dotsList.indexWhere((element) => element.id == currentDotId);
      dotsList[currentDotIndex].x = xOffset + offset[0];
      dotsList[currentDotIndex].y = yOffset + offset[1];
    }
  }

  handlePendingTasks(List<List<int>> pendingActionCells) {
    final List<List<int>> newPendingItems = [];
    for (var pendingCell in pendingActionCells) {
      final row = pendingCell[0];
      final column = pendingCell[1];
      final currentEditingUser = matrix[row][column].user;
      final possibleMovements = getNumberOfPossibleMovementDirections(
          row, numberOfRows - 1, column, numberOfColumns - 1);
      final numberOfPossibleMovements = possibleMovements.length;
      final numberOfDotsInCell = matrix[row][column].dotIds.length;
      final bool hasExtraDotToHandle =
          numberOfDotsInCell > numberOfPossibleMovements;

      for (int i = 0; i < possibleMovements.length; i++) {
        final possibleMovement = possibleMovements[i];
        final newRow = possibleMovement[0];
        final newColumn = possibleMovement[1];
        final currentCell = matrix[row][column];
        final currentMovingDotId = currentCell.dotIds[i];
        matrix[newRow][newColumn].dotIds = [
          ...matrix[newRow][newColumn].dotIds,
          currentMovingDotId
        ];
        final movingDotIndex =
            dotsList.indexWhere((element) => element.id == currentMovingDotId);
        final xDirection = newColumn;
        final yDirection = newRow;
        final xOffset = xDirection * 100.0 + 40;
        final yOffset = yDirection * 100.0 + 40;
        dotsList[movingDotIndex].x = xOffset;
        dotsList[movingDotIndex].y = yOffset;

        matrix[newRow][newColumn].user = currentEditingUser;
        dotsList[movingDotIndex].player = currentEditingUser;
        final dotsInNewLocation = matrix[newRow][newColumn].dotIds;
        randomizeDots(newRow, newColumn);
        for (var dotId in dotsInNewLocation) {
          final newLocationColleagueDotIndex =
              dotsList.indexWhere((element) => element.id == dotId);
          dotsList[newLocationColleagueDotIndex].player = currentEditingUser;
        }

        if (isCellOverflowing(newRow, newColumn)) {
          final isCellAlreadyAdded = newPendingItems.indexWhere(
              (element) => element[0] == newRow && element[1] == newColumn);
          if (isCellAlreadyAdded == -1) {
            newPendingItems.add([newRow, newColumn]);
          }
        }
      }

      if (hasExtraDotToHandle) {
        final dotsListLength = matrix[row][column].dotIds.length;
        final remainingDotsList =
            matrix[row][column].dotIds.sublist(dotsListLength - 1);
        matrix[row][column].dotIds = remainingDotsList;
        randomizeDots(row, column);
      } else {
        matrix[row][column].dotIds = [];
        matrix[row][column].user = -1;
      }

      setState(() {});
    }
    handleDelayedPendingTasks(newPendingItems, false);
  }

  handleChangePlayerIndex() {
    currentPlayerIndex = (currentPlayerIndex + 1) % players.length;
    setState(() {});
  }

  handleDelayedPendingTasks(List<List<int>> pendingActionCells, bool short) {
    if (pendingActionCells.isNotEmpty) {
      Future.delayed(
        Duration(milliseconds: short ? 100 : 1000),
        () => handlePendingTasks(pendingActionCells),
      );
    } else {
      Future.delayed(
          Duration(milliseconds: short ? 100 : 1000), handleChangePlayerIndex);
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

  handleIndexTap(int row, int column) {
    handleAddDot(row, column);
    if (isCellOverflowing(row, column)) {
      handleDelayedPendingTasks([
        [row, column]
      ], true);
    } else {
      randomizeDots(row, column);
      handleChangePlayerIndex();
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
                  duration: const Duration(milliseconds: 800),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 800),
                    curve: CustomRapidCurve(),
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: playerColors[dot.player],
                      borderRadius: BorderRadius.circular(20),
                    ),
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
