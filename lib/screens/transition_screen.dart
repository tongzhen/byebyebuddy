import 'dart:math' as math;
import 'dart:io';
import 'package:flutter/material.dart';
import '../widgets/buddy_character.dart';

class TransitionScreen extends StatelessWidget {
  final List<Map<String, String>> activities;
  final Function(Map<String, String>) onSelectActivity;
  final Color characterColor;

  const TransitionScreen({
    super.key,
    required this.activities,
    required this.onSelectActivity,
    required this.characterColor,
  });

  void _pickRandom() {
    if (activities.isEmpty) return;
    final random = math.Random();
    final index = random.nextInt(activities.length);
    final activity = activities[index];
    onSelectActivity(activity);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F8F5), // Soothing pastel mint green
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Column(
            children: [
              // Buddy at the top
              BuddyCharacter(
                state: BuddyState.transition,
                bodyColor: characterColor,
                size: 140, // Slightly smaller to fit grid
              ),
              
              const Column(
                children: [
                  Text(
                    'Time to say bye-bye!',
                    style: TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'What fun thing do we want to do next?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 14,
                      color: Color(0xFF7F8C8D),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Activity Options Grid
              Expanded(
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.15, // Wider cards to fit more height-wise
                  ),
                  itemCount: activities.length + 1, // +1 for "Pick for me"
                  itemBuilder: (context, index) {
                    if (index < activities.length) {
                      final activity = activities[index];
                      return _buildActivityCard(
                        icon: activity['icon']!,
                        label: activity['label']!,
                        imagePath: activity['imagePath'],
                        onTap: () => onSelectActivity(activity),
                      );
                    } else {
                      // The "Pick for me" button
                      return _buildActivityCard(
                        icon: '❓',
                        label: 'Pick for me',
                        imagePath: null,
                        onTap: _pickRandom,
                        isSpecial: true,
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityCard({
    required String icon,
    required String label,
    required String? imagePath,
    required VoidCallback onTap,
    bool isSpecial = false,
  }) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: isSpecial ? const Color(0xFFD5F5E3) : Colors.white,
        elevation: 3,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: isSpecial 
            ? const BorderSide(color: Color(0xFF2ECC71), width: 2) 
            : BorderSide.none,
        ),
        padding: const EdgeInsets.all(6),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (imagePath != null && imagePath.isNotEmpty)
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.file(
                    File(imagePath),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Center(
                      child: Text(icon, style: const TextStyle(fontSize: 32)),
                    ),
                  ),
                ),
              ),
            )
          else
            Expanded(
              child: Center(
                child: Text(
                  icon,
                  style: const TextStyle(fontSize: 40),
                ),
              ),
            ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Fredoka',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isSpecial ? const Color(0xFF27AE60) : const Color(0xFF2C3E50),
            ),
          ),
        ],
      ),
    );
  }
}
