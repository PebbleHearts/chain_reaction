import 'package:flutter/material.dart';

class NumberSelector extends StatelessWidget {
  final int maxPlayers;
  final int currentPlayersCount;
  final VoidCallback handleIncrement;
  final VoidCallback handleDecrement;
  const NumberSelector({
    super.key,
    required this.maxPlayers,
    required this.currentPlayersCount,
    required this.handleIncrement,
    required this.handleDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          height: 30,
          width: 40,
          child: ElevatedButton(
            style: ButtonStyle(
              padding: const MaterialStatePropertyAll(EdgeInsets.zero),
              shape: MaterialStatePropertyAll(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
            onPressed: currentPlayersCount > 2 ? handleDecrement : null,
            child: const Icon(
              Icons.add,
              size: 10,
            ),
          ),
        ),
        const SizedBox(
          width: 5,
        ),
        Text('$currentPlayersCount'),
        const SizedBox(
          width: 5,
        ),
        SizedBox(
          height: 30,
          width: 40,
          child: ElevatedButton(
            style: ButtonStyle(
              padding: const MaterialStatePropertyAll(EdgeInsets.zero),
              shape: MaterialStatePropertyAll(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
            onPressed:
                currentPlayersCount < maxPlayers ? handleIncrement : null,
            child: const Icon(Icons.add, size: 10),
          ),
        )
      ],
    );
  }
}
