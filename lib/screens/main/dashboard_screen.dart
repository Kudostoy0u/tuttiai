import 'package:flutter/material.dart';
import '../features/sheet_music_screen.dart';
import '../features/tuning_screen.dart';
import '../features/intonation_screen.dart';
import '../features/metronome_screen.dart';
import '../features/recording_library_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF0F0F23),
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'TuttiAI',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF0F0F23),
                      Color(0xFF1E1E3F),
                    ],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 60), // Account for status bar
                      Container(
                        width: 80,
                        height: 80,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/tonic.jpg',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFF6366F1),
                                ),
                                child: const Icon(
                                  Icons.music_note,
                                  size: 40,
                                  color: Colors.white,
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
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1, // Slightly taller cards to accommodate text
              ),
              delegate: SliverChildListDelegate([
                _buildFeatureCard(
                  context,
                  'Sheet Music\nRecommendations',
                  Icons.library_music,
                  const Color(0xFF6366F1),
                  'AI-powered sheet music suggestions',
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SheetMusicScreen()),
                  ),
                ),
                _buildFeatureCard(
                  context,
                  'Tuning',
                  Icons.tune,
                  const Color(0xFF059669),
                  'Tune your instrument with precision',
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TuningScreen()),
                  ),
                ),
                _buildFeatureCard(
                  context,
                  'Intonation\nChecker',
                  Icons.graphic_eq,
                  const Color(0xFFDC2626),
                  'Check pitch accuracy',
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const IntonationScreen()),
                  ),
                ),
                _buildFeatureCard(
                  context,
                  'Metronome',
                  Icons.timer,
                  const Color(0xFFD97706),
                  'Keep perfect time',
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MetronomeScreen()),
                  ),
                ),
                _buildFeatureCard(
                  context,
                  'Recording\nLibrary',
                  Icons.mic,
                  const Color(0xFF7C3AED),
                  'Record practice sessions',
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RecordingLibraryScreen()),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    String description,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E3F),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 28,
                  color: color,
                ),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 6),
              Flexible(
                child: Text(
                  description,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.7),
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 