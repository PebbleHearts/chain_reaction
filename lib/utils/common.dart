List<List<int>> getNumberOfPossibleMovementDirections(int x, int xMax, int y, int yMax) {
  List<List<int>> possibleMovements = [];
  if (!(x == 0)) {
    possibleMovements.add([x-1, y]);
  }
  if (!(x == xMax)) {
    possibleMovements.add([x + 1, y]);
  }

  if (!(y == 0)) {
    possibleMovements.add([x, y - 1]);
  }
  if (!(y == yMax)) {
    possibleMovements.add([x, y + 1]);
  }

  return possibleMovements;
}