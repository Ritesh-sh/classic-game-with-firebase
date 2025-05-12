import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseScreen extends StatefulWidget {
  const DatabaseScreen({super.key});

  @override
  State<DatabaseScreen> createState() => _DatabaseScreenState();
}

class _DatabaseScreenState extends State<DatabaseScreen> {
  final Color primaryColor = const Color(0xFFF5F7FA);
  final Color secondaryColor = const Color(0xFF2E3A59);
  final Color accentColor = const Color(0xFFE63946);

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference _gameStats = FirebaseFirestore.instance.collection('game_stats');

  Future<void> _deleteGameStats() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _gameStats.doc(user.uid).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Game stats deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting game stats: $e')),
      );
    }
  }

  Widget _buildGameStatsList() {
    final user = _auth.currentUser;
    if (user == null) {
      return const Center(
        child: Text('Please sign in to view your game stats'),
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: _gameStats.doc(user.uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: TextStyle(color: accentColor),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(
            child: Text('No game stats found. Play some games to see your stats!'),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          data['email'] ?? 'Your Stats',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: secondaryColor,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: accentColor),
                          onPressed: _deleteGameStats,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (data['tic_tac_toe'] != null) ...[
                      Text(
                        'Tic Tac Toe:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: secondaryColor.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'X Wins: ${data['tic_tac_toe']['x_wins'] ?? 0}',
                        style: TextStyle(color: secondaryColor),
                      ),
                      Text(
                        'O Wins: ${data['tic_tac_toe']['o_wins'] ?? 0}',
                        style: TextStyle(color: secondaryColor),
                      ),
                      Text(
                        'Draws: ${data['tic_tac_toe']['draws'] ?? 0}',
                        style: TextStyle(color: secondaryColor),
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (data['rock_paper_scissors'] != null) ...[
                      Text(
                        'Rock Paper Scissors:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: secondaryColor.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Wins: ${data['rock_paper_scissors']['wins'] ?? 0}',
                        style: TextStyle(color: secondaryColor),
                      ),
                      Text(
                        'Losses: ${data['rock_paper_scissors']['losses'] ?? 0}',
                        style: TextStyle(color: secondaryColor),
                      ),
                      Text(
                        'Draws: ${data['rock_paper_scissors']['draws'] ?? 0}',
                        style: TextStyle(color: secondaryColor),
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (data['snake_game'] != null) ...[
                      Text(
                        'Snake Game:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: secondaryColor.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Highest Score: ${data['snake_game']['highest_score'] ?? 0}',
                        style: TextStyle(color: secondaryColor),
                      ),
                      Text(
                        'Games Played: ${data['snake_game']['games_played'] ?? 0}',
                        style: TextStyle(color: secondaryColor),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: secondaryColor,
        title: const Text('Game Stats'),
        foregroundColor: Colors.white,
      ),
      body: _buildGameStatsList(),
    );
  }
} 