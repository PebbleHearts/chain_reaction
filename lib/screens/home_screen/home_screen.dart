import 'package:chain_reaction/components/number_selector.dart';
import 'package:chain_reaction/screens/game_screen/game_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int numberOfPlayers = 2;

  handleIncrement() {
    setState(() {
      numberOfPlayers = numberOfPlayers + 1;
    });
  }

  handleDecrement() {
    setState(() {
      numberOfPlayers = numberOfPlayers - 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Number of Players: '),
              NumberSelector(
                maxPlayers: 8,
                currentPlayersCount: numberOfPlayers,
                handleIncrement: handleIncrement,
                handleDecrement: handleDecrement,
              )
            ],
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => const GameScreen()));
            },
            child: const Text('Start Game'),
          )
        ],
      ),
    );
  }
}
