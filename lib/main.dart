import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import 'screens/home_screen.dart';
import 'screens/countdown_screen.dart';
import 'screens/transition_screen.dart';
import 'screens/celebration_screen.dart';
import 'screens/settings_screen.dart';

void main() {
  runApp(const ByeByeBuddyApp());
}

class ByeByeBuddyApp extends StatelessWidget {
  const ByeByeBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ByeBye Buddy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue,
      ),
      home: const MainRouter(),
    );
  }
}

class MainRouter extends StatefulWidget {
  const MainRouter({super.key});

  @override
  State<MainRouter> createState() => _MainRouterState();
}

class _MainRouterState extends State<MainRouter> with WidgetsBindingObserver {
  final AudioPlayer _audioPlayer = AudioPlayer();
  StreamSubscription? _audioSubscription;
  int _celebrationLoopsLeft = 0;
  Source? _celebrationSource;

  String _currentScreen = 'home';
  String? _selectedActivityLabel;
  String? _selectedActivityIcon;
  String? _selectedActivityImagePath;
  int _stars = 0;
  Color _characterColor = const Color(0xFF5DADE2); // Sky Blue
  double _durationMinutes = 5.0;
  List<String> _recentImages = [];

  List<Map<String, String>> _activities = [
    {'label': 'Read a Book', 'icon': '📚', 'imagePath': ''},
    {'label': 'Play Blocks', 'icon': '🧱', 'imagePath': ''},
    {'label': 'Draw & Color', 'icon': '🎨', 'imagePath': ''},
    {'label': 'Play Outside', 'icon': '🌳', 'imagePath': ''},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadStoredSettings();

    // Handle fixed loop counts (e.g. celebration playing 3 times)
    _audioSubscription = _audioPlayer.onPlayerComplete.listen((event) {
      if (_celebrationLoopsLeft > 0 && _celebrationSource != null) {
        _celebrationLoopsLeft--;
        _audioPlayer.play(_celebrationSource!);
      }
    });
  }

  @override
  void dispose() {
    _audioSubscription?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _stopSound();
    }
  }

  Future<void> _loadStoredSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _stars = prefs.getInt('stars') ?? 0;
      _durationMinutes = prefs.getDouble('duration') ?? 5.0;
      
      final colorVal = prefs.getInt('char_color');
      if (colorVal != null) {
        _characterColor = Color(colorVal);
      }
      
      // Load activities
      for (int i = 0; i < 4; i++) {
        final label = prefs.getString('act_label_$i');
        final icon = prefs.getString('act_icon_$i');
        final imagePath = prefs.getString('act_image_$i') ?? '';
        if (label != null && icon != null) {
          _activities[i] = {
            'label': label,
            'icon': icon,
            'imagePath': imagePath,
          };
        }
      }

      _recentImages = prefs.getStringList('recent_images') ?? [];
    });
  }

  Future<void> _saveSettings(Color color, double duration, List<Map<String, String>> newActs) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('duration', duration);
    await prefs.setInt('char_color', color.toARGB32());
    
    List<String> updatedRecent = List.from(_recentImages);
    for (int i = 0; i < 4; i++) {
      await prefs.setString('act_label_$i', newActs[i]['label']!);
      await prefs.setString('act_icon_$i', newActs[i]['icon']!);
      final path = newActs[i]['imagePath'] ?? '';
      await prefs.setString('act_image_$i', path);
      
      if (path.isNotEmpty && !updatedRecent.contains(path)) {
        updatedRecent.insert(0, path);
      }
    }
    
    // Keep only last 10
    if (updatedRecent.length > 10) {
      updatedRecent = updatedRecent.sublist(0, 10);
    }
    await prefs.setStringList('recent_images', updatedRecent);

    setState(() {
      _characterColor = color;
      _durationMinutes = duration;
      _activities = newActs;
      _recentImages = updatedRecent;
      _currentScreen = 'home';
    });
  }

  Future<void> _incrementStars() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _stars++;
    });
    await prefs.setInt('stars', _stars);
  }

  // Audio helper (plays actual sounds using audioplayers)
  void _playSound(String type) async {
    debugPrint('[AudioService] Play sound: $type');
    try {
      Source? source;
      switch (type) {
        case 'start':
          source = AssetSource('audio/start.mp3');
          break;
        case 'warning':
          source = AssetSource('audio/warning.mp3');
          break;
        case 'timesup':
          source = AssetSource('audio/timesup.mp3');
          break;
        case 'celebration':
          source = AssetSource('audio/celebration.mp3');
          break;
      }

      if (source != null) {
        await _audioPlayer.stop();

        if (type == 'celebration') {
          // Play 1st time + 2 loops = 3 total plays
          _celebrationLoopsLeft = 2;
          _celebrationSource = source;
          await _audioPlayer.setReleaseMode(ReleaseMode.stop);
        } else {
          _celebrationLoopsLeft = 0;
          _celebrationSource = null;
          await _audioPlayer.setReleaseMode(
            (type == 'start' || type == 'timesup') ? ReleaseMode.loop : ReleaseMode.stop,
          );
        }

        await _audioPlayer.play(source);
      }
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
  }

  void _stopSound() {
    _audioPlayer.stop();
  }

  void _pauseSound() {
    _audioPlayer.pause();
  }

  void _resumeSound() {
    _audioPlayer.resume();
  }

  @override
  Widget build(BuildContext context) {
    switch (_currentScreen) {
      case 'home':
        return HomeScreen(
          characterColor: _characterColor,
          starCount: _stars,
          onStart: () {
            _playSound('start');
            setState(() => _currentScreen = 'countdown');
          },
          onOpenSettings: () {
            _stopSound();
            setState(() => _currentScreen = 'settings');
          },
        );
      case 'countdown':
        return CountdownScreen(
          durationMinutes: _durationMinutes,
          characterColor: _characterColor,
          onPlaySound: _playSound,
          onPause: _pauseSound,
          onResume: _resumeSound,
          onTimeUp: () {
            _playSound('timesup');
            setState(() => _currentScreen = 'transition');
          },
        );
      case 'transition':
        return TransitionScreen(
          activities: _activities,
          characterColor: _characterColor,
          onSelectActivity: (activity) async {
            await _incrementStars();
            _playSound('celebration');
            setState(() {
              _selectedActivityLabel = activity['label'];
              _selectedActivityIcon = activity['icon'];
              _selectedActivityImagePath = activity['imagePath'];
              _currentScreen = 'celebration';
            });
          },
        );
      case 'celebration':
        return CelebrationScreen(
          activityLabel: _selectedActivityLabel ?? '',
          activityIcon: _selectedActivityIcon ?? '⭐',
          activityImagePath: _selectedActivityImagePath,
          onFinish: () {
            _stopSound();
            setState(() => _currentScreen = 'home');
          },
        );
      case 'settings':
        return SettingsScreen(
          initialColor: _characterColor,
          initialDuration: _durationMinutes,
          initialActivities: _activities,
          recentImages: _recentImages,
          onCancel: () {
            _stopSound();
            setState(() => _currentScreen = 'home');
          },
          onSave: (color, duration, acts) {
            _stopSound();
            _saveSettings(color, duration, acts);
          },
        );
      default:
        return const Scaffold(body: Center(child: Text('Unknown State')));
    }
  }
}
