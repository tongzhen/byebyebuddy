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

class _MainRouterState extends State<MainRouter> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  String _currentScreen = 'home';
  int _stars = 0;
  Color _characterColor = const Color(0xFF5DADE2); // Sky Blue
  double _durationMinutes = 5.0;

  List<Map<String, String>> _activities = [
    {'label': 'Read a Book', 'icon': '📚'},
    {'label': 'Play Blocks', 'icon': '🧱'},
    {'label': 'Draw & Color', 'icon': '🎨'},
    {'label': 'Play Outside', 'icon': '🌳'},
  ];

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
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
        if (label != null && icon != null) {
          _activities[i] = {'label': label, 'icon': icon};
        }
      }
    });
  }

  Future<void> _saveSettings(Color color, double duration, List<Map<String, String>> newActs) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('duration', duration);
    await prefs.setInt('char_color', color.toARGB32());
    
    for (int i = 0; i < 4; i++) {
      await prefs.setString('act_label_$i', newActs[i]['label']!);
      await prefs.setString('act_icon_$i', newActs[i]['icon']!);
    }

    setState(() {
      _characterColor = color;
      _durationMinutes = duration;
      _activities = newActs;
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
        await _audioPlayer.play(source);
      }
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
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
            setState(() => _currentScreen = 'settings');
          },
        );
      case 'countdown':
        return CountdownScreen(
          durationMinutes: _durationMinutes,
          characterColor: _characterColor,
          onPlaySound: _playSound,
          onTimeUp: () {
            _playSound('timesup');
            setState(() => _currentScreen = 'transition');
          },
        );
      case 'transition':
        return TransitionScreen(
          activities: _activities,
          onSelectActivity: (label) async {
            await _incrementStars();
            _playSound('celebration');
            setState(() => _currentScreen = 'celebration');
          },
        );
      case 'celebration':
        return CelebrationScreen(
          onFinish: () {
            setState(() => _currentScreen = 'home');
          },
        );
      case 'settings':
        return SettingsScreen(
          initialColor: _characterColor,
          initialDuration: _durationMinutes,
          initialActivities: _activities,
          onCancel: () {
            setState(() => _currentScreen = 'home');
          },
          onSave: (color, duration, acts) {
            _saveSettings(color, duration, acts);
          },
        );
      default:
        return const Scaffold(body: Center(child: Text('Unknown State')));
    }
  }
}
