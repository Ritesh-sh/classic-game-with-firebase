import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/tic_tac_toe.dart';
import 'games_screen.dart';
import 'database_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  final Color primaryColor = const Color(0xFFF5F7FA);
  final Color secondaryColor = const Color(0xFF2E3A59);
  final Color accentColor = const Color(0xFFE63946);

  Future<void> _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: secondaryColor,
        title: const Text('Home'),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _signOut(context),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          children: [
            Text(
              'Welcome,',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w600,
                color: secondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              user?.email ?? 'User',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w400,
                color: secondaryColor.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Text(
              'Choose a game to play!',
              style: TextStyle(fontSize: 18, color: secondaryColor),
            ),
            const SizedBox(height: 20),
            const Divider(thickness: 1.2),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GamesScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.games),
              label: const Text(
                'View All Games',
                style: TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 20),
            const Divider(thickness: 1.2),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DatabaseScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: secondaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.storage),
              label: const Text(
                'Database Operations',
                style: TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 20),
            const Divider(thickness: 1.2),
            const SizedBox(height: 20),
            const Text(
              'Quick Play:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const TicTacToe(),
          ],
        ),
      ),
    );
  }
}
