import 'package:flutter/material.dart';
import '../widgets/tic_tac_toe.dart';
import '../widgets/memory_game.dart';
import '../widgets/snake_game.dart';
import '../widgets/rock_paper_scissors.dart';

class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key});

  final Color primaryColor = const Color(0xFFF5F7FA);
  final Color secondaryColor = const Color(0xFF2E3A59);
  final Color accentColor = const Color(0xFFE63946);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: secondaryColor,
        title: const Text('Games'),
        foregroundColor: Colors.white,
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(20),
        crossAxisCount: 2,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        children: [
          _GameCard(
            title: 'Tic Tac Toe',
            icon: Icons.grid_3x3,
            color: accentColor,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TicTacToe()),
            ),
          ),
          _GameCard(
            title: 'Memory Game',
            icon: Icons.memory,
            color: Colors.blue,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MemoryGame()),
            ),
          ),
          _GameCard(
            title: 'Snake Game',
            icon: Icons.sports_esports,
            color: Colors.green,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SnakeGame()),
            ),
          ),
          _GameCard(
            title: 'Rock Paper Scissors',
            icon: Icons.gesture,
            color: Colors.purple,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RockPaperScissors()),
            ),
          ),
        ],
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _GameCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.8),
                color,
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 50,
                color: Colors.white,
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 