import 'dart:io';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

class CelebrationScreen extends StatefulWidget {
  final VoidCallback onFinish;
  final String activityLabel;
  final String activityIcon;
  final String? activityImagePath;

  const CelebrationScreen({
    super.key,
    required this.onFinish,
    required this.activityLabel,
    required this.activityIcon,
    this.activityImagePath,
  });

  @override
  State<CelebrationScreen> createState() => _CelebrationScreenState();
}

class _CelebrationScreenState extends State<CelebrationScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 4));
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6ECFF), // Magical soft purple
      body: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Confetti emitter
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: true,
                colors: const [
                  Colors.green,
                  Colors.blue,
                  Colors.pink,
                  Colors.orange,
                  Colors.purple,
                  Colors.yellow,
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(height: 40),
                  
                  // Star badge & congrats text
                  Column(
                    children: [
                      const Text(
                        '⭐',
                        style: TextStyle(fontSize: 90),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Yay! Great Job!',
                        style: TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'You helped Buddy wave bye-bye!',
                        style: TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: 18,
                          color: const Color(0xFF2C3E50).withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 30),
                      // Selected Activity Display
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            if (widget.activityImagePath != null && widget.activityImagePath!.isNotEmpty)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.file(
                                  File(widget.activityImagePath!),
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Text(
                                    widget.activityIcon,
                                    style: const TextStyle(fontSize: 60),
                                  ),
                                ),
                              )
                            else
                              Text(
                                widget.activityIcon,
                                style: const TextStyle(fontSize: 60),
                              ),
                            const SizedBox(height: 10),
                            Text(
                              'Time for ${widget.activityLabel}!',
                              style: const TextStyle(
                                fontFamily: 'Fredoka',
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF9B59B6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Acknowledge Button
                  SizedBox(
                    width: 200,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        _confettiController.stop();
                        widget.onFinish();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF9B59B6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        elevation: 6,
                      ),
                      child: const Text(
                        'Let\'s Play!',
                        style: TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: 18,
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
          ],
        ),
      ),
    );
  }
}
