import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:async';

class TuningScreen extends StatefulWidget {
  const TuningScreen({super.key});

  @override
  State<TuningScreen> createState() => _TuningScreenState();
}

class _TuningScreenState extends State<TuningScreen> with TickerProviderStateMixin {
  bool _isListening = false;
  bool _isPlayingReference = false;
  String _currentNote = 'A4';
  double _frequency = 440.0;
  double _cents = 0.0;
  String _selectedInstrument = 'Guitar';
  double _confidence = 0.0;
  Timer? _tuningTimer;
  
  late AnimationController _pulseController;
  late AnimationController _needleController;
  late AnimationController _confidenceController;

  final List<String> _instruments = ['Guitar', 'Piano', 'Violin', 'Ukulele', 'Bass', 'Cello'];
  
  final Map<String, List<Map<String, dynamic>>> _instrumentNotes = {
    'Guitar': [
      {'note': 'E2', 'frequency': 82.41, 'string': '6th'},
      {'note': 'A2', 'frequency': 110.00, 'string': '5th'},
      {'note': 'D3', 'frequency': 146.83, 'string': '4th'},
      {'note': 'G3', 'frequency': 196.00, 'string': '3rd'},
      {'note': 'B3', 'frequency': 246.94, 'string': '2nd'},
      {'note': 'E4', 'frequency': 329.63, 'string': '1st'},
    ],
    'Piano': [
      {'note': 'C4', 'frequency': 261.63, 'string': 'Middle C'},
      {'note': 'D4', 'frequency': 293.66, 'string': 'D'},
      {'note': 'E4', 'frequency': 329.63, 'string': 'E'},
      {'note': 'F4', 'frequency': 349.23, 'string': 'F'},
      {'note': 'G4', 'frequency': 392.00, 'string': 'G'},
      {'note': 'A4', 'frequency': 440.00, 'string': 'A'},
      {'note': 'B4', 'frequency': 493.88, 'string': 'B'},
    ],
    'Violin': [
      {'note': 'G3', 'frequency': 196.00, 'string': 'G'},
      {'note': 'D4', 'frequency': 293.66, 'string': 'D'},
      {'note': 'A4', 'frequency': 440.00, 'string': 'A'},
      {'note': 'E5', 'frequency': 659.25, 'string': 'E'},
    ],
    'Ukulele': [
      {'note': 'G4', 'frequency': 392.00, 'string': '4th'},
      {'note': 'C4', 'frequency': 261.63, 'string': '3rd'},
      {'note': 'E4', 'frequency': 329.63, 'string': '2nd'},
      {'note': 'A4', 'frequency': 440.00, 'string': '1st'},
    ],
    'Bass': [
      {'note': 'E1', 'frequency': 41.20, 'string': '4th'},
      {'note': 'A1', 'frequency': 55.00, 'string': '3rd'},
      {'note': 'D2', 'frequency': 73.42, 'string': '2nd'},
      {'note': 'G2', 'frequency': 98.00, 'string': '1st'},
    ],
    'Cello': [
      {'note': 'C2', 'frequency': 65.41, 'string': 'C'},
      {'note': 'G2', 'frequency': 98.00, 'string': 'G'},
      {'note': 'D3', 'frequency': 146.83, 'string': 'D'},
      {'note': 'A3', 'frequency': 220.00, 'string': 'A'},
    ],
  };

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _needleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _confidenceController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // Initialize with first note of selected instrument
    if (_instrumentNotes[_selectedInstrument]!.isNotEmpty) {
      final firstNote = _instrumentNotes[_selectedInstrument]!.first;
      _currentNote = firstNote['note'];
      _frequency = firstNote['frequency'];
    }
  }

  @override
  void dispose() {
    _tuningTimer?.cancel();
    _pulseController.dispose();
    _needleController.dispose();
    _confidenceController.dispose();
    super.dispose();
  }

  void _toggleListening() {
    setState(() {
      _isListening = !_isListening;
    });
    
    if (_isListening) {
      _pulseController.repeat();
      _startTuning();
    } else {
      _stopTuning();
    }
  }

  void _startTuning() {
    _tuningTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_isListening) {
        _simulateFrequencyDetection();
      }
    });
  }

  void _stopTuning() {
    _tuningTimer?.cancel();
    _pulseController.stop();
    _pulseController.reset();
    setState(() {
      _confidence = 0.0;
    });
    _confidenceController.reset();
  }

  void _simulateFrequencyDetection() {
    // Get target frequency for current note
    final targetNote = _instrumentNotes[_selectedInstrument]!
        .firstWhere((note) => note['note'] == _currentNote);
    final targetFrequency = targetNote['frequency'] as double;
    
    // Simulate frequency detection with some variation
    final variation = (math.Random().nextDouble() - 0.5) * 30; // ±15 Hz variation
    final detectedFrequency = targetFrequency + variation;
    
    // Calculate cents difference
    final cents = 1200 * math.log(detectedFrequency / targetFrequency) / math.ln2;
    
    // Simulate confidence based on how close we are to target
    final maxConfidence = 1.0 - (cents.abs() / 50).clamp(0.0, 1.0);
    final confidence = maxConfidence * (0.7 + math.Random().nextDouble() * 0.3);
    
    setState(() {
      _frequency = detectedFrequency;
      _cents = cents;
      _confidence = confidence;
    });
    
    // Animate needle
    _needleController.animateTo(
      (cents.clamp(-50, 50) + 50) / 100,
      duration: const Duration(milliseconds: 200),
    );
    
    // Animate confidence
    _confidenceController.animateTo(confidence);
  }

  void _playReferenceNote() async {
    if (_isPlayingReference) return;
    
    setState(() => _isPlayingReference = true);
    
    // Show visual feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.volume_up, color: Colors.white),
            const SizedBox(width: 8),
            Text('Playing $_currentNote reference tone'),
          ],
        ),
        backgroundColor: const Color(0xFF6366F1),
        duration: const Duration(seconds: 2),
      ),
    );
    
    // Simulate playing reference note for 2 seconds
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      setState(() => _isPlayingReference = false);
    }
  }

  void _selectNote(String note) {
    final noteData = _instrumentNotes[_selectedInstrument]!
        .firstWhere((n) => n['note'] == note);
    
    setState(() {
      _currentNote = note;
      _frequency = noteData['frequency'];
      _cents = 0.0;
      _confidence = 0.0;
    });
    
    _needleController.reset();
    _confidenceController.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tuning',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF0F0F23),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isPlayingReference ? Icons.volume_up : Icons.volume_off,
              color: _isPlayingReference ? const Color(0xFF6366F1) : Colors.white,
            ),
            onPressed: _playReferenceNote,
            tooltip: 'Play reference note',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Instrument selector
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.music_note, color: Color(0xFF6366F1)),
                    const SizedBox(width: 12),
                    const Text(
                      'Instrument:',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    DropdownButton<String>(
                      value: _selectedInstrument,
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedInstrument = newValue;
                            // Reset to first note of new instrument
                            final firstNote = _instrumentNotes[newValue]!.first;
                            _currentNote = firstNote['note'];
                            _frequency = firstNote['frequency'];
                            _cents = 0.0;
                            _confidence = 0.0;
                          });
                          _needleController.reset();
                          _confidenceController.reset();
                        }
                      },
                      dropdownColor: const Color(0xFF1E1E3F),
                      style: const TextStyle(color: Colors.white),
                      items: _instruments.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Tuning display
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Current note display with confidence indicator
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Confidence ring
                        AnimatedBuilder(
                          animation: _confidenceController,
                          builder: (context, child) {
                            return Container(
                              width: 220,
                              height: 220,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF6366F1).withOpacity(0.3),
                                  width: 2,
                                ),
                              ),
                              child: CircularProgressIndicator(
                                value: _confidenceController.value,
                                strokeWidth: 8,
                                backgroundColor: Colors.transparent,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  _getTuningColor().withOpacity(0.8),
                                ),
                              ),
                            );
                          },
                        ),
                        // Main note circle
                        AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            return Container(
                              width: 200,
                              height: 200,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _getTuningColor().withOpacity(0.1),
                                border: Border.all(
                                  color: _isListening 
                                      ? Color.lerp(
                                          _getTuningColor(),
                                          _getTuningColor().withOpacity(0.3),
                                          _pulseController.value,
                                        )!
                                      : _getTuningColor().withOpacity(0.3),
                                  width: 3,
                                ),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _currentNote,
                                      style: const TextStyle(
                                        fontSize: 48,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      '${_frequency.toStringAsFixed(1)} Hz',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.white70,
                                      ),
                                    ),
                                    if (_isListening) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        'Confidence: ${(_confidence * 100).toStringAsFixed(0)}%',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: _getTuningColor(),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    
                    // Enhanced tuning meter
                    SizedBox(
                      width: 320,
                      height: 120,
                      child: CustomPaint(
                        painter: EnhancedTuningMeterPainter(
                          cents: _cents,
                          needleAnimation: _needleController,
                          isListening: _isListening,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Cents value and status
                    Column(
                      children: [
                        Text(
                          '${_cents.toStringAsFixed(1)} cents',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: _getTuningColor(),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: _getTuningColor().withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _getTuningStatus(),
                            style: TextStyle(
                              fontSize: 16,
                              color: _getTuningColor(),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            // String/Note selector
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_selectedInstrument} Strings',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'Target: ${_instrumentNotes[_selectedInstrument]!.firstWhere((n) => n['note'] == _currentNote)['frequency'].toStringAsFixed(1)} Hz',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _instrumentNotes[_selectedInstrument]!.map((noteData) {
                        final note = noteData['note'] as String;
                        final string = noteData['string'] as String;
                        final isSelected = note == _currentNote;
                        return GestureDetector(
                          onTap: () => _selectNote(note),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF6366F1)
                                  : Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  note,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : Colors.white70,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  string,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white70 : Colors.white60,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Control buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _playReferenceNote,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD97706),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(_isPlayingReference ? Icons.volume_up : Icons.play_arrow),
                        const SizedBox(width: 8),
                        Text(
                          _isPlayingReference ? 'Playing...' : 'Reference',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _toggleListening,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isListening ? Colors.red : const Color(0xFF6366F1),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(_isListening ? Icons.stop : Icons.mic, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          _isListening ? 'Stop Listening' : 'Start Tuning',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getTuningColor() {
    if (_cents.abs() < 5) return const Color(0xFF059669); // Green - in tune
    if (_cents.abs() < 15) return const Color(0xFFD97706); // Orange - close
    return const Color(0xFFDC2626); // Red - out of tune
  }

  String _getTuningStatus() {
    if (_cents.abs() < 5) return 'In Tune ♪';
    if (_cents.abs() < 15) {
      return _cents > 0 ? 'Slightly Sharp ↑' : 'Slightly Flat ↓';
    }
    return _cents > 0 ? 'Too Sharp ↑↑' : 'Too Flat ↓↓';
  }
}

class EnhancedTuningMeterPainter extends CustomPainter {
  final double cents;
  final Animation<double> needleAnimation;
  final bool isListening;

  EnhancedTuningMeterPainter({
    required this.cents,
    required this.needleAnimation,
    required this.isListening,
  }) : super(repaint: needleAnimation);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 30;

    // Draw meter background
    final backgroundPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi * 0.75,
      math.pi * 1.5,
      false,
      backgroundPaint,
    );

    // Draw colored sections
    final sectionPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10;

    // Red sections (very out of tune)
    sectionPaint.color = const Color(0xFFDC2626);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi * 0.75,
      math.pi * 0.3,
      false,
      sectionPaint,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi * 0.45,
      math.pi * 0.3,
      false,
      sectionPaint,
    );

    // Orange sections (close)
    sectionPaint.color = const Color(0xFFD97706);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi * 0.45,
      math.pi * 0.25,
      false,
      sectionPaint,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi * 0.2,
      math.pi * 0.25,
      false,
      sectionPaint,
    );

    // Green section (in tune)
    sectionPaint.color = const Color(0xFF059669);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi * 0.2,
      math.pi * 0.4,
      false,
      sectionPaint,
    );

    // Draw tick marks
    final tickPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2;

    for (int i = -50; i <= 50; i += 10) {
      final angle = (i / 50) * math.pi * 0.6;
      final isMainTick = i % 20 == 0;
      final tickLength = isMainTick ? 15.0 : 8.0;
      
      final startRadius = radius - 5;
      final endRadius = radius - 5 - tickLength;
      
      final start = Offset(
        center.dx + math.cos(angle) * startRadius,
        center.dy + math.sin(angle) * startRadius,
      );
      final end = Offset(
        center.dx + math.cos(angle) * endRadius,
        center.dy + math.sin(angle) * endRadius,
      );
      
      canvas.drawLine(start, end, tickPaint);
      
      // Draw tick labels for main ticks
      if (isMainTick && i != 0) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: '${i > 0 ? '+' : ''}$i',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        
        final textOffset = Offset(
          center.dx + math.cos(angle) * (endRadius - 15) - textPainter.width / 2,
          center.dy + math.sin(angle) * (endRadius - 15) - textPainter.height / 2,
        );
        
        textPainter.paint(canvas, textOffset);
      }
    }

    // Draw center marker
    final centerPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3;
      
    canvas.drawLine(
      Offset(center.dx, center.dy + radius - 5),
      Offset(center.dx, center.dy + radius - 20),
      centerPaint,
    );

    // Draw needle
    if (isListening) {
      final needleAngle = (needleAnimation.value - 0.5) * math.pi * 1.2;
      final needlePaint = Paint()
        ..color = Colors.white
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round;

      final needleEnd = Offset(
        center.dx + math.cos(needleAngle) * (radius - 20),
        center.dy + math.sin(needleAngle) * (radius - 20),
      );

      canvas.drawLine(center, needleEnd, needlePaint);

      // Draw needle center circle
      final centerCirclePaint = Paint()
        ..color = const Color(0xFF6366F1)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(center, 6, centerCirclePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
} 