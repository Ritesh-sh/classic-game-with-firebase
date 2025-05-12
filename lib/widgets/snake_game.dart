import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SnakeGame extends StatefulWidget {
  const SnakeGame({super.key});

  @override
  State<SnakeGame> createState() => _SnakeGameState();
}

class _SnakeGameState extends State<SnakeGame> {
  static const int _gridSize = 20;
  static const int _cellSize = 20;
  static const int _gameSpeed = 150;

  final Color primaryColor = const Color(0xFFF5F7FA);
  final Color secondaryColor = const Color(0xFF2E3A59);
  final Color accentColor = const Color(0xFFE63946);

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late List<Point<int>> _snake;
  late Point<int> _food;
  late Direction _direction;
  late Timer _timer;
  bool _isGameOver = false;
  int _score = 0;
  int _highestScore = 0;
  int _gamesPlayed = 0;

  @override
  void initState() {
    super.initState();
    _startGame();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final doc = await _firestore.collection('game_stats').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final snakeGame = data['snake_game'] as Map<String, dynamic>?;
        if (snakeGame != null) {
          setState(() {
            _highestScore = snakeGame['highest_score'] ?? 0;
            _gamesPlayed = snakeGame['games_played'] ?? 0;
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
        'snake_game': {
          'highest_score': _highestScore,
          'games_played': _gamesPlayed,
          'last_updated': FieldValue.serverTimestamp(),
        },
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error saving stats: $e');
    }
  }

  void _startGame() {
    setState(() {
      _snake = [Point(_gridSize ~/ 2, _gridSize ~/ 2)];
      _direction = Direction.right;
      _isGameOver = false;
      _score = 0;
      _generateFood();
    });
    _timer = Timer.periodic(
      const Duration(milliseconds: _gameSpeed),
      (_) => _moveSnake(),
    );
  }

  void _generateFood() {
    final random = Random();
    Point<int> newFood;
    do {
      newFood = Point(
        random.nextInt(_gridSize),
        random.nextInt(_gridSize),
      );
    } while (_snake.contains(newFood));
    _food = newFood;
  }

  void _moveSnake() {
    if (_isGameOver) return;

    setState(() {
      final head = _snake.first;
      Point<int> newHead;

      switch (_direction) {
        case Direction.up:
          newHead = Point(head.x, head.y - 1);
          break;
        case Direction.down:
          newHead = Point(head.x, head.y + 1);
          break;
        case Direction.left:
          newHead = Point(head.x - 1, head.y);
          break;
        case Direction.right:
          newHead = Point(head.x + 1, head.y);
          break;
      }

      if (_isCollision(newHead)) {
        _gameOver();
        return;
      }

      _snake.insert(0, newHead);

      if (newHead == _food) {
        _score++;
        if (_score > _highestScore) {
          _highestScore = _score;
        }
        _generateFood();
      } else {
        _snake.removeLast();
      }
    });
  }

  bool _isCollision(Point<int> point) {
    return point.x < 0 ||
        point.x >= _gridSize ||
        point.y < 0 ||
        point.y >= _gridSize ||
        _snake.contains(point);
  }

  void _gameOver() {
    setState(() {
      _isGameOver = true;
      _gamesPlayed++;
    });
    _timer.cancel();
    _saveStats();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Game Over'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Score: $_score'),
            const SizedBox(height: 8),
            Text(
              'Highest Score: $_highestScore',
              style: TextStyle(
                fontSize: 16,
                color: secondaryColor.withOpacity(0.8),
              ),
            ),
            Text(
              'Games Played: $_gamesPlayed',
              style: TextStyle(
                fontSize: 16,
                color: secondaryColor.withOpacity(0.8),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _startGame();
            },
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: secondaryColor,
        title: const Text('Snake Game'),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _startGame,
            tooltip: 'Restart Game',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'Score: $_score',
                  style: TextStyle(
                    fontSize: 24,
                    color: secondaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Highest Score: $_highestScore',
                  style: TextStyle(
                    fontSize: 16,
                    color: secondaryColor.withOpacity(0.8),
                  ),
                ),
                Text(
                  'Games Played: $_gamesPlayed',
                  style: TextStyle(
                    fontSize: 16,
                    color: secondaryColor.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Container(
                width: _gridSize * _cellSize.toDouble(),
                height: _gridSize * _cellSize.toDouble(),
                decoration: BoxDecoration(
                  border: Border.all(color: secondaryColor, width: 2),
                ),
                child: Stack(
                  children: [
                    // Food
                    Positioned(
                      left: _food.x * _cellSize.toDouble(),
                      top: _food.y * _cellSize.toDouble(),
                      child: Container(
                        width: _cellSize.toDouble(),
                        height: _cellSize.toDouble(),
                        color: accentColor,
                      ),
                    ),
                    // Snake
                    ..._snake.map((point) => Positioned(
                          left: point.x * _cellSize.toDouble(),
                          top: point.y * _cellSize.toDouble(),
                          child: Container(
                            width: _cellSize.toDouble(),
                            height: _cellSize.toDouble(),
                            color: secondaryColor,
                          ),
                        )),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildDirectionButton(Icons.arrow_upward, Direction.up),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildDirectionButton(Icons.arrow_back, Direction.left),
                    const SizedBox(width: 50),
                    _buildDirectionButton(Icons.arrow_forward, Direction.right),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildDirectionButton(Icons.arrow_downward, Direction.down),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDirectionButton(IconData icon, Direction direction) {
    return IconButton(
      icon: Icon(icon),
      onPressed: () {
        if (!_isOppositeDirection(direction)) {
          setState(() {
            _direction = direction;
          });
        }
      },
      color: secondaryColor,
      iconSize: 40,
    );
  }

  bool _isOppositeDirection(Direction newDirection) {
    return (_direction == Direction.up && newDirection == Direction.down) ||
        (_direction == Direction.down && newDirection == Direction.up) ||
        (_direction == Direction.left && newDirection == Direction.right) ||
        (_direction == Direction.right && newDirection == Direction.left);
  }
}

enum Direction { up, down, left, right } 