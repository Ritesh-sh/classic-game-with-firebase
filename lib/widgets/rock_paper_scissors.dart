import 'package:flutter/material.dart';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RockPaperScissors extends StatefulWidget {
  const RockPaperScissors({super.key});

  @override
  State<RockPaperScissors> createState() => _RockPaperScissorsState();
}

class _RockPaperScissorsState extends State<RockPaperScissors> {
  final Color primaryColor = const Color(0xFFF5F7FA);
  final Color secondaryColor = const Color(0xFF2E3A59);
  final Color accentColor = const Color(0xFFE63946);

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _playerChoice;
  String? _computerChoice;
  String? _result;
  int _playerScore = 0;
  int _computerScore = 0;
  int _draws = 0;

  final List<String> _choices = ['✊', '✋', '✌️'];
  final random = Random();

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final doc = await _firestore.collection('game_stats').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final rps = data['rock_paper_scissors'] as Map<String, dynamic>?;
        if (rps != null) {
          setState(() {
            _playerScore = rps['wins'] ?? 0;
            _computerScore = rps['losses'] ?? 0;
            _draws = rps['draws'] ?? 0;
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading stats: $e');
    }
  }

  Future<void> _saveStats() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore.collection('game_stats').doc(user.uid).set({
        'email': user.email,
        'rock_paper_scissors': {
          'wins': _playerScore,
          'losses': _computerScore,
          'draws': _draws,
          'last_updated': FieldValue.serverTimestamp(),
        },
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error saving stats: $e');
    }
  }

  void _playGame(String playerChoice) {
    setState(() {
      _playerChoice = playerChoice;
      _computerChoice = _choices[random.nextInt(3)];
      _determineWinner();
    });
  }

  void _determineWinner() {
    if (_playerChoice == _computerChoice) {
      _result = 'Draw!';
      _draws++;
    } else if ((_playerChoice == '✊' && _computerChoice == '✌️') ||
        (_playerChoice == '✋' && _computerChoice == '✊') ||
        (_playerChoice == '✌️' && _computerChoice == '✋')) {
      _result = 'You Win!';
      _playerScore++;
    } else {
      _result = 'Computer Wins!';
      _computerScore++;
    }
    _saveStats();
  }

  void _resetGame() {
    setState(() {
      _playerChoice = null;
      _computerChoice = null;
      _result = null;
      _playerScore = 0;
      _computerScore = 0;
      _draws = 0;
    });
    _saveStats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: secondaryColor,
        title: const Text('Rock Paper Scissors'),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetGame,
            tooltip: 'Reset Game',
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Text(
                    'You',
                    style: TextStyle(
                      fontSize: 24,
                      color: secondaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$_playerScore',
                    style: TextStyle(
                      fontSize: 36,
                      color: secondaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    'Computer',
                    style: TextStyle(
                      fontSize: 24,
                      color: secondaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$_computerScore',
                    style: TextStyle(
                      fontSize: 36,
                      color: secondaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 40),
          if (_playerChoice != null && _computerChoice != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  _playerChoice!,
                  style: const TextStyle(fontSize: 60),
                ),
                Text(
                  _computerChoice!,
                  style: const TextStyle(fontSize: 60),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              _result!,
              style: TextStyle(
                fontSize: 32,
                color: _result == 'You Win!'
                    ? Colors.green
                    : _result == 'Computer Wins!'
                        ? accentColor
                        : secondaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _choices.map((choice) {
              return GestureDetector(
                onTap: () => _playGame(choice),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      choice,
                      style: const TextStyle(fontSize: 40),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
} 