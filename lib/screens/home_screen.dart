import 'package:flutter/material.dart';
import '../widgets/buddy_character.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onStart;
  final VoidCallback onOpenSettings;
  final int starCount;
  final Color characterColor;

  const HomeScreen({
    super.key,
    required this.onStart,
    required this.onOpenSettings,
    required this.starCount,
    required this.characterColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4FC), // Warm pastel background
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Text('⭐ ', style: TextStyle(fontSize: 18)),
                        Text(
                          '$starCount',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFF39C12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton.icon(
                    onPressed: onOpenSettings,
                    icon: const Text('⚙️'),
                    label: const Text(
                      'Parents',
                      style: TextStyle(
                        fontFamily: 'Fredoka',
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF7F8C8D),
                      ),
                    ),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 2,
                      shadowColor: Colors.black.withOpacity(0.1),
                    ),
                  ),
                ],
              ),

              // Title and Tagline
              const Column(
                children: [
                  Text(
                    'ByeBye Buddy',
                    style: TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Say bye-bye to screens…\nand hello to something fun.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 16,
                      color: Color(0xFF7F8C8D),
                    ),
                  ),
                ],
              ),

              // Character Mascot
              BuddyCharacter(
                state: BuddyState.happy,
                bodyColor: characterColor,
              ),

              // Start Button
              SizedBox(
                width: 260,
                height: 60,
                child: ElevatedButton(
                  onPressed: onStart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6A7BFE),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 8,
                    shadowColor: const Color(0xFF6A7BFE).withOpacity(0.4),
                  ),
                  child: const Text(
                    'Start Screen Time',
                    style: TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
