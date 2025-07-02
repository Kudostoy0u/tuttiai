import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:just_audio/just_audio.dart';
import 'dart:typed_data';
import 'package:tuttiai/widgets/metronome/bpm_display.dart';
import 'package:tuttiai/widgets/metronome/metronome_controls.dart';
import 'package:tuttiai/widgets/metronome/visual_metronome.dart';

class MetronomeScreen extends StatefulWidget {
  const MetronomeScreen({super.key});

  @override
  State<MetronomeScreen> createState() => _MetronomeScreenState();
}

class _MetronomeScreenState extends State<MetronomeScreen> with TickerProviderStateMixin {
  // State variables
  bool _isPlaying = false;
  bool _isInitialized = false;
  int _bpm = 120;
  int _timeSignature = 4;
  int _currentBeat = 0;
  int _subdivision = 1; // 1 = quarter notes, 2 = eighth notes, 4 = sixteenth notes
  
  // Animation controllers
  late AnimationController _beatController;
  late AnimationController _pendulumController;
  late AnimationController _visualBeatController;
  
  // Timer for metronome ticking
  Timer? _metronomeTimer;

  // Tap tempo variables
  final List<DateTime> _tapTimes = [];

  final List<int> _commonBpms = [60, 72, 80, 92, 104, 120, 138, 144, 160, 176, 192, 208];
  final List<Map<String, dynamic>> _tempoMarkings = [
    {'name': 'Largo', 'range': '40-60', 'min': 40, 'max': 60},
    {'name': 'Adagio', 'range': '66-76', 'min': 66, 'max': 76},
    {'name': 'Andante', 'range': '76-108', 'min': 76, 'max': 108},
    {'name': 'Moderato', 'range': '108-120', 'min': 108, 'max': 120},
    {'name': 'Allegro', 'range': '120-168', 'min': 120, 'max': 168},
    {'name': 'Presto', 'range': '168-200', 'min': 168, 'max': 200},
    {'name': 'Prestissimo', 'range': '>200', 'min': 200, 'max': 300},
  ];

  final List<Map<String, dynamic>> _accentPatterns = [
    {'name': 'None', 'pattern': []},
    {'name': 'First Beat', 'pattern': []},
    {'name': 'Strong-Weak', 'pattern': [true, false]},
    {'name': 'Waltz', 'pattern': [true, false, false]},
    {'name': 'March', 'pattern': [true, false, true, false]},
    {'name': 'Complex', 'pattern': [true, false, true, false, false, true]},
  ];

  String _selectedAccentPattern = 'None';

  // --- Custom Audio Generation ---
  late AudioPlayer _accentPlayer;
  late AudioPlayer _tickPlayer;
  late List<AudioPlayer> _subdivisionPlayers;
  int _subdivisionPlayerIndex = 0;
  double _audioVolume = 100.0;
  double _hapticIntensity = 100.0;
  // --- End Custom Audio Generation ---

  @override
  void initState() {
    super.initState();
    
    // Sound system is ready - using SystemSound for immediate playback
    _initializeAudio();
    
    _beatController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _pendulumController = AnimationController(
      duration: Duration(milliseconds: (60000 / _bpm).round()),
      vsync: this,
    );
    _visualBeatController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  Future<void> _initializeAudio() async {
    _accentPlayer = AudioPlayer();
    _tickPlayer = AudioPlayer();
    _subdivisionPlayers = List.generate(4, (_) => AudioPlayer());

    final accentPcm = _generateTone(1200, 0.05);
    final tickPcm = _generateTone(880, 0.05);
    final subdivisionPcm = _generateTone(660, 0.05, 0.5);

    final subdivisionSource = MyCustomSource(_addWavHeader(subdivisionPcm));

    await _accentPlayer.setAudioSource(MyCustomSource(_addWavHeader(accentPcm)));
    await _tickPlayer.setAudioSource(MyCustomSource(_addWavHeader(tickPcm)));
    for (final player in _subdivisionPlayers) {
      await player.setAudioSource(subdivisionSource);
    }

    _updateAllVolumes(_audioVolume / 100.0);

    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  void _updateAllVolumes(double volume) {
    _accentPlayer.setVolume(volume);
    _tickPlayer.setVolume(volume);
    for (final player in _subdivisionPlayers) {
      player.setVolume(volume);
    }
  }

  Uint8List _addWavHeader(Uint8List pcm) {
    final int pcmLength = pcm.length;
    final int sampleRate = 44100;
    final int numChannels = 1;
    final int bitsPerSample = 16;
    final int byteRate = sampleRate * numChannels * (bitsPerSample ~/ 8);
    final int blockAlign = numChannels * (bitsPerSample ~/ 8);
    final int chunkSize = 36 + pcmLength;

    final ByteData header = ByteData(44);
    header.setUint8(0, 0x52); // 'R'
    header.setUint8(1, 0x49); // 'I'
    header.setUint8(2, 0x46); // 'F'
    header.setUint8(3, 0x46); // 'F'
    header.setUint32(4, chunkSize, Endian.little);
    header.setUint8(8, 0x57); // 'W'
    header.setUint8(9, 0x41); // 'A'
    header.setUint8(10, 0x56); // 'V'
    header.setUint8(11, 0x45); // 'E'
    header.setUint8(12, 0x66); // 'f'
    header.setUint8(13, 0x6D); // 'm'
    header.setUint8(14, 0x74); // 't'
    header.setUint8(15, 0x20); // ' '
    header.setUint32(16, 16, Endian.little); // Subchunk1Size for PCM
    header.setUint16(20, 1, Endian.little); // AudioFormat - 1 for PCM
    header.setUint16(22, numChannels, Endian.little);
    header.setUint32(24, sampleRate, Endian.little);
    header.setUint32(28, byteRate, Endian.little);
    header.setUint16(32, blockAlign, Endian.little);
    header.setUint16(34, bitsPerSample, Endian.little);
    header.setUint8(36, 0x64); // 'd'
    header.setUint8(37, 0x61); // 'a'
    header.setUint8(38, 0x74); // 't'
    header.setUint8(39, 0x61); // 'a'
    header.setUint32(40, pcmLength, Endian.little);

    final builder = BytesBuilder(copy: false);
    builder.add(header.buffer.asUint8List());
    builder.add(pcm);
    return builder.takeBytes();
  }

  Uint8List _generateTone(double frequency, double duration, [double amplitude = 1.0]) {
    const int sampleRate = 44100;
    final int frameCount = (sampleRate * duration).round();
    final Float32List buffer = Float32List(frameCount);
    final double twoPi = math.pi * 2;

    for (int i = 0; i < frameCount; i++) {
      final double t = i / sampleRate;
      final double envelope = math.pow(1 - (t / duration), 2.0).toDouble();
      buffer[i] = math.sin(twoPi * frequency * t) * envelope * amplitude;
    }

    final Uint8List pcm = Uint8List(frameCount * 2);
    for (int i = 0; i < frameCount; i++) {
      final int sample = (buffer[i] * 32767).round().clamp(-32768, 32767);
      pcm[i * 2] = sample & 0xFF;
      pcm[i * 2 + 1] = (sample >> 8) & 0xFF;
    }
    return pcm;
  }

  void _startMetronome() {
    _stopMetronome(); // Stop any existing timer
    
    final beatIntervalMs = (60000 / (_bpm * _subdivision)).round();
    
    _pendulumController.duration = Duration(milliseconds: (60000 / _bpm * 2).round());
    _pendulumController.repeat();
    
    _metronomeTimer = Timer.periodic(Duration(milliseconds: beatIntervalMs), (timer) {
      if (!mounted || !_isPlaying) {
        timer.cancel();
        return;
      }
      
      setState(() {
        _currentBeat = (_currentBeat + 1) % (_timeSignature * _subdivision);
      });
      
      _visualBeatController.forward().then((_) => _visualBeatController.reverse());
      
      // Check if this is a main beat (not subdivision)
      if (_currentBeat % _subdivision == 0) {
        _beatController.forward().then((_) => _beatController.reverse());
        
        final beatNumber = (_currentBeat ~/ _subdivision) % _timeSignature;
        final isAccent = _shouldAccent(beatNumber);
        
        _playSound(isAccent: isAccent, isSubdivision: false);
      } else {
        // Subdivision beat
        _playSound(isAccent: false, isSubdivision: true);
      }
    });
  }
  
  void _stopMetronome() {
    _metronomeTimer?.cancel();
    _metronomeTimer = null;
    _pendulumController.stop();
    _pendulumController.reset();
    _visualBeatController.reset();
    
    if (mounted) {
      setState(() {
        _currentBeat = 0;
      });
    }
  }

  void _playSound({required bool isAccent, bool isSubdivision = false}) {
    final AudioPlayer player;

    if (_hapticIntensity > 0) {
      if (isAccent) {
        if (_hapticIntensity > 50) {
          HapticFeedback.heavyImpact();
        } else {
          HapticFeedback.mediumImpact();
        }
      } else if (isSubdivision) {
        HapticFeedback.selectionClick();
      } else { // regular beat
        if (_hapticIntensity > 50) {
          HapticFeedback.mediumImpact();
        } else {
          HapticFeedback.lightImpact();
        }
      }
    }

    if (isAccent) {
      player = _accentPlayer;
    } else if (isSubdivision) {
      player = _subdivisionPlayers[_subdivisionPlayerIndex];
      _subdivisionPlayerIndex = (_subdivisionPlayerIndex + 1) % _subdivisionPlayers.length;
    } else {
      player = _tickPlayer;
    }

    try {
      player.seek(Duration.zero);
      player.play();
    } catch (_) {
      // Ignore player errors
    }
  }

  @override
  void dispose() {
    // Cancel timers/animations without calling setState to avoid lifecycle assertion.
    _metronomeTimer?.cancel();
    _pendulumController.stop();
    _visualBeatController.stop();
    _beatController.stop();

    _beatController.dispose();
    _pendulumController.dispose();
    _visualBeatController.dispose();
    _accentPlayer.dispose();
    _tickPlayer.dispose();
    for (final player in _subdivisionPlayers) {
      player.dispose();
    }
    
    super.dispose();
  }

  void _toggleMetronome() {
    if (!mounted || !_isInitialized) return;
    setState(() {
      _isPlaying = !_isPlaying;
    });

    if (_isPlaying) {
      _startMetronome();
    } else {
      _stopMetronome();
    }
  }

  bool _shouldAccent(int beatNumber) {
    // Check if pattern is set to 'None' - no accents at all
    if (_selectedAccentPattern == 'None') return false;
    
    // Special case: first beat only accent
    if (_selectedAccentPattern == 'First Beat') {
      return beatNumber == 0;
    }
    
    final patternData = _accentPatterns.firstWhere(
      (p) => p['name'] == _selectedAccentPattern,
      orElse: () => _accentPatterns.first,
    )['pattern'];
    
    final pattern = (patternData as List).cast<bool>();
    
    if (pattern.isEmpty) return false;
    
    // Use modulo to handle patterns shorter than time signature
    return pattern[beatNumber % pattern.length];
  }

  void _updateBpm(int newBpm) {
    final bpm = newBpm.clamp(40, 300);
    if (!mounted) return;
    setState(() {
      _bpm = bpm;
    });
    
    // Update pendulum animation speed
    if (_isPlaying) {
      _pendulumController.duration = Duration(milliseconds: (60000 / bpm * 2).round());
      // Restart metronome with new BPM
      _startMetronome();
    }
  }

  void _updateTimeSignature(int newTimeSignature) {
    if (!mounted) return;
    setState(() {
      _timeSignature = newTimeSignature;
      _currentBeat = 0;
    });
    
    if (_isPlaying) {
      // Restart metronome to reset beat counting
      _startMetronome();
    }
  }

  void _tapTempo() {
    if (!_isInitialized) return;

    if (_hapticIntensity > 0) {
      if (_hapticIntensity > 50) {
        HapticFeedback.mediumImpact();
      } else {
        HapticFeedback.lightImpact();
      }
    }

    try {
      _tickPlayer.seek(Duration.zero);
      _tickPlayer.play();
    } catch (_) {
      // Ignore player errors
    }

    final now = DateTime.now();
    _tapTimes.add(now);
    
    // Keep only the last 4 taps for calculation
    if (_tapTimes.length > 4) {
      _tapTimes.removeAt(0);
    }
    
    if (_tapTimes.length >= 2) {
      // Calculate average interval between taps
      final intervals = <int>[];
      for (int i = 1; i < _tapTimes.length; i++) {
        intervals.add(_tapTimes[i].difference(_tapTimes[i - 1]).inMilliseconds);
      }
      
      final averageInterval = intervals.reduce((a, b) => a + b) / intervals.length;
      final calculatedBpm = (60000 / averageInterval).round();
      
      if (calculatedBpm >= 40 && calculatedBpm <= 300) {
        _updateBpm(calculatedBpm);
      }
    }
    
    // Clear old taps after 3 seconds
    Timer(const Duration(seconds: 3), () {
      if (_tapTimes.isNotEmpty) {
        final oldTaps = _tapTimes.where(
          (tap) => now.difference(tap).inSeconds > 3,
        ).toList();
        _tapTimes.removeWhere((tap) => oldTaps.contains(tap));
      }
    });
  }

  String _getTempoMarking() {
    for (final marking in _tempoMarkings) {
      if (_bpm >= marking['min'] && _bpm <= marking['max']) {
        return marking['name'];
      }
    }
    return 'Custom';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Metronome',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.touch_app),
            onPressed: _isInitialized ? _tapTempo : null,
            tooltip: 'Tap Tempo',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // BPM Display
            BpmDisplay(
              bpm: _bpm,
              tempoMarking: _getTempoMarking(),
            ),
            const SizedBox(height: 20),
            VisualMetronome(
              isPlaying: _isPlaying,
              isInitialized: _isInitialized,
              pendulumController: _pendulumController,
              visualBeatController: _visualBeatController,
              beatController: _beatController,
              timeSignature: _timeSignature,
              currentBeat: _currentBeat,
              subdivision: _subdivision,
              shouldAccent: _shouldAccent,
              toggleMetronome: _toggleMetronome,
            ),
            const SizedBox(height: 16),
            BpmControls(bpm: _bpm, onBpmChanged: _updateBpm),
            const SizedBox(height: 16),
            SubdivisionControls(
              subdivision: _subdivision,
              onSubdivisionChanged: (value) {
                if (!mounted) return;
                setState(() {
                  _subdivision = value;
                  _currentBeat = 0;
                });
                if (_isPlaying) {
                  _startMetronome();
                }
              },
            ),
            const SizedBox(height: 12),
            TimeAccentControls(
              timeSignature: _timeSignature,
              selectedAccentPattern: _selectedAccentPattern,
              accentPatterns: _accentPatterns,
              onTimeSignatureChanged: _updateTimeSignature,
              onAccentPatternChanged: (newValue) {
                if (newValue != null) {
                  if (!mounted) return;
                  setState(() {
                    _selectedAccentPattern = newValue;
                  });
                }
              },
            ),
            const SizedBox(height: 12),
            FeedbackControls(
              audioVolume: _audioVolume,
              hapticIntensity: _hapticIntensity,
              onAudioVolumeChanged: (value) {
                setState(() {
                  _audioVolume = value;
                });
                _updateAllVolumes(value / 100.0);
              },
              onHapticIntensityChanged: (value) {
                setState(() {
                  _hapticIntensity = value;
                });
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class MyCustomSource extends StreamAudioSource {
  final Uint8List bytes;
  MyCustomSource(this.bytes);

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    start ??= 0;
    end ??= bytes.length;
    return StreamAudioResponse(
      sourceLength: bytes.length,
      contentLength: end - start,
      offset: start,
      stream: Stream.value(bytes.sublist(start, end)),
      contentType: 'audio/wav',
    );
  }
} 