import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/buddy_character.dart';

class CountdownScreen extends StatefulWidget {
  final double durationMinutes;
  final Color characterColor;
  final VoidCallback onTimeUp;
  final Function(String) onPlaySound;
  final VoidCallback onPause;
  final VoidCallback onResume;

  const CountdownScreen({
    super.key,
    required this.durationMinutes,
    required this.characterColor,
    required this.onTimeUp,
    required this.onPlaySound,
    required this.onPause,
    required this.onResume,
  });

  @override
  State<CountdownScreen> createState() => _CountdownScreenState();
}

class _CountdownScreenState extends State<CountdownScreen> {
  late int _timeLeft; // In seconds
  late int _totalTime; // In seconds
  Timer? _timer;
  bool _isPaused = false;
  BuddyState _buddyState = BuddyState.happy;
  String? _warningMessage;

  @override
  void initState() {
    super.initState();
    _totalTime = (widget.durationMinutes * 60).toInt();
    _timeLeft = _totalTime;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isPaused) return;

      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
          _checkWarnings();
        } else {
          _timer?.cancel();
          _triggerTimesUp();
        }
      });
    });
  }

  void _triggerTimesUp() {
    widget.onPlaySound('timesup');
    setState(() {
      _buddyState = BuddyState.timesUp;
      _warningMessage = '🌟 Time is up! 🌟\nLet\'s choose what\'s next!';
    });

    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        widget.onTimeUp();
      }
    });
  }

  void _checkWarnings() {
    // Dynamic warnings based on timer length:
    final isShort = _totalTime < 360;
    final warn1Time = isShort ? (_totalTime * 0.5).toInt() : 300;
    final warn2Time = isShort ? (_totalTime * 0.2).toInt() : 60;

    if (_timeLeft == warn1Time) {
      _triggerWarning('Almost Done!', 'Buddy waves: Screen time wrapping up soon.');
    } else if (_timeLeft == warn2Time) {
      _triggerWarning('1 Minute Left!', 'Get ready to choose what\'s next.');
    }
  }

  void _triggerWarning(String title, String subtitle) {
    widget.onPlaySound('warning');
    setState(() {
      _buddyState = BuddyState.warning;
      _warningMessage = '$title\n$subtitle';
    });

    // Auto dismiss after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted && _timeLeft > 0) {
        setState(() {
          _buddyState = BuddyState.happy;
          _warningMessage = null;
        });
      }
    });
  }

  void _togglePlayPause() {
    setState(() {
      _isPaused = !_isPaused;
      if (_isPaused) {
        widget.onPause();
      } else {
        widget.onResume();
      }
    });
  }

  void _skipToTransition() {
    _timer?.cancel();
    _triggerTimesUp();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double percent = _timeLeft / _totalTime;
    final minutes = _timeLeft ~/ 60;
    final seconds = _timeLeft % 60;
    final timeStr = '$minutes:${seconds.toString().padLeft(2, '0')}';
    final bool isTimesUp = _buddyState == BuddyState.timesUp;

    return Scaffold(
      backgroundColor: const Color(0xFFEBF7FF), // Calming soft blue
      body: SafeArea(
        child: Stack(
          children: [
            // Main Content
            AnimatedOpacity(
              duration: const Duration(milliseconds: 500),
              opacity: isTimesUp ? 0.0 : 1.0,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Screen Time',
                      style: TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),

                    // Timer Dial wrapping the character
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 250,
                          height: 250,
                          child: CircularProgressIndicator(
                            value: percent,
                            strokeWidth: 10,
                            backgroundColor: Colors.black.withValues(alpha: 0.05),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              percent < 0.2
                                  ? const Color(0xFFE74C3C) // Alert Red
                                  : percent < 0.5
                                      ? const Color(0xFFF39C12) // Alert Orange
                                      : const Color(0xFF6A7BFE), // Cool Blue
                            ),
                          ),
                        ),
                        // Character (Small version)
                        BuddyCharacter(
                          state: _buddyState,
                          bodyColor: widget.characterColor,
                        ),
                      ],
                    ),

                    // Text Timer Countdown
                    Text(
                      timeStr,
                      style: const TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),

                    // Controls Drawer
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: _togglePlayPause,
                          icon: Text(
                            _isPaused ? '▶️' : '⏸️',
                            style: const TextStyle(fontSize: 28),
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.all(16),
                            elevation: 4,
                          ),
                        ),
                        const SizedBox(width: 20),
                        IconButton(
                          onPressed: _skipToTransition,
                          icon: const Text(
                            '⏭️',
                            style: TextStyle(fontSize: 28),
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.all(16),
                            elevation: 4,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Large Animated Buddy for "Time's Up"
            if (isTimesUp)
              Center(
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.5, end: 1.8),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: BuddyCharacter(
                        state: BuddyState.timesUp,
                        bodyColor: widget.characterColor,
                        size: 300, // Scaled by Transform.scale
                      ),
                    );
                  },
                ),
              ),

            // Warning / Time's Up Overlay dialog
            if (_warningMessage != null)
              Align(
                alignment: isTimesUp ? Alignment.center : Alignment.bottomCenter,
                child: Container(
                  margin: EdgeInsets.only(
                    left: 24,
                    right: 24,
                    bottom: isTimesUp ? 0 : 24,
                    top: isTimesUp ? 350 : 0, // Position below large buddy
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isTimesUp ? const Color(0xFF6A7BFE) : const Color(0xFFF39C12), 
                      width: 3
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Text(
                    _warningMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
