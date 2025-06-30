import 'package:flutter/material.dart';
import 'dart:math' as math;

class IntonationScreen extends StatefulWidget {
  const IntonationScreen({super.key});

  @override
  State<IntonationScreen> createState() => _IntonationScreenState();
}

class _IntonationScreenState extends State<IntonationScreen> with TickerProviderStateMixin {
  bool _isRecording = false;
  final List<double> _pitchData = [];
  double _currentPitch = 0.0;
  final double _targetPitch = 440.0;
  String _selectedScale = 'C Major';
  
  late AnimationController _waveController;
  late AnimationController _recordingController;

  final List<String> _scales = [
    'C Major', 'G Major', 'D Major', 'A Major', 'E Major', 'B Major',
    'F# Major', 'C# Major', 'F Major', 'Bb Major', 'Eb Major', 'Ab Major',
    'Db Major', 'Gb Major', 'Cb Major'
  ];

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _recordingController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _waveController.dispose();
    _recordingController.dispose();
    super.dispose();
  }

  void _toggleRecording() {
    setState(() {
      _isRecording = !_isRecording;
    });
    
    if (_isRecording) {
      _recordingController.repeat();
      _waveController.repeat();
      _startMockAnalysis();
    } else {
      _recordingController.stop();
      _waveController.stop();
    }
  }

  void _startMockAnalysis() {
    // Mock pitch analysis
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_isRecording) {
        setState(() {
          _currentPitch = _targetPitch + (math.Random().nextDouble() - 0.5) * 50;
          _pitchData.add(_currentPitch);
          if (_pitchData.length > 200) {
            _pitchData.removeAt(0);
          }
        });
        _startMockAnalysis();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Intonation Checker',
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Scale selector
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.piano, color: Color(0xFFDC2626)),
                    const SizedBox(width: 12),
                    const Text(
                      'Scale:',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    DropdownButton<String>(
                      value: _selectedScale,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedScale = newValue!;
                        });
                      },
                      dropdownColor: const Color(0xFF1E1E3F),
                      style: const TextStyle(color: Colors.white),
                      items: _scales.map<DropdownMenuItem<String>>((String value) {
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
            
            // Pitch visualization
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        'Pitch Analysis',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Current pitch display
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              const Text(
                                'Target',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                '${_targetPitch.toStringAsFixed(1)} Hz',
                                style: const TextStyle(
                                  color: Color(0xFF6366F1),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              const Text(
                                'Current',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                '${_currentPitch.toStringAsFixed(1)} Hz',
                                style: TextStyle(
                                  color: _getPitchColor(),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              const Text(
                                'Difference',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                '${(_currentPitch - _targetPitch).toStringAsFixed(1)} Hz',
                                style: TextStyle(
                                  color: _getPitchColor(),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Pitch graph
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: AnimatedBuilder(
                            animation: _waveController,
                            builder: (context, child) {
                              return CustomPaint(
                                painter: PitchGraphPainter(
                                  pitchData: _pitchData,
                                  targetPitch: _targetPitch,
                                  animation: _waveController,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Statistics
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'Session Statistics',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatItem('Accuracy', '${_getAccuracy().toStringAsFixed(1)}%'),
                        _buildStatItem('Avg Deviation', '${_getAverageDeviation().toStringAsFixed(1)} Hz'),
                        _buildStatItem('Duration', '${_getDuration()}s'),
                      ],
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
                    onPressed: () {
                      setState(() {
                        _pitchData.clear();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Clear'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: AnimatedBuilder(
                    animation: _recordingController,
                    builder: (context, child) {
                      return ElevatedButton(
                        onPressed: _toggleRecording,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isRecording 
                              ? Color.lerp(
                                  Colors.red,
                                  Colors.red.withOpacity(0.7),
                                  _recordingController.value,
                                )
                              : const Color(0xFFDC2626),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(_isRecording ? Icons.stop : Icons.mic),
                            const SizedBox(width: 8),
                            Text(
                              _isRecording ? 'Stop Analysis' : 'Start Analysis',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getPitchColor() {
    final diff = (_currentPitch - _targetPitch).abs();
    if (diff < 5) return const Color(0xFF059669);
    if (diff < 15) return const Color(0xFFD97706);
    return const Color(0xFFDC2626);
  }

  double _getAccuracy() {
    if (_pitchData.isEmpty) return 0.0;
    int accurate = 0;
    for (double pitch in _pitchData) {
      if ((pitch - _targetPitch).abs() < 10) accurate++;
    }
    return (accurate / _pitchData.length) * 100;
  }

  double _getAverageDeviation() {
    if (_pitchData.isEmpty) return 0.0;
    double sum = 0.0;
    for (double pitch in _pitchData) {
      sum += (pitch - _targetPitch).abs();
    }
    return sum / _pitchData.length;
  }

  String _getDuration() {
    return (_pitchData.length * 0.1).toStringAsFixed(1);
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class PitchGraphPainter extends CustomPainter {
  final List<double> pitchData;
  final double targetPitch;
  final Animation<double> animation;

  PitchGraphPainter({
    required this.pitchData,
    required this.targetPitch,
    required this.animation,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    if (pitchData.isEmpty) return;

    // Draw target line
    final targetPaint = Paint()
      ..color = const Color(0xFF6366F1)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final targetY = size.height / 2;
    canvas.drawLine(
      Offset(0, targetY),
      Offset(size.width, targetY),
      targetPaint,
    );

    // Draw pitch data
    final pitchPaint = Paint()
      ..color = const Color(0xFFDC2626)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    if (pitchData.length > 1) {
      final path = Path();
      final stepX = size.width / (pitchData.length - 1);
      
      for (int i = 0; i < pitchData.length; i++) {
        final x = i * stepX;
        final normalizedPitch = (pitchData[i] - targetPitch) / 100;
        final y = targetY - (normalizedPitch * size.height * 0.3);
        
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      
      canvas.drawPath(path, pitchPaint);
    }

    // Draw accuracy zones
    final zonePaint = Paint()
      ..style = PaintingStyle.fill;

    // Green zone (accurate)
    zonePaint.color = const Color(0xFF059669).withOpacity(0.1);
    canvas.drawRect(
      Rect.fromLTWH(0, targetY - 20, size.width, 40),
      zonePaint,
    );

    // Orange zone (close)
    zonePaint.color = const Color(0xFFD97706).withOpacity(0.1);
    canvas.drawRect(
      Rect.fromLTWH(0, targetY - 40, size.width, 20),
      zonePaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(0, targetY + 20, size.width, 20),
      zonePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
} 