import 'package:flutter/material.dart';
import '../features/sheet_music_screen.dart';
import '../features/tuning_screen.dart';
import '../features/listen_screen.dart';
import '../features/metronome_screen.dart';
import '../features/recording_analyzer_screen.dart';
import '../features/community_videos_screen.dart';
import '../../widgets/theme_image.dart';

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
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
              centerTitle: false,
              title: const Text(
                'Tutti',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: Theme.of(context).brightness == Brightness.dark
                        ? [
                            const Color(0xFF0F0F23),
                            const Color(0xFF1E1E3F),
                          ]
                        : [
                            Colors.white,
                            Colors.grey[100]!,
                          ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: ClipOval(
                          child: ThemeImage(
                            lightImagePath: 'assets/tuttiicon.png',
                            width: 80,
                            height: 80,
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
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
              stretchModes: const [
                StretchMode.zoomBackground,
              ],
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
                  'Sheet Music\nFinder',
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
                  'Recording\nAnalyzer',
                  Icons.mic,
                  const Color(0xFF7C3AED),
                  'Record and analyze your practice sessions.',
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RecordingAnalyzerScreen()),
                  ),
                ),
                _buildFeatureCard(
                  context,
                  'Listen',
                  Icons.headphones,
                  const Color(0xFFDC2626),
                  'Hear pieces or play with accompaniment',
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ListenScreen()),
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
                  'Community\nVideos',
                  Icons.people,
                  const Color(0xFFEC4899),
                  'Get feedback from the community',
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CommunityVideosScreen()),
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
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Theme.of(context).brightness == Brightness.light
              ? Border.all(color: Colors.grey.withOpacity(0.3), width: 1)
              : null,
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black.withOpacity(0.3)
                  : Colors.grey.withOpacity(0.2),
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
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
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