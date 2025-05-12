import 'package:flutter/material.dart';
import 'dart:math';

class MemoryGame extends StatefulWidget {
  const MemoryGame({super.key});

  @override
  State<MemoryGame> createState() => _MemoryGameState();
}

class _MemoryGameState extends State<MemoryGame> {
  final List<String> _icons = [
    '🎮', '🎲', '🎯', '🎨', '🎭', '🎪',
    '🎫', '🎬', '🎤', '🎧', '🎸', '🎹',
  ];
  late List<String> _cards;
  late List<bool> _flipped;
  int? _firstCardIndex;
  int _moves = 0;
  int _pairsFound = 0;
  bool _isProcessing = false;

  final Color primaryColor = const Color(0xFFF5F7FA);
  final Color secondaryColor = const Color(0xFF2E3A59);
  final Color accentColor = const Color(0xFFE63946);

  @override
  void initState() {
    super.initState();
    _resetGame();
  }

  void _resetGame() {
    setState(() {
      _cards = [..._icons, ..._icons]..shuffle();
      _flipped = List.filled(_cards.length, false);
      _firstCardIndex = null;
      _moves = 0;
      _pairsFound = 0;
      _isProcessing = false;
    });
  }

  Future<void> _flipCard(int index) async {
    if (_isProcessing || _flipped[index]) return;

    setState(() {
      _flipped[index] = true;
      _moves++;
    });

    if (_firstCardIndex == null) {
      _firstCardIndex = index;
    } else {
      _isProcessing = true;
      if (_cards[_firstCardIndex!] == _cards[index]) {
        _pairsFound++;
        if (_pairsFound == _icons.length) {
          await Future.delayed(const Duration(milliseconds: 500));
          _showWinDialog();
        }
      } else {
        await Future.delayed(const Duration(milliseconds: 1000));
        setState(() {
          _flipped[_firstCardIndex!] = false;
          _flipped[index] = false;
        });
      }
      _firstCardIndex = null;
      _isProcessing = false;
    }
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Congratulations!'),
        content: Text('You won in $_moves moves!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetGame();
            },
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: secondaryColor,
        title: const Text('Memory Game'),
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
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Moves: $_moves',
                  style: TextStyle(
                    fontSize: 18,
                    color: secondaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Pairs: $_pairsFound/${_icons.length}',
                  style: TextStyle(
                    fontSize: 18,
                    color: secondaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _cards.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _flipCard(index),
                  child: Container(
                    decoration: BoxDecoration(
                      color: _flipped[index] ? Colors.white : accentColor,
                      borderRadius: BorderRadius.circular(8),
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
                        _flipped[index] ? _cards[index] : '?',
                        style: TextStyle(
                          fontSize: _flipped[index] ? 32 : 24,
                          color: _flipped[index] ? secondaryColor : Colors.white,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 