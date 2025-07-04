import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/localization_service.dart';
import '../features/sheet_music_screen.dart';
import '../features/tuning_screen.dart';
import '../features/listen_screen.dart';
import '../features/metronome_screen.dart';
import '../features/recording_analyzer_screen.dart';
import '../features/community_videos_screen.dart';
import '../../widgets/theme_image.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final settings = Provider.of<SettingsProvider>(context);
    final user = authProvider.currentUser;
    
    String displayName = 'Guest';
    if (user != null) {
      // Prioritize profile name, fallback to metadata
      displayName = authProvider.userProfile['name'] ?? user.userMetadata?['name'] ?? user.email ?? 'Musician';
    }
    final String firstName = displayName.split(' ').first;

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
              title: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${LocalizationService.translate('welcome_back', settings.language)}, $firstName',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.local_fire_department,
                        color: Colors.amber,
                        size: 14,
                      ),
                      SizedBox(width: 4),
                      Builder(builder:(context){final lang=Provider.of<SettingsProvider>(context).language;return Text(
                        '12 ${LocalizationService.translate('days_unit', lang)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      );}),
                      SizedBox(width: 16),
                      Icon(
                        Icons.hourglass_bottom,
                        color: Colors.lightBlue,
                        size: 12,
                      ),
                      SizedBox(width: 4),
                      Builder(builder:(context){final lang=Provider.of<SettingsProvider>(context).language;return Text(
                        '3${LocalizationService.translate('h_unit', lang)} 45${LocalizationService.translate('m_unit', lang)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      );}),
                    ],
                  ),
                ],
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
                      const SizedBox(height: 40),
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
                childAspectRatio: 1.1,
              ),
              delegate: SliverChildListDelegate([
                _buildFeatureCard(
                  context,
                  LocalizationService.translate('sheet_music_finder', settings.language),
                  Icons.library_music,
                  const Color(0xFF6366F1),
                  LocalizationService.translate('sheet_music_desc', settings.language),
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SheetMusicScreen()),
                  ),
                ),
                _buildFeatureCard(
                  context,
                  LocalizationService.translate('recording_analyzer', settings.language),
                  Icons.mic,
                  const Color(0xFF7C3AED),
                  LocalizationService.translate('recording_desc', settings.language),
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RecordingAnalyzerScreen()),
                  ),
                ),
                _buildFeatureCard(
                  context,
                  LocalizationService.translate('listen', settings.language),
                  Icons.headphones,
                  const Color(0xFFDC2626),
                  LocalizationService.translate('listen_desc', settings.language),
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ListenScreen()),
                  ),
                ),
                _buildFeatureCard(
                  context,
                  LocalizationService.translate('metronome_feature', settings.language),
                  Icons.timer,
                  const Color(0xFFD97706),
                  LocalizationService.translate('metronome_desc', settings.language),
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MetronomeScreen()),
                  ),
                ),
                _buildFeatureCard(
                  context,
                  LocalizationService.translate('tuning_feature', settings.language),
                  Icons.tune,
                  const Color(0xFF059669),
                  LocalizationService.translate('tuning_desc', settings.language),
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TuningScreen()),
                  ),
                ),
                _buildFeatureCard(
                  context,
                  LocalizationService.translate('community_videos', settings.language),
                  Icons.people,
                  const Color(0xFFEC4899),
                  LocalizationService.translate('community_desc', settings.language),
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
              ? Border.all(color: Colors.grey.withAlpha(77), width: 1)
              : null,
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black.withAlpha(77)
                  : Colors.grey.withAlpha(51),
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
                  color: color.withAlpha(51),
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
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(179),
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