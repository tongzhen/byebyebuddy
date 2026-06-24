import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

class CelebrationScreen extends StatefulWidget {
  final VoidCallback onFinish;

  const CelebrationScreen({
    super.key,
    required this.onFinish,
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
                          color: const Color(0xFF2C3E50).withOpacity(0.6),
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
