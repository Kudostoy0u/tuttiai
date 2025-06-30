import 'package:flutter/material.dart';
import 'dart:async';

class RecordingLibraryScreen extends StatefulWidget {
  const RecordingLibraryScreen({super.key});

  @override
  State<RecordingLibraryScreen> createState() => _RecordingLibraryScreenState();
}

class _RecordingLibraryScreenState extends State<RecordingLibraryScreen> with TickerProviderStateMixin {
  bool _isRecording = false;
  int _recordingSeconds = 0;
  Timer? _recordingTimer;
  
  late AnimationController _waveController;

  final List<Map<String, dynamic>> _recordings = [
    {
      'id': '1',
      'title': 'Scale Practice',
      'duration': '3:24',
      'date': DateTime.now().subtract(const Duration(days: 1)),
    },
    {
      'id': '2',
      'title': 'Beethoven Sonata',
      'duration': '8:15',
      'date': DateTime.now().subtract(const Duration(days: 3)),
    },
  ];

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _waveController.dispose();
    super.dispose();
  }

  void _toggleRecording() {
    setState(() {
      _isRecording = !_isRecording;
    });

    if (_isRecording) {
      _waveController.repeat();
      _recordingSeconds = 0;
      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _recordingSeconds++;
        });
      });
    } else {
      _waveController.stop();
      _recordingTimer?.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Recording Library',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0F0F23),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Recording controls
          Container(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _waveController,
                      builder: (context, child) {
                        return Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _isRecording
                                ? Color.lerp(Colors.red, Colors.red.withOpacity(0.3), _waveController.value)
                                : const Color(0xFF7C3AED),
                          ),
                          child: IconButton(
                            onPressed: _toggleRecording,
                            icon: Icon(
                              _isRecording ? Icons.stop : Icons.mic,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 16),
                    Text(
                      _isRecording ? '${_recordingSeconds}s' : 'Tap to Record',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Recordings list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _recordings.length,
              itemBuilder: (context, index) {
                final recording = _recordings[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFF7C3AED).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.play_arrow, color: Color(0xFF7C3AED)),
                    ),
                    title: Text(
                      recording['title'],
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      '${recording['duration']} • ${recording['date'].day}/${recording['date'].month}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.more_vert, color: Colors.white60),
                      onPressed: () {},
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 