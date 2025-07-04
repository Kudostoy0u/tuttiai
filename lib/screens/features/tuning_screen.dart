import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:record/record.dart';
import 'package:pitch_detector_dart/pitch_detector.dart';
import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/localization_service.dart';

class TuningScreen extends StatefulWidget {
  const TuningScreen({super.key});

  @override
  State<TuningScreen> createState() => _TuningScreenState();
}

class _TuningScreenState extends State<TuningScreen> with TickerProviderStateMixin {
  // Audio players for reference tones
  final AudioPlayer _referencePlayer = AudioPlayer();
  final AudioRecorder _audioRecorder = AudioRecorder();
  late PitchDetector _pitchDetector;
  
  // Audio configuration
  static const int _sampleRate = 44100; // Standard sample rate  
  static const int _bufferSize = 4000; // Increased buffer size to match common implementations
  
  // Animation controllers
  late AnimationController _tuningAnimationController;
  late AnimationController _pulseController;
  
  // State variables
  bool _isListening = false;
  bool _isPlayingReference = false;
  double _currentPitch = 0.0;
  double _targetPitch = 0.0;
  String _detectedNote = '';
  String _selectedInstrument = 'Violin';
  String _selectedNote = '';
  String _selectedString = '';
  int _selectedOctave = 4;
  double _cents = 0.0;
  
  // Pitch detection
  StreamSubscription<Uint8List>? _recordSub;
  Timer? _pitchUpdateTimer;
  
  // Buffer for accumulating audio samples
  final List<int> _audioBuffer = [];
  
  // Instrument definitions with base notes and default octaves
  final Map<String, List<Map<String, dynamic>>> _instruments = {
    'Violin': [
      {'note': 'E', 'defaultOctave': 5, 'string': 'E'},
      {'note': 'A', 'defaultOctave': 4, 'string': 'A'},
      {'note': 'D', 'defaultOctave': 4, 'string': 'D'},
      {'note': 'G', 'defaultOctave': 3, 'string': 'G'},
    ],
    'Viola': [
      {'note': 'A', 'defaultOctave': 4, 'string': 'A'},
      {'note': 'D', 'defaultOctave': 4, 'string': 'D'},
      {'note': 'G', 'defaultOctave': 3, 'string': 'G'},
      {'note': 'C', 'defaultOctave': 3, 'string': 'C'},
    ],
    'Cello': [
      {'note': 'A', 'defaultOctave': 3, 'string': 'A'},
      {'note': 'D', 'defaultOctave': 3, 'string': 'D'},
      {'note': 'G', 'defaultOctave': 2, 'string': 'G'},
      {'note': 'C', 'defaultOctave': 2, 'string': 'C'},
    ],
    'Double Bass': [
      {'note': 'G', 'defaultOctave': 2, 'string': 'G'},
      {'note': 'D', 'defaultOctave': 2, 'string': 'D'},
      {'note': 'A', 'defaultOctave': 1, 'string': 'A'},
      {'note': 'E', 'defaultOctave': 1, 'string': 'E'},
    ],
    'Guitar': [
      {'note': 'E', 'defaultOctave': 4, 'string': 'E'},
      {'note': 'B', 'defaultOctave': 3, 'string': 'B'},
      {'note': 'G', 'defaultOctave': 3, 'string': 'G'},
      {'note': 'D', 'defaultOctave': 3, 'string': 'D'},
      {'note': 'A', 'defaultOctave': 2, 'string': 'A'},
      {'note': 'E', 'defaultOctave': 2, 'string': 'E'},
    ],
    'Flute': [
      {'note': 'A', 'defaultOctave': 4, 'string': 'Concert A'},
      {'note': 'Bb', 'defaultOctave': 4, 'string': 'B♭'},
    ],
    'Oboe': [
      {'note': 'A', 'defaultOctave': 4, 'string': 'Concert A'},
      {'note': 'Bb', 'defaultOctave': 4, 'string': 'B♭'},
    ],
    'Clarinet': [
      {'note': 'A', 'defaultOctave': 4, 'string': 'Concert A'},
      {'note': 'Bb', 'defaultOctave': 4, 'string': 'B♭'},
    ],
    'Trumpet': [
      {'note': 'A', 'defaultOctave': 4, 'string': 'Concert A'},
      {'note': 'Bb', 'defaultOctave': 4, 'string': 'B♭'},
      {'note': 'C', 'defaultOctave': 5, 'string': 'C'},
    ],
    'French Horn': [
      {'note': 'A', 'defaultOctave': 4, 'string': 'Concert A'},
      {'note': 'F', 'defaultOctave': 4, 'string': 'F'},
      {'note': 'Bb', 'defaultOctave': 3, 'string': 'B♭'},
    ],
    'Trombone': [
      {'note': 'A', 'defaultOctave': 4, 'string': 'Concert A'},
      {'note': 'Bb', 'defaultOctave': 3, 'string': 'B♭'},
      {'note': 'F', 'defaultOctave': 3, 'string': 'F'},
    ],
  };

  /// Calculate frequency for a given note and octave
  /// Uses A4 = 440 Hz as reference
  double _calculateFrequency(String note, int octave) {
    // Note to semitone mapping (A4 = 0)
    final Map<String, int> noteOffsets = {
      'C': -9,
      'C#': -8, 'Db': -8,
      'D': -7,
      'D#': -6, 'Eb': -6,
      'E': -5,
      'F': -4,
      'F#': -3, 'Gb': -3,
      'G': -2,
      'G#': -1, 'Ab': -1,
      'A': 0,
      'A#': 1, 'Bb': 1,
      'B': 2,
    };
    
    final int semitoneOffset = noteOffsets[note] ?? 0;
    final int octaveOffset = (octave - 4) * 12; // A4 is our reference
    final int totalSemitones = semitoneOffset + octaveOffset;
    
    // A4 = 440 Hz, each semitone is 2^(1/12) times the previous
    return 440.0 * math.pow(2, totalSemitones / 12.0);
  }

  /// Get the display note name with octave
  String _getDisplayNote(String note, int octave) {
    return '$note$octave';
  }

  /// Find the closest note to a given frequency
  String _findClosestNote(double frequency) {
    if (frequency <= 0) return '';
    
    // Calculate semitones from A4 (440 Hz)
    final semitones = 12 * (math.log(frequency / 440) / math.log(2));
    final roundedSemitones = semitones.round();
    
    // A4 is at index 0, so we need to map to note names correctly
    // Note sequence starting from A: A, A#, B, C, C#, D, D#, E, F, F#, G, G#
    const noteNames = ['A', 'A#', 'B', 'C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#'];
    
    // Calculate note index (0-11) and octave
    int noteIndex = roundedSemitones % 12;
    if (noteIndex < 0) noteIndex += 12; // Handle negative modulo
    
    // Calculate octave - A4 is octave 4, so we adjust from there
    int octave = 4 + (roundedSemitones / 12).floor();
    
    // Special handling for notes B and higher that cross octave boundary
    // When we go from A4 to B4, we're still in octave 4
    // When we go from B4 to C5, we enter octave 5
    if (noteIndex >= 2) { // C and above
      octave += 1;
    }
    
    final noteName = noteNames[noteIndex];
    return '$noteName$octave';
  }

  @override
  void initState() {
    super.initState();
    
    _tuningAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    // Select first note of default instrument
    final firstNote = _instruments[_selectedInstrument]!.first;
    _selectedString = firstNote['string'];
    _selectedNote = firstNote['note'];
    _selectedOctave = firstNote['defaultOctave'];
    _targetPitch = _calculateFrequency(_selectedNote, _selectedOctave);
    
    // Initialize pitch detector with optimal settings for music
    _pitchDetector = PitchDetector(
      audioSampleRate: _sampleRate.toDouble(),
      bufferSize: _bufferSize,
    );
    
    // Check permissions on init
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    try {
      final hasPermission = await _audioRecorder.hasPermission();
      if (!hasPermission) {
        debugPrint('Microphone permission not granted');
      }
    } catch (e) {
      debugPrint('Error checking permissions: $e');
    }
  }

  @override
  void dispose() {
    _pitchUpdateTimer?.cancel();
    _recordSub?.cancel();
    _audioRecorder.dispose();
    _referencePlayer.dispose();
    _tuningAnimationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _stopListening();
    } else {
      await _startListening();
    }
  }

  Future<void> _startListening() async {
    try {
      // Request permission if needed
      if (!await _audioRecorder.hasPermission()) {
        final hasPermission = await _audioRecorder.hasPermission();
        debugPrint('Microphone permission status: $hasPermission');
        if (!hasPermission) {
          _showError('Microphone permission is required for tuning');
          return;
        }
      }

      // Check if encoder is supported
      if (!await _audioRecorder.isEncoderSupported(AudioEncoder.pcm16bits)) {
        _showError('PCM recording is not supported on this device');
        return;
      }

      debugPrint('Starting audio recording...');

      // Start streaming audio data
      final stream = await _audioRecorder.startStream(
        const RecordConfig(
          encoder: AudioEncoder.pcm16bits,
          sampleRate: _sampleRate,
          numChannels: 1,
          bitRate: 128000,
        ),
      );

      setState(() {
        _isListening = true;
      });

      debugPrint('Audio stream started successfully');

      // Process audio data with pitch detection
      _recordSub = stream.listen(
        (data) {
          _processPitch(data);
        },
        onError: (error) {
          debugPrint('Audio stream error: $error');
          _showError('Audio stream error: $error');
          _stopListening();
        },
        onDone: () {
          debugPrint('Audio stream completed');
        },
      );

      // Start animation
      _tuningAnimationController.repeat();
    } catch (e) {
      debugPrint('Error starting recording: $e');
      _showError('Failed to start tuning: ${e.toString()}');
      setState(() {
        _isListening = false;
      });
    }
  }

  Future<void> _stopListening() async {
    try {
      await _audioRecorder.stop();
      _recordSub?.cancel();
      _pitchUpdateTimer?.cancel();
      
      // Clear the audio buffer
      _audioBuffer.clear();
      
      if (mounted) {
        setState(() {
          _isListening = false;
          _currentPitch = 0.0;
          _cents = 0.0;
          _detectedNote = '';
        });
      }
      
      _tuningAnimationController.stop();
      _tuningAnimationController.reset();
    } catch (e) {
      debugPrint('Error stopping recording: $e');
    }
  }

  void _processPitch(Uint8List audioData) async {
    if (audioData.isEmpty) return;
    
    try {
      // Add the audio data to the buffer
      _audioBuffer.addAll(audioData);
      
      // The pitch detector needs exactly bufferSize * 2 bytes for PCM16
      final requiredBytes = _bufferSize * 2;
      
      // Process when we have enough samples
      while (_audioBuffer.length >= requiredBytes) {
        // Extract exactly the required number of bytes
        final intBuffer = Uint8List.fromList(_audioBuffer.take(requiredBytes).toList());
        
        // Remove processed bytes from buffer
        _audioBuffer.removeRange(0, requiredBytes);
        
        // Debug logging to verify buffer size
        debugPrint('Processing buffer of size: ${intBuffer.length} bytes (expected: $requiredBytes)');
        
        // Use pitch detector with the buffer
        final result = await _pitchDetector.getPitchFromIntBuffer(intBuffer);
        
        // Debug logging
        debugPrint('Pitch detection - Pitched: ${result.pitched}, Pitch: ${result.pitch}, Probability: ${result.probability}');
        
        // Update UI if a valid pitch is detected
        if (result.pitched && result.pitch > 50 && result.pitch < 2000) {
          if (mounted) {
            setState(() {
              _currentPitch = result.pitch;
              _cents = _calculateCents(_currentPitch, _targetPitch);
              _detectedNote = _findClosestNote(_currentPitch);
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Error in pitch processing: $e');
      if (e.toString().contains('InvalidAudioBufferException')) {
        debugPrint('Buffer size mismatch - check that buffer size matches pitch detector expectations');
      }
    }
  }

  double _calculateCents(double frequency, double targetFrequency) {
    if (frequency <= 0 || targetFrequency <= 0) return 0;
    return 1200 * (math.log(frequency / targetFrequency) / math.log(2));
  }

  Future<void> _playReferenceTone() async {
    if (_isPlayingReference) {
      await _referencePlayer.stop();
      setState(() {
        _isPlayingReference = false;
      });
      return;
    }

    setState(() {
      _isPlayingReference = true;
    });

    try {
      // Generate a sine wave for the reference tone
      final sampleRate = _sampleRate;
      final duration = 3; // seconds
      final samples = sampleRate * duration;
      final waveData = List<int>.generate(samples, (i) {
        final sample = math.sin(2 * math.pi * _targetPitch * i / sampleRate);
        // Convert to 16-bit PCM with lower volume
        return (sample * 16383).toInt(); // Half volume to avoid clipping
      });
      
      // Convert to bytes
      final bytes = Uint8List(waveData.length * 2);
      final byteData = bytes.buffer.asByteData();
      for (int i = 0; i < waveData.length; i++) {
        byteData.setInt16(i * 2, waveData[i], Endian.little);
      }
      
      // Create WAV file in memory
      final wavBytes = _createWavFile(bytes, sampleRate);
      
      // Play the generated audio
      await _referencePlayer.setAudioSource(
        WaveAudioSource(wavBytes),
      );
      await _referencePlayer.play();
      
      // Wait for playback to complete
      await _referencePlayer.playerStateStream.firstWhere(
        (state) => state.processingState == ProcessingState.completed,
      );
      
    } catch (e) {
      debugPrint('Error playing reference tone: $e');
      _showError('Failed to play reference tone');
    } finally {
      setState(() {
        _isPlayingReference = false;
      });
    }
  }

  Uint8List _createWavFile(Uint8List pcmData, int sampleRate) {
    final dataSize = pcmData.length;
    final fileSize = dataSize + 36; // 44 - 8
    
    final wav = Uint8List(44 + dataSize);
    final byteData = wav.buffer.asByteData();
    
    // RIFF header
    wav.setRange(0, 4, 'RIFF'.codeUnits);
    byteData.setUint32(4, fileSize, Endian.little);
    wav.setRange(8, 12, 'WAVE'.codeUnits);
    
    // fmt chunk
    wav.setRange(12, 16, 'fmt '.codeUnits);
    byteData.setUint32(16, 16, Endian.little); // chunk size
    byteData.setUint16(20, 1, Endian.little); // PCM format
    byteData.setUint16(22, 1, Endian.little); // channels
    byteData.setUint32(24, sampleRate, Endian.little);
    byteData.setUint32(28, sampleRate * 2, Endian.little); // byte rate
    byteData.setUint16(32, 2, Endian.little); // block align
    byteData.setUint16(34, 16, Endian.little); // bits per sample
    
    // data chunk
    wav.setRange(36, 40, 'data'.codeUnits);
    byteData.setUint32(40, dataSize, Endian.little);
    wav.setRange(44, 44 + dataSize, pcmData);
    
    return wav;
  }

  void _showError(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Color _getTuningColor() {
    final absCents = _cents.abs();
    if (absCents <= 5) {
      return const Color(0xFF10B981); // Green - in tune
    } else if (absCents <= 10) {
      return const Color(0xFFF59E0B); // Yellow - close
    } else {
      return const Color(0xFFEF4444); // Red - out of tune
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Builder(builder: (context) {
          final settings = Provider.of<SettingsProvider>(context);
          return Text(
            LocalizationService.translate('tuner', settings.language),
            style: const TextStyle(fontWeight: FontWeight.bold),
          );
        }),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Instrument Selector
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Builder(builder: (context){
                      final lang = Provider.of<SettingsProvider>(context).language;
                      return Text(
                        LocalizationService.translate('select_instrument', lang),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      );
                    }),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white30),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButton<String>(
                        value: _selectedInstrument,
                        isExpanded: true,
                        dropdownColor: Theme.of(context).cardColor,
                        style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                        underline: const SizedBox(),
                        items: _instruments.keys.map((instrument) {
                          return DropdownMenuItem(
                            value: instrument,
                            child: Builder(builder:(context){final lang=Provider.of<SettingsProvider>(context).language;return Text(LocalizationService.translate('instrument_${instrument.toLowerCase().replaceAll(' ', '_')}', lang));}),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedInstrument = value;
                              final firstNote = _instruments[value]!.first;
                              _selectedString = firstNote['string'];
                              _selectedNote = firstNote['note'];
                              _selectedOctave = firstNote['defaultOctave'];
                              _targetPitch = _calculateFrequency(_selectedNote, _selectedOctave);
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Note Selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _instruments[_selectedInstrument]!.any((n) => n['string'].length > 1) 
                          ? LocalizationService.translate('select_string', Provider.of<SettingsProvider>(context, listen: false).language) 
                          : LocalizationService.translate('select_string', Provider.of<SettingsProvider>(context, listen: false).language),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // String/Note Selection - Full Width Grid
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: math.min(4, _instruments[_selectedInstrument]!.length),
                      childAspectRatio: 1.2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      children: _instruments[_selectedInstrument]!.map((noteData) {
                        final isSelected = _selectedString == noteData['string'];
                        return Material(
                          color: isSelected 
                              ? const Color(0xFF6366F1) 
                              : Theme.of(context).colorScheme.onSurface.withAlpha(26),
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              setState(() {
                                _selectedString = noteData['string'];
                                _selectedNote = noteData['note'];
                                _selectedOctave = noteData['defaultOctave'];
                                _targetPitch = _calculateFrequency(_selectedNote, _selectedOctave);
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: isSelected 
                                    ? null 
                                    : Border.all(color: Theme.of(context).colorScheme.onSurface.withAlpha(77)),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    noteData['string'],
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(179),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _getDisplayNote(noteData['note'], noteData['defaultOctave']),
                                    style: TextStyle(
                                      color: isSelected ? Colors.white70 : Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(138),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Octave Selection
                    Row(
                      children: [
                        Builder(
                          builder: (context) {
                            final lang = Provider.of<SettingsProvider>(context).language;
                            return Text(
                              '${LocalizationService.translate('octave', lang)}:',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Row(
                            children: [
                              // Decrease octave button
                              Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.onSurface.withAlpha(26),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Theme.of(context).colorScheme.onSurface.withAlpha(77)),
                                ),
                                child: IconButton(
                                  onPressed: _selectedOctave > 0 ? () {
                                    setState(() {
                                      _selectedOctave--;
                                      _targetPitch = _calculateFrequency(_selectedNote, _selectedOctave);
                                    });
                                  } : null,
                                  icon: Icon(Icons.remove, color: Theme.of(context).iconTheme.color),
                                  iconSize: 20,
                                ),
                              ),
                              
                              // Octave display
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 8),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF6366F1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '$_selectedOctave',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              
                              // Increase octave button
                              Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.onSurface.withAlpha(26),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Theme.of(context).colorScheme.onSurface.withAlpha(77)),
                                ),
                                child: IconButton(
                                  onPressed: _selectedOctave < 8 ? () {
                                    setState(() {
                                      _selectedOctave++;
                                      _targetPitch = _calculateFrequency(_selectedNote, _selectedOctave);
                                    });
                                  } : null,
                                  icon: Icon(Icons.add, color: Theme.of(context).iconTheme.color),
                                  iconSize: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Tuning Display
            Card(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Visual Tuner
                    SizedBox(
                      width: 200,
                      height: 200,
                      child: CustomPaint(
                        size: Size.infinite,
                        painter: TunerPainter(
                          tuningOffset: _cents,
                          noteName: _getDisplayNote(_selectedNote, _selectedOctave),
                          isListening: _isListening,
                          color: _isListening ? _getTuningColor() : (Theme.of(context).iconTheme.color ?? Colors.grey).withAlpha(77),
                          detectedNote: _detectedNote,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Control Buttons - Fixed overflow with flexible layout
                    LayoutBuilder(
                      builder: (context, constraints) {
                        // Use column layout for narrow screens
                        if (constraints.maxWidth < 320) {
                          return Column(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: _playReferenceTone,
                                  icon: Icon(
                                    _isPlayingReference ? Icons.stop : Icons.play_arrow,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  label: Builder(builder:(context){final lang=Provider.of<SettingsProvider>(context).language;return Text(_isPlayingReference? LocalizationService.translate('stop',lang): LocalizationService.translate('reference',lang),style: const TextStyle(color: Colors.white));}),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF6366F1),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: _toggleListening,
                                  icon: Icon(
                                    _isListening ? Icons.mic : Icons.mic_none,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  label: Builder(builder:(context){final lang=Provider.of<SettingsProvider>(context).language;return Text(_isListening? LocalizationService.translate('stop',lang): LocalizationService.translate('start',lang),style: const TextStyle(color: Colors.white));}),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _isListening 
                                        ? const Color(0xFFEF4444) 
                                        : const Color(0xFF10B981),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }
                        
                        // Use row layout for wider screens with flexible spacing
                        return Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _playReferenceTone,
                                icon: Icon(
                                  _isPlayingReference ? Icons.stop : Icons.play_arrow,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                label: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Builder(builder:(context){final l=Provider.of<SettingsProvider>(context).language;return Text(_isPlayingReference? LocalizationService.translate('stop',l): LocalizationService.translate('reference',l),style: const TextStyle(color: Colors.white));}),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF6366F1),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _toggleListening,
                                icon: Icon(
                                  _isListening ? Icons.mic : Icons.mic_none,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                label: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Builder(builder:(context){final l=Provider.of<SettingsProvider>(context).language;return Text(_isListening? LocalizationService.translate('stop',l): LocalizationService.translate('start',l),style: const TextStyle(color: Colors.white));}),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _isListening 
                                      ? const Color(0xFFEF4444) 
                                      : const Color(0xFF10B981),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Target Frequency Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Builder(builder: (context){final lang=Provider.of<SettingsProvider>(context).language;return Text(
                          LocalizationService.translate('target_note', lang),
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(138),
                            fontSize: 14,
                          ),
                        );}),
                        Text(
                          _getDisplayNote(_selectedNote, _selectedOctave),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Builder(builder: (context){final lang=Provider.of<SettingsProvider>(context).language;return Text(
                          LocalizationService.translate('target_frequency', lang),
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(138),
                            fontSize: 14,
                          ),
                        );}),
                        Text(
                          '${_targetPitch.toStringAsFixed(2)} Hz',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom painter for the tuning meter
class TunerPainter extends CustomPainter {
  final double tuningOffset;
  final String noteName;
  final bool isListening;
  final Color color;
  final String detectedNote;

  TunerPainter({
    required this.tuningOffset,
    required this.noteName,
    required this.isListening,
    required this.color,
    required this.detectedNote,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 20;
    
    // Draw circular path
    final pathPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius, pathPaint);
    
    // Draw center mark
    final centerMarkPaint = Paint()
      ..color = color.withValues(alpha: 0.7)
      ..strokeWidth = 3;
    
    final centerAngle = math.pi * 1.5;
    final centerStartX = center.dx + (radius - 10) * math.cos(centerAngle);
    final centerStartY = center.dy + (radius - 10) * math.sin(centerAngle);
    final centerEndX = center.dx + (radius + 10) * math.cos(centerAngle);
    final centerEndY = center.dy + (radius + 10) * math.sin(centerAngle);
    
    canvas.drawLine(
      Offset(centerStartX, centerStartY),
      Offset(centerEndX, centerEndY),
      centerMarkPaint,
    );
    
    if (isListening) {
      // Draw curved paddle indicator
      final normalizedOffset = tuningOffset.clamp(-50.0, 50.0);
      final indicatorAngle = math.pi * 0.75 + (math.pi * 1.5 * ((normalizedOffset + 50) / 100));
      
      // Draw curved paddle
      final paddlePaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      
      final paddleRadius = 12.0;
      final paddleDistance = radius - 5;
      
      // Create curved paddle path
      final paddlePath = Path();
      
      // Calculate paddle arc points
      final paddleStartAngle = indicatorAngle - 0.2;
      final paddleEndAngle = indicatorAngle + 0.2;
      
      // Outer arc
      final outerRadius = paddleDistance + paddleRadius;
      
      // Inner arc  
      final innerRadius = paddleDistance - paddleRadius;
      
      // Build paddle as an arc segment
      paddlePath.addArc(
        Rect.fromCircle(center: center, radius: outerRadius),
        paddleStartAngle,
        paddleEndAngle - paddleStartAngle,
      );
      
      paddlePath.arcTo(
        Rect.fromCircle(center: center, radius: innerRadius),
        paddleEndAngle,
        -(paddleEndAngle - paddleStartAngle),
        false,
      );
      
      paddlePath.close();
      
      // Draw the paddle
      canvas.drawPath(paddlePath, paddlePaint);
      
      // Add a small highlight circle on the paddle
      final paddleCenterX = center.dx + paddleDistance * math.cos(indicatorAngle);
      final paddleCenterY = center.dy + paddleDistance * math.sin(indicatorAngle);
      
      final highlightPaint = Paint()
        ..color = color.withAlpha(180)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(
        Offset(paddleCenterX, paddleCenterY),
        6,
        highlightPaint,
      );
      
      // Draw detected note
      final textPainter = TextPainter(
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      
      textPainter.text = TextSpan(
        text: detectedNote,
        style: TextStyle(
          color: color,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(center.dx - textPainter.width / 2, center.dy - textPainter.height - 8),
      );
      
      // Draw cents below note
      final centsText = tuningOffset > 0 
          ? '+${tuningOffset.toStringAsFixed(0)}¢'
          : '${tuningOffset.toStringAsFixed(0)}¢';
      
      textPainter.text = TextSpan(
        text: centsText,
        style: TextStyle(
          color: color,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(center.dx - textPainter.width / 2, center.dy + 8),
      );
    }
  }

  @override
  bool shouldRepaint(covariant TunerPainter oldDelegate) {
    return tuningOffset != oldDelegate.tuningOffset ||
        noteName != oldDelegate.noteName ||
        isListening != oldDelegate.isListening ||
        color != oldDelegate.color ||
        detectedNote != oldDelegate.detectedNote;
  }
}

// Custom audio source for in-memory WAV data
class WaveAudioSource extends StreamAudioSource {
  final Uint8List _buffer;

  WaveAudioSource(this._buffer);

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    start ??= 0;
    end ??= _buffer.length;

    return StreamAudioResponse(
      sourceLength: _buffer.length,
      contentLength: end - start,
      offset: start,
      stream: Stream.value(_buffer.sublist(start, end)),
      contentType: 'audio/wav',
    );
  }
}
