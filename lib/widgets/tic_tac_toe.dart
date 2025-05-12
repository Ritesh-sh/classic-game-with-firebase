import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TicTacToe extends StatefulWidget {
  const TicTacToe({super.key});

  @override
  State<TicTacToe> createState() => _TicTacToeState();
}

class _TicTacToeState extends State<TicTacToe> {
  late List<List<String>> _board;
  bool _isXTurn = true;
  String? _winner;
  bool _isGameOver = false;
  int _xWins = 0;
  int _oWins = 0;
  int _draws = 0;

  final Color primaryColor = const Color(0xFFF5F7FA); // 60%
  final Color secondaryColor = const Color(0xFF2E3A59); // 30%
  final Color accentColor = const Color(0xFFE63946); // 10%

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _resetGame();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final doc = await _firestore.collection('game_stats').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final ticTacToe = data['tic_tac_toe'] as Map<String, dynamic>?;
        if (ticTacToe != null) {
          setState(() {
            _xWins = ticTacToe['x_wins'] ?? 0;
            _oWins = ticTacToe['o_wins'] ?? 0;
            _draws = ticTacToe['draws'] ?? 0;
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
        'tic_tac_toe': {
          'x_wins': _xWins,
          'o_wins': _oWins,
          'draws': _draws,
          'last_updated': FieldValue.serverTimestamp(),
        },
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error saving stats: $e');
    }
  }

  void _resetGame() {
    setState(() {
      _board = List.generate(3, (_) => List.filled(3, ''));
      _isXTurn = true;
      _winner = null;
      _isGameOver = false;
    });
  }

  void _makeMove(int row, int col) {
    if (_board[row][col].isEmpty && !_isGameOver) {
      setState(() {
        _board[row][col] = _isXTurn ? 'X' : 'O';
        _isXTurn = !_isXTurn;
        _checkWinner();
      });
    }
  }

  void _checkWinner() {
    for (int i = 0; i < 3; i++) {
      if (_board[i][0].isNotEmpty &&
          _board[i][0] == _board[i][1] &&
          _board[i][1] == _board[i][2]) {
        _winner = _board[i][0];
        _isGameOver = true;
        _updateStats();
        return;
      }
      if (_board[0][i].isNotEmpty &&
          _board[0][i] == _board[1][i] &&
          _board[1][i] == _board[2][i]) {
        _winner = _board[0][i];
        _isGameOver = true;
        _updateStats();
        return;
      }
    }

    if (_board[0][0].isNotEmpty &&
        _board[0][0] == _board[1][1] &&
        _board[1][1] == _board[2][2]) {
      _winner = _board[0][0];
      _isGameOver = true;
      _updateStats();
      return;
    }
    if (_board[0][2].isNotEmpty &&
        _board[0][2] == _board[1][1] &&
        _board[1][1] == _board[2][0]) {
      _winner = _board[0][2];
      _isGameOver = true;
      _updateStats();
      return;
    }

    if (_board.every((row) => row.every((cell) => cell.isNotEmpty))) {
      _isGameOver = true;
      _updateStats();
    }
  }

  void _updateStats() {
    if (_winner == 'X') {
      _xWins++;
    } else if (_winner == 'O') {
      _oWins++;
    } else {
      _draws++;
    }
    _saveStats();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          _isGameOver
              ? _winner != null
                  ? '🎉 Player $_winner wins!'
                  : 'It\'s a draw!'
              : 'Current turn: ${_isXTurn ? 'X' : 'O'}',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: secondaryColor,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Stats: X: $_xWins | O: $_oWins | Draws: $_draws',
          style: TextStyle(
            fontSize: 16,
            color: secondaryColor.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: Container(
            decoration: BoxDecoration(
              color: primaryColor,
              border: Border.all(color: secondaryColor, width: 3),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (row) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (col) {
                    return GestureDetector(
                      onTap: () => _makeMove(row, col),
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          border: Border.all(color: secondaryColor, width: 1.5),
                        ),
                        child: Center(
                          child: Text(
                            _board[row][col],
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color:
                                  _board[row][col] == 'X'
                                      ? secondaryColor
                                      : accentColor,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                );
              }),
            ),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: _resetGame,
          style: ElevatedButton.styleFrom(
            backgroundColor: accentColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          icon: const Icon(Icons.refresh),
          label: const Text('Reset Game', style: TextStyle(fontSize: 16)),
        ),
      ],
    );
  }
}
