import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:just_audio/just_audio.dart';

class MetronomeScreen extends StatefulWidget {
  const MetronomeScreen({super.key});

  @override
  State<MetronomeScreen> createState() => _MetronomeScreenState();
}

class _MetronomeScreenState extends State<MetronomeScreen> with TickerProviderStateMixin {
  // State variables
  bool _isPlaying = false;
  final bool _isInitialized = true; // Always initialized since no audio loading needed
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
    {'name': 'Strong-Weak', 'pattern': [true, false]},
    {'name': 'Waltz', 'pattern': [true, false, false]},
    {'name': 'March', 'pattern': [true, false, true, false]},
    {'name': 'Complex', 'pattern': [true, false, true, false, false, true]},
    {'name': 'First Beat', 'pattern': []},
  ];

  String _selectedAccentPattern = 'Strong-Weak';

  // Audio players for ticks
  late AudioPlayer _tickPlayer;
  late AudioPlayer _accentPlayer;

  @override
  void initState() {
    super.initState();
    
    // Initialize audio players and preload assets
    _tickPlayer = AudioPlayer();
    _accentPlayer = AudioPlayer();
    _loadAudio();
    
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

  // Preload audio assets
  Future<void> _loadAudio() async {
    try {
      await _tickPlayer.setAsset('assets/audio/tick.wav');
      await _accentPlayer.setAsset('assets/audio/accent.wav');
    } catch (_) {
      // Ignore loading errors for now
    }
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
        
        _playSound(isAccent: isAccent);
        
        if (isAccent) {
          HapticFeedback.heavyImpact();
        } else {
          HapticFeedback.lightImpact();
        }
      } else {
        // Subdivision beat
        _playSound(isAccent: false);
        HapticFeedback.selectionClick();
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

  void _playSound({required bool isAccent}) {
    final player = isAccent ? _accentPlayer : _tickPlayer;
    try {
      player.seek(Duration.zero);
      if (!player.playing) {
        player.play();
      }
    } catch (_) {}
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
    _tickPlayer.dispose();
    _accentPlayer.dispose();
    super.dispose();
  }

  void _toggleMetronome() {
    if (!mounted) return;
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
            onPressed: _tapTempo,
            tooltip: 'Tap Tempo',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // BPM Display
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _bpm.toString(),
                          style: const TextStyle(
                            fontSize: 64,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'BPM',
                          style: TextStyle(
                            fontSize: 20,
                            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
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
                          fontSize: 16,
                          color: Color(0xFFD97706),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Visual metronome with enhanced pendulum
            Stack(
              children: [
                Card(
                  child: Container(
                    width: double.infinity,
                    height: 280, // Fixed height to prevent overflow
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Enhanced pendulum with base
                        Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            // Pendulum base
                            Container(
                              width: 50,
                              height: 16,
                              decoration: BoxDecoration(
                                color: const Color(0xFF374151),
                                borderRadius: BorderRadius.circular(8),
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
                                              width: 20,
                                              height: 20,
                                              decoration: BoxDecoration(
                                                color: _isPlaying 
                                                  ? const Color(0xFFD97706)
                                                  : const Color(0xFF6B7280),
                                                shape: BoxShape.circle,
                                                boxShadow: _isPlaying ? [
                                                  BoxShadow(
                                                    color: const Color(0xFFD97706).withOpacity(0.3),
                                                    blurRadius: 6,
                                                    spreadRadius: 1,
                                                  ),
                                                ] : null,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      // Pendulum rod
                                      Container(
                                        width: 3,
                                        height: 100,
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
                        const SizedBox(height: 24),
                        
                        // Enhanced beat indicators with subdivisions
                        Column(
                          children: [
                            // Main beats
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(_timeSignature, (index) {
                                  return AnimatedBuilder(
                                    animation: _beatController,
                                    builder: (context, child) {
                                      final currentMainBeat = (_currentBeat ~/ _subdivision) % _timeSignature;
                                      final isCurrentBeat = index == currentMainBeat;
                                      final isAccent = _shouldAccent(index);
                                      
                                      return Container(
                                        margin: const EdgeInsets.symmetric(horizontal: 4),
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: isCurrentBeat
                                              ? (isAccent ? const Color(0xFF6366F1) : const Color(0xFFD97706))
                                                  .withOpacity(1.0 - _beatController.value * 0.3)
                                              : Colors.white.withOpacity(0.1),
                                          border: Border.all(
                                            color: isAccent ? const Color(0xFF6366F1) : const Color(0xFFD97706),
                                            width: isAccent ? 2 : 1,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${index + 1}',
                                            style: TextStyle(
                                              color: isCurrentBeat 
                                                ? Theme.of(context).textTheme.bodyLarge?.color 
                                                : Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                                              fontSize: isAccent ? 16 : 14,
                                              fontWeight: isAccent ? FontWeight.bold : FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                }),
                              ),
                            ),
                            
                            // Subdivision indicators
                            if (_subdivision > 1) ...[
                              const SizedBox(height: 12),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
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
                                            width: 6,
                                            height: 6,
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
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // Floating play/pause button overlay
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _isPlaying ? Colors.red : const Color(0xFFD97706),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: _toggleMetronome,
                      icon: Icon(
                        _isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 24,
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
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () => _updateBpm(_bpm - 1),
                          icon: Icon(Icons.remove, color: Theme.of(context).iconTheme.color),
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
                          icon: Icon(Icons.add, color: Theme.of(context).iconTheme.color),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.1),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    // Common BPM presets
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: _commonBpms.map((bpm) {
                        return GestureDetector(
                          onTap: () => _updateBpm(bpm),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: bpm == _bpm ? const Color(0xFFD97706) : Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              bpm.toString(),
                              style: TextStyle(
                                color: bpm == _bpm ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                                fontSize: 10,
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
            
            const SizedBox(height: 16),
            
            // Subdivision selector
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    const Text(
                      'Note Subdivision',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
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
                            if (!mounted) return;
                            setState(() {
                              _subdivision = value;
                              _currentBeat = 0;
                            });
                            
                            // Restart metronome if playing to apply new subdivision
                            if (_isPlaying) {
                              _startMetronome();
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF6366F1) : Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              label,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                                fontSize: 20,
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
            const SizedBox(height: 12),
            
            // Time signature and accent pattern
            IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            const Text(
                              'Time Signature',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            SizedBox(
                              height: 60, // Reduced height to shrink card
                              child: GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 4,
                                  mainAxisSpacing: 4,
                                  crossAxisSpacing: 4,
                                  childAspectRatio: 1.2,
                                ),
                                itemCount: 8,
                                itemBuilder: (context, index) {
                                  final timeSignatures = [
                                    {'beats': 2, 'note': 4, 'display': '2/4'},
                                    {'beats': 3, 'note': 4, 'display': '3/4'},
                                    {'beats': 4, 'note': 4, 'display': '4/4'},
                                    {'beats': 5, 'note': 4, 'display': '5/4'},
                                    {'beats': 6, 'note': 4, 'display': '6/4'},
                                    {'beats': 3, 'note': 8, 'display': '3/8'},
                                    {'beats': 6, 'note': 8, 'display': '6/8'},
                                    {'beats': 12, 'note': 8, 'display': '12/8'},
                                  ];
                                  
                                  final timeSignature = timeSignatures[index];
                                  final beats = timeSignature['beats'] as int;
                                  final display = timeSignature['display'] as String;
                                  final isSelected = beats == _timeSignature;
                                  
                                  return GestureDetector(
                                    onTap: () => _updateTimeSignature(beats),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: isSelected ? const Color(0xFF6366F1) : Colors.white.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Center(
                                        child: Text(
                                          display,
                                          style: TextStyle(
                                            color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                                            fontSize: 10,
                                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            const Text(
                              'Accent Pattern',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            DropdownButton<String>(
                              alignment: Alignment.center,
                              value: _selectedAccentPattern,
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  if (!mounted) return;
                                  setState(() {
                                    _selectedAccentPattern = newValue;
                                  });
                                }
                              },
                              dropdownColor: const Color(0xFF1E1E3F),
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                              underline: Container(),
                              items: _accentPatterns.map<DropdownMenuItem<String>>((pattern) {
                                return DropdownMenuItem<String>(
                                  value: pattern['name'],
                                  child: Text(
                                    pattern['name'],
                                    style: const TextStyle(fontSize: 12),
                                  ),
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
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
} 