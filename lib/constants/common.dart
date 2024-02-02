class CellItem {
  List<String> dotIds;
  int user;

  CellItem(this.dotIds, this.user);

  get dotsCount => dotIds.length;
}

class Dot {
  String id;
  double x;
  double y;
  int player;

  Dot(this.id, this.x, this.y, this.player);
}
