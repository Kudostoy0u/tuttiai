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
            expandedHeight: 200.0,
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
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(
                            'assets/tonic.webp',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  color: const Color(0xFF6366F1),
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
                childAspectRatio: 1,
              ),
              delegate: SliverChildListDelegate([
                _buildFeatureCard(
                  context,
                  'Sheet Music\nRecommendations',
                  Icons.library_music,
                  const Color(0xFF6366F1),
                  'AI-powered sheet music suggestions based on your skill level and preferences',
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
                  'Check and improve your pitch accuracy',
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
                  'Keep perfect time with our digital metronome',
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
                  'Record and organize your practice sessions',
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
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 