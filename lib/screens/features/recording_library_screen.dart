import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:io';
import 'dart:convert';

enum RecordState { stop, record, pause }

class RecordingLibraryScreen extends StatefulWidget {
  const RecordingLibraryScreen({super.key});

  @override
  State<RecordingLibraryScreen> createState() => _RecordingLibraryScreenState();
}

class _RecordingLibraryScreenState extends State<RecordingLibraryScreen> with TickerProviderStateMixin {
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();
  
  RecordState _recordState = RecordState.stop;
  Duration _recordDuration = Duration.zero;
  Timer? _timer;
  String? _currentRecordingPath;
  
  // Waveform visualization
  late AnimationController _waveController;
  final List<double> _amplitudeHistory = List.generate(50, (_) => 0.0);
  StreamSubscription<Amplitude>? _amplitudeSub;
  
  List<RecordingItem> _recordings = [];
  RecordingItem? _playingItem;
  
  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    
    _loadRecordings();
    _checkPermissions();
    
    // Listen to player state changes
    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        setState(() => _playingItem = null);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _amplitudeSub?.cancel();
    _recorder.dispose();
    _player.dispose();
    _waveController.dispose();
    super.dispose();
  }

  Future<void> _checkPermissions() async {
    if (!await _recorder.hasPermission()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Microphone permission required')),
      );
    }
  }

  Future<void> _loadRecordings() async {
    final prefs = await SharedPreferences.getInstance();
    final recordingsJson = prefs.getStringList('recordings') ?? [];
    
    setState(() {
      _recordings = recordingsJson
          .map((json) => RecordingItem.fromJson(jsonDecode(json)))
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
    });
  }

  Future<void> _saveRecordings() async {
    final prefs = await SharedPreferences.getInstance();
    final recordingsJson = _recordings
        .map((r) => jsonEncode(r.toJson()))
        .toList();
    await prefs.setStringList('recordings', recordingsJson);
  }

  Future<void> _startRecording() async {
    try {
      if (await _recorder.hasPermission()) {
        final dir = await getApplicationDocumentsDirectory();
        final fileName = 'recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
        _currentRecordingPath = '${dir.path}/$fileName';
        
        await _recorder.start(
          const RecordConfig(encoder: AudioEncoder.aacLc),
          path: _currentRecordingPath!,
        );
        
        // Start amplitude monitoring
        _amplitudeSub = _recorder
            .onAmplitudeChanged(const Duration(milliseconds: 40))
            .listen((amp) {
          setState(() {
            // Convert dB to normalized value (0-1)
            // Typical range is -160 to 0 dB
            final normalized = (amp.current + 60) / 60;
            final clamped = normalized.clamp(0.0, 1.0);
            
            // Add to history and remove oldest
            _amplitudeHistory.add(clamped);
            _amplitudeHistory.removeAt(0);
          });
        });
        
        _startTimer();
        setState(() => _recordState = RecordState.record);
      }
    } catch (e) {
      debugPrint('Error starting recording: $e');
    }
  }

  Future<void> _pauseRecording() async {
    await _recorder.pause();
    _timer?.cancel();
    _amplitudeSub?.pause();
    setState(() => _recordState = RecordState.pause);
  }

  Future<void> _resumeRecording() async {
    await _recorder.resume();
    _startTimer();
    _amplitudeSub?.resume();
    setState(() => _recordState = RecordState.record);
  }

  Future<void> _stopRecording() async {
    final path = await _recorder.stop();
    _timer?.cancel();
    _amplitudeSub?.cancel();
    
    // Clear amplitude history
    setState(() {
      _amplitudeHistory.fillRange(0, _amplitudeHistory.length, 0.0);
    });
    
    if (path != null) {
      final recording = RecordingItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'Recording ${_recordings.length + 1}',
        path: path,
        duration: _recordDuration,
        date: DateTime.now(),
      );
      
      setState(() {
        _recordings.insert(0, recording);
        _recordDuration = Duration.zero;
        _recordState = RecordState.stop;
      });
      
      await _saveRecordings();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() => _recordDuration += const Duration(milliseconds: 100));
    });
  }

  Future<void> _playRecording(RecordingItem recording) async {
    if (_playingItem?.id == recording.id) {
      // If currently playing this recording, stop it
      setState(() => _playingItem = null);
      await _player.stop();
    } else {
      // If playing different recording or not playing, start this one
      setState(() => _playingItem = recording);
      try {
        await _player.setFilePath(recording.path);
        await _player.play();
      } catch (e) {
        debugPrint('Error playing recording: $e');
        // Reset state if there's an error
        setState(() => _playingItem = null);
      }
    }
  }

  Future<void> _deleteRecording(RecordingItem recording) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Recording?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      try {
        final file = File(recording.path);
        if (await file.exists()) await file.delete();
        
        setState(() => _recordings.removeWhere((r) => r.id == recording.id));
        await _saveRecordings();
      } catch (e) {
        debugPrint('Error deleting recording: $e');
      }
    }
  }

  Future<void> _renameRecording(RecordingItem recording) async {
    final controller = TextEditingController(text: recording.title);
    final newTitle = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Recording'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Enter new name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    
    if (newTitle != null && newTitle.isNotEmpty) {
      setState(() {
        final index = _recordings.indexWhere((r) => r.id == recording.id);
        _recordings[index] = recording.copyWith(title: newTitle);
      });
      await _saveRecordings();
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    final milliseconds = (duration.inMilliseconds % 1000) ~/ 100;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}.$milliseconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Recordings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Recording controls
          Container(
            padding: const EdgeInsets.all(20),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Timer display
                    Text(
                      _formatDuration(_recordDuration),
                      style: const TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w300,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Waveform visualization
                    SizedBox(
                      height: 60,
                      width: double.infinity,
                      child: CustomPaint(
                        painter: WaveformPainter(
                          amplitudes: _amplitudeHistory,
                          color: _recordState == RecordState.record 
                              ? const Color(0xFFEF4444)
                              : const Color(0xFF6B7280),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Control buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_recordState == RecordState.stop) ...[
                          // Start recording button
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFEF4444),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFEF4444).withOpacity(0.3),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: IconButton(
                              onPressed: _startRecording,
                              icon: const Icon(Icons.fiber_manual_record, size: 32),
                            ),
                          ),
                        ] else ...[
                          // Pause/Resume button
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.3) ?? Colors.white30, width: 2),
                            ),
                            child: IconButton(
                              onPressed: _recordState == RecordState.record 
                                  ? _pauseRecording 
                                  : _resumeRecording,
                              icon: Icon(
                                _recordState == RecordState.record ? Icons.pause : Icons.play_arrow,
                                size: 24,
                              ),
                            ),
                          ),
                          const SizedBox(width: 32),
                          // Stop button
                          Container(
                            width: 56,
                            height: 56,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            child: IconButton(
                              onPressed: _stopRecording,
                              icon: const Icon(Icons.stop, color: Colors.black, size: 24),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Recordings list
          Expanded(
            child: _recordings.isEmpty
                ? Center(
                    child: Text(
                      'No recordings yet',
                      style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.54) ?? Colors.white54),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _recordings.length,
                    itemBuilder: (context, index) {
                      final recording = _recordings[index];
                      final isPlaying = _playingItem?.id == recording.id;
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: isPlaying 
                                  ? const Color(0xFF6366F1)
                                  : const Color(0xFF6366F1).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: IconButton(
                              onPressed: () => _playRecording(recording),
                              icon: Icon(
                                isPlaying ? Icons.stop : Icons.play_arrow,
                                color: isPlaying ? Colors.white : const Color(0xFF6366F1),
                              ),
                            ),
                          ),
                          title: Text(
                            recording.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            '${_formatDuration(recording.duration)} • ${_formatDate(recording.date)}',
                            style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.54) ?? Colors.white54),
                          ),
                          trailing: PopupMenuButton<String>(
                            icon: Icon(Icons.more_vert, color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.54) ?? Colors.white54),
                            onSelected: (value) {
                              switch (value) {
                                case 'rename':
                                  _renameRecording(recording);
                                  break;
                                case 'delete':
                                  _deleteRecording(recording);
                                  break;
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'rename',
                                child: Text('Rename'),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Text('Delete', style: TextStyle(color: Colors.red)),
                              ),
                            ],
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

// Custom painter for smooth waveform visualization
class WaveformPainter extends CustomPainter {
  final List<double> amplitudes;
  final Color color;

  WaveformPainter({
    required this.amplitudes,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    final width = size.width;
    final height = size.height;
    final centerY = height / 2;
    
    // Draw smooth waveform
    for (int i = 0; i < amplitudes.length; i++) {
      final x = (i / (amplitudes.length - 1)) * width;
      final amplitude = amplitudes[i];
      
      // Create symmetric waveform
      final y1 = centerY - (amplitude * centerY * 0.8);
      final y2 = centerY + (amplitude * centerY * 0.8);
      
      if (i == 0) {
        path.moveTo(x, centerY);
      }
      
      // Draw top curve
      if (i > 0) {
        final prevX = ((i - 1) / (amplitudes.length - 1)) * width;
        final prevAmplitude = amplitudes[i - 1];
        final prevY1 = centerY - (prevAmplitude * centerY * 0.8);
        
        final controlPointX = (prevX + x) / 2;
        path.quadraticBezierTo(controlPointX, prevY1, x, y1);
      }
    }
    
    // Draw bottom curve
    for (int i = amplitudes.length - 1; i >= 0; i--) {
      final x = (i / (amplitudes.length - 1)) * width;
      final amplitude = amplitudes[i];
      final y2 = centerY + (amplitude * centerY * 0.8);
      
      if (i < amplitudes.length - 1) {
        final nextX = ((i + 1) / (amplitudes.length - 1)) * width;
        final nextAmplitude = amplitudes[i + 1];
        final nextY2 = centerY + (nextAmplitude * centerY * 0.8);
        
        final controlPointX = (nextX + x) / 2;
        path.quadraticBezierTo(controlPointX, nextY2, x, y2);
      }
    }
    
    path.close();
    
    // Fill the waveform
    canvas.drawPath(
      path,
      paint..style = PaintingStyle.fill..color = color.withOpacity(0.3),
    );
    
    // Draw the outline
    canvas.drawPath(
      path,
      paint..style = PaintingStyle.stroke..color = color,
    );
    
    // Draw center line when idle
    if (amplitudes.every((amp) => amp == 0)) {
      canvas.drawLine(
        Offset(0, centerY),
        Offset(width, centerY),
        paint..strokeWidth = 1..color = color.withOpacity(0.5),
      );
    }
  }

  @override
  bool shouldRepaint(covariant WaveformPainter oldDelegate) {
    return true; // Always repaint for smooth animation
  }
}

class RecordingItem {
  final String id;
  final String title;
  final String path;
  final Duration duration;
  final DateTime date;

  RecordingItem({
    required this.id,
    required this.title,
    required this.path,
    required this.duration,
    required this.date,
  });

  RecordingItem copyWith({
    String? title,
  }) {
    return RecordingItem(
      id: id,
      title: title ?? this.title,
      path: path,
      duration: duration,
      date: date,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'path': path,
    'duration': duration.inMilliseconds,
    'date': date.toIso8601String(),
  };

  factory RecordingItem.fromJson(Map<String, dynamic> json) => RecordingItem(
    id: json['id'],
    title: json['title'],
    path: json['path'],
    duration: Duration(milliseconds: json['duration']),
    date: DateTime.parse(json['date']),
  );
} 