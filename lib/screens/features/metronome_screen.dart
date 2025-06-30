import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math' as math;

class MetronomeScreen extends StatefulWidget {
  const MetronomeScreen({super.key});

  @override
  State<MetronomeScreen> createState() => _MetronomeScreenState();
}

class _MetronomeScreenState extends State<MetronomeScreen> with TickerProviderStateMixin {
  bool _isPlaying = false;
  int _bpm = 120;
  int _timeSignature = 4;
  int _currentBeat = 0;
  int _subdivision = 1; // 1 = quarter notes, 2 = eighth notes, 4 = sixteenth notes
  Timer? _timer;
  
  late AnimationController _beatController;
  late AnimationController _pendulumController;
  late AnimationController _visualBeatController;

  // Tap tempo variables
  final List<DateTime> _tapTimes = [];
  bool _showTapTempo = false;

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
    {'name': 'Strong-Weak', 'pattern': [true, false]},
    {'name': 'Waltz', 'pattern': [true, false, false]},
    {'name': 'March', 'pattern': [true, false, true, false]},
    {'name': 'Complex', 'pattern': [true, false, true, false, false, true]},
  ];

  String _selectedAccentPattern = 'None';

  @override
  void initState() {
    super.initState();
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

  @override
  void dispose() {
    _timer?.cancel();
    _beatController.dispose();
    _pendulumController.dispose();
    _visualBeatController.dispose();
    super.dispose();
  }

  void _toggleMetronome() {
    setState(() {
      _isPlaying = !_isPlaying;
    });

    if (_isPlaying) {
      _startMetronome();
    } else {
      _stopMetronome();
    }
  }

  void _startMetronome() {
    final beatInterval = Duration(milliseconds: (60000 / (_bpm * _subdivision)).round());
    _pendulumController.duration = Duration(milliseconds: (60000 / _bpm).round());
    _pendulumController.repeat();
    
    _timer = Timer.periodic(beatInterval, (timer) {
      final isMainBeat = (_currentBeat % _subdivision) == 0;
      final beatNumber = (_currentBeat ~/ _subdivision) % _timeSignature;
      
      setState(() {
        _currentBeat = (_currentBeat + 1) % (_timeSignature * _subdivision);
      });

      if (isMainBeat) {
        _beatController.forward().then((_) => _beatController.reverse());
        _playBeatSound(beatNumber == 0); // Accent on first beat
      }
      
      _visualBeatController.forward().then((_) => _visualBeatController.reverse());
      
      // Haptic feedback on accented beats
      if (isMainBeat && (beatNumber == 0 || _shouldAccent(beatNumber))) {
        HapticFeedback.lightImpact();
      }
    });
  }

  void _stopMetronome() {
    _timer?.cancel();
    _pendulumController.stop();
    _pendulumController.reset();
    _visualBeatController.reset();
    setState(() {
      _currentBeat = 0;
    });
  }

  void _playBeatSound(bool isAccent) {
    // Simulate playing metronome sound
    // In a real app, you would play actual audio files here
    if (isAccent) {
      // High-pitched click for accent
      HapticFeedback.mediumImpact();
    } else {
      // Regular click
      HapticFeedback.selectionClick();
    }
  }

  bool _shouldAccent(int beatNumber) {
    final pattern = _accentPatterns.firstWhere(
      (p) => p['name'] == _selectedAccentPattern,
      orElse: () => _accentPatterns.first,
    )['pattern'] as List<bool>;
    
    if (pattern.isEmpty) return false;
    return pattern[beatNumber % pattern.length];
  }

  void _updateBpm(int newBpm) {
    setState(() {
      _bpm = newBpm.clamp(40, 300);
    });
    
    if (_isPlaying) {
      _stopMetronome();
      _startMetronome();
    }
  }

  void _tapTempo() {
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
            icon: const Icon(Icons.touch_app, color: Colors.white),
            onPressed: () {
              setState(() {
                _showTapTempo = !_showTapTempo;
              });
            },
            tooltip: 'Tap Tempo',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // BPM Display
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _bpm.toString(),
                          style: const TextStyle(
                            fontSize: 72,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          'BPM',
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD97706).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        _getTempoMarking(),
                        style: const TextStyle(
                          fontSize: 18,
                          color: Color(0xFFD97706),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Visual metronome with enhanced pendulum
            Expanded(
              child: Card(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Enhanced pendulum with base
                      Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          // Pendulum base
                          Container(
                            width: 60,
                            height: 20,
                            decoration: BoxDecoration(
                              color: const Color(0xFF374151),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          // Pendulum rod and bob
                          AnimatedBuilder(
                            animation: _pendulumController,
                            builder: (context, child) {
                              final angle = _isPlaying 
                                ? math.sin(_pendulumController.value * 2 * math.pi) * 0.5
                                : 0.0;
                              return Transform.rotate(
                                angle: angle,
                                alignment: Alignment.bottomCenter,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Pendulum bob
                                    AnimatedBuilder(
                                      animation: _visualBeatController,
                                      builder: (context, child) {
                                        final scale = 1.0 + _visualBeatController.value * 0.2;
                                        return Transform.scale(
                                          scale: scale,
                                          child: Container(
                                            width: 24,
                                            height: 24,
                                            decoration: BoxDecoration(
                                              color: _isPlaying 
                                                ? const Color(0xFFD97706)
                                                : const Color(0xFF6B7280),
                                              shape: BoxShape.circle,
                                              boxShadow: _isPlaying ? [
                                                BoxShadow(
                                                  color: const Color(0xFFD97706).withOpacity(0.3),
                                                  blurRadius: 8,
                                                  spreadRadius: 2,
                                                ),
                                              ] : null,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    // Pendulum rod
                                    Container(
                                      width: 4,
                                      height: 120,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF6B7280),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      
                      // Enhanced beat indicators with subdivisions
                      Column(
                        children: [
                          // Main beats
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(_timeSignature, (index) {
                              return AnimatedBuilder(
                                animation: _beatController,
                                builder: (context, child) {
                                  final currentMainBeat = (_currentBeat ~/ _subdivision) % _timeSignature;
                                  final isCurrentBeat = index == currentMainBeat;
                                  final isAccent = index == 0 || _shouldAccent(index);
                                  
                                  return Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 6),
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isCurrentBeat
                                          ? (isAccent ? const Color(0xFF6366F1) : const Color(0xFFD97706))
                                              .withOpacity(1.0 - _beatController.value * 0.3)
                                          : Colors.white.withOpacity(0.1),
                                      border: Border.all(
                                        color: isAccent ? const Color(0xFF6366F1) : const Color(0xFFD97706),
                                        width: isAccent ? 3 : 2,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${index + 1}',
                                        style: TextStyle(
                                          color: isCurrentBeat ? Colors.white : Colors.white60,
                                          fontSize: isAccent ? 18 : 16,
                                          fontWeight: isAccent ? FontWeight.bold : FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            }),
                          ),
                          
                          // Subdivision indicators
                          if (_subdivision > 1) ...[
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(_subdivision * _timeSignature, (index) {
                                return AnimatedBuilder(
                                  animation: _visualBeatController,
                                  builder: (context, child) {
                                    final isCurrentSubdivision = index == _currentBeat;
                                    final scale = isCurrentSubdivision 
                                      ? 1.0 + _visualBeatController.value * 0.5
                                      : 1.0;
                                    
                                    return Transform.scale(
                                      scale: scale,
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(horizontal: 2),
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: isCurrentSubdivision
                                              ? const Color(0xFFD97706)
                                              : Colors.white.withOpacity(0.3),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Subdivision selector
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'Note Subdivision',
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
                        {'value': 1, 'label': '♩'},
                        {'value': 2, 'label': '♫'},
                        {'value': 4, 'label': '♬'},
                      ].map((subdivision) {
                        final value = subdivision['value'] as int;
                        final label = subdivision['label'] as String;
                        final isSelected = value == _subdivision;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _subdivision = value;
                              _currentBeat = 0;
                            });
                            if (_isPlaying) {
                              _stopMetronome();
                              _startMetronome();
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF6366F1) : Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              label,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.white70,
                                fontSize: 24,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Time signature and accent pattern
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Text(
                            'Time Signature',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            children: [2, 3, 4, 5, 6].map((beats) {
                              final isSelected = beats == _timeSignature;
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _timeSignature = beats;
                                    _currentBeat = 0;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: isSelected ? const Color(0xFF6366F1) : Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '$beats/4',
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : Colors.white70,
                                      fontSize: 12,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Text(
                            'Accent Pattern',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButton<String>(
                            value: _selectedAccentPattern,
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _selectedAccentPattern = newValue;
                                });
                              }
                            },
                            dropdownColor: const Color(0xFF1E1E3F),
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                            underline: Container(),
                            items: _accentPatterns.map<DropdownMenuItem<String>>((pattern) {
                              return DropdownMenuItem<String>(
                                value: pattern['name'],
                                child: Text(pattern['name']),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // BPM controls
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () => _updateBpm(_bpm - 1),
                          icon: const Icon(Icons.remove, color: Colors.white),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        Expanded(
                          child: Slider(
                            value: _bpm.toDouble(),
                            min: 40,
                            max: 300,
                            divisions: 260,
                            activeColor: const Color(0xFFD97706),
                            inactiveColor: Colors.white.withOpacity(0.3),
                            onChanged: (value) => _updateBpm(value.round()),
                          ),
                        ),
                        IconButton(
                          onPressed: () => _updateBpm(_bpm + 1),
                          icon: const Icon(Icons.add, color: Colors.white),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.1),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    // Common BPM presets
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: _commonBpms.map((bpm) {
                        return GestureDetector(
                          onTap: () => _updateBpm(bpm),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: bpm == _bpm ? const Color(0xFFD97706) : Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              bpm.toString(),
                              style: TextStyle(
                                color: bpm == _bpm ? Colors.white : Colors.white70,
                                fontSize: 11,
                                fontWeight: bpm == _bpm ? FontWeight.bold : FontWeight.normal,
                              ),
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
                if (_showTapTempo) ...[
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _tapTempo,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF059669),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.touch_app, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Tap Tempo',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                Expanded(
                  flex: _showTapTempo ? 2 : 1,
                  child: ElevatedButton(
                    onPressed: _toggleMetronome,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isPlaying ? Colors.red : const Color(0xFFD97706),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isPlaying ? Icons.stop : Icons.play_arrow,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _isPlaying ? 'Stop' : 'Start',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
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
} 