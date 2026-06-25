import 'dart:math' as math;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class SettingsScreen extends StatefulWidget {
  final Color initialColor;
  final double initialDuration;
  final List<Map<String, String>> initialActivities;
  final List<String> recentImages;
  final Function(Color, double, List<Map<String, String>>) onSave;
  final VoidCallback onCancel;

  const SettingsScreen({
    super.key,
    required this.initialColor,
    required this.initialDuration,
    required this.initialActivities,
    required this.recentImages,
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

  Future<void> _pickMedia(int index) async {
    final ImagePicker picker = ImagePicker();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Choose Icon or Photo',
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                // Emoji Gallery
                SizedBox(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _icons.length,
                    itemBuilder: (context, i) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _activities[index]['icon'] = _icons[i];
                            _activities[index]['imagePath'] = '';
                          });
                          Navigator.pop(context);
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2F4FC),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(_icons[i], style: const TextStyle(fontSize: 24)),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                // Recent Images
                if (widget.recentImages.isNotEmpty) ...[
                  const Text(
                    'Recent Photos',
                    style: TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.recentImages.length,
                      itemBuilder: (context, i) {
                        final rPath = widget.recentImages[i];
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _activities[index]['imagePath'] = rPath;
                              _activities[index]['icon'] = '📸'; // placeholder icon
                            });
                            Navigator.pop(context);
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 12),
                            width: 80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.black12),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(File(rPath), fit: BoxFit.cover),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                // Camera & Gallery Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final XFile? photo = await picker.pickImage(source: ImageSource.camera);
                          if (photo != null) _saveLocalImage(index, photo.path);
                          if (mounted) Navigator.pop(context);
                        },
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Take Photo'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                          if (image != null) _saveLocalImage(index, image.path);
                          if (mounted) Navigator.pop(context);
                        },
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Gallery'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _saveLocalImage(int index, String tempPath) async {
    final directory = await getApplicationDocumentsDirectory();
    final String fileName = 'activity_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final String localPath = p.join(directory.path, fileName);
    
    await File(tempPath).copy(localPath);
    
    setState(() {
      _activities[index]['imagePath'] = localPath;
    });
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
        backgroundColor: Colors.black.withValues(alpha: 0.4),
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
          onPressed: () => widget.onSave(_selectedColor, _selectedDuration, _activities),
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
                final isSelected = _selectedColor.toARGB32() == color.toARGB32();
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
              initialValue: _selectedDuration,
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
              final String? imagePath = activity['imagePath'];
              final String icon = activity['icon'] ?? '⭐';

              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => _pickMedia(index),
                      child: Stack(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF2F4FC),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.black12),
                            ),
                            child: (imagePath != null && imagePath.isNotEmpty)
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.file(File(imagePath), fit: BoxFit.cover),
                                  )
                                : Center(child: Text(icon, style: const TextStyle(fontSize: 32))),
                          ),
                          Positioned(
                            right: -2,
                            bottom: -2,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Color(0xFF6A7BFE),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.edit, size: 12, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        initialValue: activity['label'],
                        decoration: InputDecoration(
                          labelText: 'Activity Name',
                          hintText: 'e.g., Read a Book',
                          filled: true,
                          fillColor: const Color(0xFFF2F4FC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        onChanged: (val) => activity['label'] = val,
                      ),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
