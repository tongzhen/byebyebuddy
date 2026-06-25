import 'package:flutter/material.dart';
import '../widgets/buddy_character.dart';

class TransitionScreen extends StatelessWidget {
  final List<Map<String, String>> activities;
  final Function(String) onSelectActivity;
  final Color characterColor;

  const TransitionScreen({
    super.key,
    required this.activities,
    required this.onSelectActivity,
    required this.characterColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F8F5), // Soothing pastel mint green
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Column(
            children: [
              // Buddy at the top
              const SizedBox(height: 10),
              BuddyCharacter(
                state: BuddyState.transition,
                bodyColor: characterColor,
              ),
              
              const Column(
                children: [
                  Text(
                    'Time to say bye-bye!',
                    style: TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'What fun thing do we want to do next?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 16,
                      color: Color(0xFF7F8C8D),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Activity Options Grid
              Expanded(
                child: GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.1,
                  ),
                  itemCount: activities.length,
                  itemBuilder: (context, index) {
                    final activity = activities[index];
                    return ElevatedButton(
                      onPressed: () => onSelectActivity(activity['label']!),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        elevation: 4,
                        shadowColor: Colors.black.withValues(alpha: 0.05),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.all(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            activity['icon']!,
                            style: const TextStyle(fontSize: 40),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            activity['label']!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'Fredoka',
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
