import 'package:flutter/material.dart';

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

final List<List<List<int>>> offsetMap = [
  [
    [0, 0]
  ],
  [
    [0, -10],
    [10, 0]
  ],
  [
    [0, -10],
    [10, 0],
    [-10, 0]
  ],
  [
    [0, -10],
    [10, 0],
    [-10, 0],
    [0, 10]
  ],
  [
    [0, 0],
    [-10, -10],
    [-10, 10],
    [10, -10],
    [10, 10]
  ]
];

class CustomRapidCurve extends Curve {
  @override
  double transform(double t) {
    if (t < 0.8) {
      return 0;
    } else {
      return 1;
    }
  }
}
