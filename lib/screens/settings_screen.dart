import 'dart:math' as math;
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  final Color initialColor;
  final double initialDuration;
  final List<Map<String, String>> initialActivities;
  final Function(Color, double, List<Map<String, String>>) onSave;
  final VoidCallback onCancel;

  const SettingsScreen({
    super.key,
    required this.initialColor,
    required this.initialDuration,
    required this.initialActivities,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _gateUnlocked = false;
  late int _gateNum1;
  late int _gateNum2;
  late int _gateAnswer;
  final TextEditingController _gateController = TextEditingController();
  String? _errorMessage;

  // Actual Form controllers
  late double _selectedDuration;
  late Color _selectedColor;
  late List<Map<String, String>> _activities;

  final List<Color> _colors = const [
    Color(0xFF5DADE2), // Sky Blue
    Color(0xFF58D68D), // Mint Green
    Color(0xFFEC7063), // Coral Red
    Color(0xFFF4D03F), // Sunny Yellow
    Color(0xFFA569BD), // Purple
  ];

  final List<String> _icons = const ['📚', '🧱', '🎨', '🌳', '🍎', '🧩', '🏃', '🧸'];

  @override
  void initState() {
    super.initState();
    _selectedDuration = widget.initialDuration;
    _selectedColor = widget.initialColor;
    // deep copy
    _activities = widget.initialActivities.map((e) => Map<String, String>.from(e)).toList();
    _generateGatePuzzle();
  }

  void _generateGatePuzzle() {
    final rand = math.Random();
    _gateNum1 = rand.nextInt(5) + 3; // 3 to 7
    _gateNum2 = rand.nextInt(4) + 2; // 2 to 5
    _gateAnswer = _gateNum1 + _gateNum2;
  }

  void _verifyGate() {
    final val = int.tryParse(_gateController.text);
    if (val == _gateAnswer) {
      setState(() {
        _gateUnlocked = true;
      });
    } else {
      setState(() {
        _errorMessage = 'Oops! Try again.';
      });
    }
  }

  @override
  void dispose() {
    _gateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_gateUnlocked) {
      return Scaffold(
        backgroundColor: Colors.black.withOpacity(0.4),
        body: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Parents Only',
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Solve this math puzzle to access settings:',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 14,
                    color: Color(0xFF7F8C8D),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F4FC),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '$_gateNum1 + $_gateNum2 = ?',
                    style: const TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6A7BFE),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _gateController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    hintText: 'Answer',
                    errorText: _errorMessage,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: widget.onCancel,
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _verifyGate,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6A7BFE),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text('Unlock', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Parent Settings', style: TextStyle(fontFamily: 'Fredoka', fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF2C3E50),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onCancel,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Buddy\'s Color',
              style: TextStyle(fontFamily: 'Fredoka', fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _colors.map((color) {
                final isSelected = _selectedColor.value == color.value;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = color),
                  child: CircleAvatar(
                    backgroundColor: color,
                    radius: 20,
                    child: isSelected ? const Icon(Icons.check, color: Colors.white) : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            const Text(
              'Screen Time Duration',
              style: TextStyle(fontFamily: 'Fredoka', fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<double>(
              value: _selectedDuration,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
              items: const [
                DropdownMenuItem(value: 0.5, child: Text('30 Seconds (For Testing)')),
                DropdownMenuItem(value: 1.0, child: Text('1 Minute')),
                DropdownMenuItem(value: 5.0, child: Text('5 Minutes')),
                DropdownMenuItem(value: 15.0, child: Text('15 Minutes')),
                DropdownMenuItem(value: 30.0, child: Text('30 Minutes')),
                DropdownMenuItem(value: 60.0, child: Text('60 Minutes')),
              ],
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedDuration = val);
                }
              },
            ),
            const SizedBox(height: 24),

            const Text(
              'Next Activities',
              style: TextStyle(fontFamily: 'Fredoka', fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ...List.generate(4, (index) {
              final activity = _activities[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  children: [
                    DropdownButton<String>(
                      value: activity['icon'],
                      items: _icons.map((icon) {
                        return DropdownMenuItem(value: icon, child: Text(icon, style: const TextStyle(fontSize: 24)));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => activity['icon'] = val);
                        }
                      },
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        initialValue: activity['label'],
                        decoration: InputDecoration(
                          hintText: 'Activity Name',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onChanged: (val) => activity['label'] = val,
                      ),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => widget.onSave(_selectedColor, _selectedDuration, _activities),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6A7BFE),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Save Settings', style: TextStyle(color: Colors.white, fontFamily: 'Fredoka', fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
