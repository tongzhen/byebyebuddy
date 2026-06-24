import 'package:flutter/material.dart';

enum BuddyState { happy, warning, transition, cheering }

class BuddyCharacter extends StatefulWidget {
  final BuddyState state;
  final Color bodyColor;

  const BuddyCharacter({
    super.key,
    required this.state,
    required this.bodyColor,
  });

  @override
  State<BuddyCharacter> createState() => _BuddyCharacterState();
}

class _BuddyCharacterState extends State<BuddyCharacter>
    with TickerProviderStateMixin {
  late AnimationController _breathingController;
  late AnimationController _blinkingController;
  late AnimationController _wavingController;

  @override
  void initState() {
    super.initState();

    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _blinkingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat();

    _wavingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _blinkingController.dispose();
    _wavingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _breathingController,
        _blinkingController,
        _wavingController,
      ]),
      builder: (context, child) {
        return SizedBox(
          width: 200,
          height: 200,
          child: CustomPaint(
            painter: BuddyPainter(
              state: widget.state,
              bodyColor: widget.bodyColor,
              breathVal: _breathingController.value,
              blinkVal: _blinkingController.value,
              waveVal: _wavingController.value,
            ),
          ),
        );
      },
    );
  }
}

class BuddyPainter extends CustomPainter {
  final BuddyState state;
  final Color bodyColor;
  final double breathVal;
  final double blinkVal;
  final double waveVal;

  BuddyPainter({
    required this.state,
    required this.bodyColor,
    required this.breathVal,
    required this.blinkVal,
    required this.waveVal,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // 1. Draw Feet
    final orangePaint = Paint()..color = const Color(0xFFE67E22);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.32, size.height * 0.8, 25, 15),
        const Radius.circular(8),
      ),
      orangePaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.55, size.height * 0.8, 25, 15),
        const Radius.circular(8),
      ),
      orangePaint,
    );

    // 2. Draw Left & Right Arms
    final bodyPaint = Paint()..color = bodyColor;
    
    // Wave calculations
    double leftArmAngle = 0;
    double rightArmAngle = 0;
    
    if (state == BuddyState.warning) {
      leftArmAngle = -0.4 - (waveVal * 0.5); // wave left arm
    } else if (state == BuddyState.transition) {
      rightArmAngle = 0.4 + (waveVal * 0.5); // wave right arm
    } else if (state == BuddyState.cheering) {
      leftArmAngle = -0.6 + (waveVal * 0.3);
      rightArmAngle = 0.6 - (waveVal * 0.3);
    }

    // Left Arm
    canvas.save();
    canvas.translate(size.width * 0.28, size.height * 0.55);
    canvas.rotate(leftArmAngle);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-20, -10, 25, 20),
        const Radius.circular(10),
      ),
      bodyPaint,
    );
    canvas.restore();

    // Right Arm
    canvas.save();
    canvas.translate(size.width * 0.72, size.height * 0.55);
    canvas.rotate(rightArmAngle);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-5, -10, 25, 20),
        const Radius.circular(10),
      ),
      bodyPaint,
    );
    canvas.restore();

    // 3. Draw Body (with gentle scale breathing)
    canvas.save();
    final scaleY = 1.0 + (breathVal * 0.03);
    canvas.translate(center.dx, size.height * 0.85);
    canvas.scale(2.0 - scaleY, scaleY);
    canvas.translate(-center.dx, -size.height * 0.85);

    // Leaf on Head
    final greenPaint = Paint()..color = const Color(0xFF2ECC71);
    final leafPath = Path()
      ..moveTo(size.width / 2, size.height * 0.25)
      ..quadraticBezierTo(size.width / 2 - 10, size.height * 0.15, size.width / 2, size.height * 0.1)
      ..quadraticBezierTo(size.width / 2 + 10, size.height * 0.15, size.width / 2, size.height * 0.25);
    canvas.drawPath(leafPath, greenPaint);

    // Main Blob
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.24,
          size.height * 0.22,
          size.width * 0.52,
          size.height * 0.6,
        ),
        const Radius.circular(52),
      ),
      bodyPaint,
    );

    // 4. Rosy Cheeks
    final cheekPaint = Paint()
      ..color = const Color(0xFFF08080).withValues(alpha: 0.6);
    canvas.drawCircle(
      Offset(size.width * 0.35, size.height * 0.58),
      10,
      cheekPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.65, size.height * 0.58),
      10,
      cheekPaint,
    );

    // 5. Draw Eyes (Blinking behavior)
    final eyePaint = Paint()..color = Colors.white;
    final pupilPaint = Paint()..color = const Color(0xFF2C3E50);
    
    // Eyeballs
    double eyeHeightScale = 1.0;
    // Blink every 4 seconds (blinkVal goes from 0.0 to 1.0)
    if (blinkVal > 0.92) {
      eyeHeightScale = (1.0 - ((blinkVal - 0.92) / 0.08)).clamp(0.1, 1.0);
    }

    // Left Eye
    canvas.save();
    canvas.translate(size.width * 0.4, size.height * 0.45);
    canvas.scale(1.0, eyeHeightScale);
    canvas.drawCircle(Offset.zero, 12, eyePaint);
    canvas.drawCircle(const Offset(2, 2), 7, pupilPaint);
    canvas.drawCircle(const Offset(0, -1), 2.5, eyePaint);
    canvas.restore();

    // Right Eye
    canvas.save();
    canvas.translate(size.width * 0.6, size.height * 0.45);
    canvas.scale(1.0, eyeHeightScale);
    canvas.drawCircle(Offset.zero, 12, eyePaint);
    canvas.drawCircle(const Offset(-2, 2), 7, pupilPaint);
    canvas.drawCircle(const Offset(-2, -1), 2.5, eyePaint);
    canvas.restore();

    // Eyebrows
    final browPaint = Paint()
      ..color = const Color(0xFF2C3E50)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final leftBrow = Path();
    final rightBrow = Path();

    if (state == BuddyState.warning) {
      // Slightly concerned brows
      leftBrow.moveTo(size.width * 0.36, size.height * 0.39);
      leftBrow.quadraticBezierTo(size.width * 0.41, size.height * 0.37, size.width * 0.45, size.height * 0.38);
      rightBrow.moveTo(size.width * 0.55, size.height * 0.38);
      rightBrow.quadraticBezierTo(size.width * 0.59, size.height * 0.37, size.width * 0.64, size.height * 0.39);
    } else {
      // Happy eyebrows
      leftBrow.moveTo(size.width * 0.36, size.height * 0.37);
      leftBrow.quadraticBezierTo(size.width * 0.41, size.height * 0.35, size.width * 0.45, size.height * 0.37);
      rightBrow.moveTo(size.width * 0.55, size.height * 0.37);
      rightBrow.quadraticBezierTo(size.width * 0.59, size.height * 0.35, size.width * 0.64, size.height * 0.37);
    }
    canvas.drawPath(leftBrow, browPaint);
    canvas.drawPath(rightBrow, browPaint);

    // 6. Mouth drawing depending on State
    final mouthPaint = Paint()
      ..color = const Color(0xFF2C3E50)
      ..strokeWidth = 4.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final mouthPath = Path();
    if (state == BuddyState.cheering) {
      // Wide open smile (filled)
      final cheerMouthPaint = Paint()
        ..color = const Color(0xFF2C3E50)
        ..style = PaintingStyle.fill;
      mouthPath.moveTo(size.width * 0.44, size.height * 0.58);
      mouthPath.quadraticBezierTo(size.width * 0.5, size.height * 0.68, size.width * 0.56, size.height * 0.58);
      mouthPath.close();
      canvas.drawPath(mouthPath, cheerMouthPaint);
    } else if (state == BuddyState.warning) {
      // Concerned straight line
      mouthPath.moveTo(size.width * 0.46, size.height * 0.6);
      mouthPath.lineTo(size.width * 0.54, size.height * 0.6);
      canvas.drawPath(mouthPath, mouthPaint);
    } else {
      // Normal happy smile
      mouthPath.moveTo(size.width * 0.45, size.height * 0.59);
      mouthPath.quadraticBezierTo(size.width * 0.5, size.height * 0.66, size.width * 0.55, size.height * 0.59);
      canvas.drawPath(mouthPath, mouthPaint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
