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
  bool move = false;
  List<List<CellItem>> matrix = [];
  List<CellItem> flattenedList = [];

  @override
  void initState() {
    matrix = List<List<CellItem>>.generate(
      numberOfRows,
      (x) =>
          List<CellItem>.generate(numberOfColumns, (y) => CellItem(0, -1), growable: false),
      growable: false);
    super.initState();
  }

  handleMovement(List<List<int>> actionCells) {
    final List<List<int>> newPendingItems = [];
    for (var cell in actionCells) {
      final x = cell[0];
      final y = cell[1];
      final currentCellItem = matrix[x][y];
      final possibleMovementDirections =
          getNumberOfPossibleMovementDirections(x, numberOfRows - 1, y, numberOfColumns - 1);
      if (currentCellItem.count >= possibleMovementDirections.length) {
        for (var element in possibleMovementDirections) {
          matrix[element[0]][element[1]].count++;
          matrix[element[0]][element[1]].user = currentPlayerIndex;
          final numberOfMovement = getNumberOfPossibleMovementDirections(
                  element[0], numberOfRows - 1, element[1], numberOfColumns - 1)
              .length;
          if ((matrix[element[0]][element[1]].count) >= numberOfMovement) {
            newPendingItems.add(element);
          }
        }
        matrix[x][y].count = 0;
        matrix[x][y].user = -1;
      }
      setState(() {});
    }
    // print('new pending actions: ${newPendingItems}');
    if (newPendingItems.isNotEmpty) {
      Future.delayed(
        const Duration(seconds: 1),
        () => handleMovement(newPendingItems),
      );
    } else {
      currentPlayerIndex = (currentPlayerIndex + 1) % players.length;
      print('currentPlayerIndex $currentPlayerIndex');
      setState(() {});
    }
  }

  handleIndexTap(int x, int y) {
    final List<List<int>> newPendingItems = [];
    final currentCellItem = matrix[x][y];
    if (currentCellItem.user == -1 ||
        currentCellItem.user == currentPlayerIndex) {
      matrix[x][y].count++;
      matrix[x][y].user = currentPlayerIndex;
      setState(() {});
      final numberOfMovement = getNumberOfPossibleMovementDirections(
        x,
        numberOfRows - 1,
        y,
        numberOfColumns - 1,
      ).length;
      if ((matrix[x][y].count) >= numberOfMovement) {
        newPendingItems.add([x, y]);
      }

      if (newPendingItems.isNotEmpty) {
        Future.delayed(
          const Duration(seconds: 1),
          () => handleMovement(newPendingItems),
        );
      } else {
        currentPlayerIndex = (currentPlayerIndex + 1) % players.length;
        setState(() {});
      }
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
                                      side: MaterialStatePropertyAll(BorderSide(
                                          width: 1,
                                          color: playerColors[currentPlayerIndex])),
                                      elevation:
                                          const MaterialStatePropertyAll(0.0),
                                      backgroundColor:
                                          const MaterialStatePropertyAll(
                                              Colors.white),
                                      foregroundColor: MaterialStatePropertyAll(
                                          playerColors[
                                              matrix[row.key][column.key].user == -1
                                                  ? 0
                                                  : matrix[row.key][column.key]
                                                      .user]),
                                    ),
                                    onPressed:
                                        (matrix[row.key][column.key].user == -1 ||
                                                matrix[row.key][column.key].user ==
                                                    currentPlayerIndex)
                                            ? () => handleIndexTap(
                                                  row.key,
                                                  column.key,
                                                )
                                            : null,
                                    child: Text(''),
                                    // child: Row(
                                    //   mainAxisAlignment: MainAxisAlignment.center,
                                    //   children: [
                                    //     ...List.generate(
                                    //             column.value.count,
                                    //             (index) => const SizedBox(
                                    //                 width: 20,
                                    //                 height: 20,
                                    //                 child:
                                    //                     Icon(Icons.circle_sharp)))
                                    //         .toList()
                                    //   ],
                                    // ),
                                  ),
                                ),
                              ),
                        ],
                      ),
                    )
              ],
            ),
            // AnimatedPositioned(child: Text('ss'), left: move ? 80 : 40, top: 40, duration: Duration(milliseconds: 2000)),
            // ElevatedButton(onPressed: () {
            //   setState(() {
            //     move = !move;
            //   });
            // }, child: Text('click'))
          ],
        ),
      ),
    );
  }
}
