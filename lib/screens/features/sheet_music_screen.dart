import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/localization_service.dart';

class SheetMusicScreen extends StatefulWidget {
  const SheetMusicScreen({super.key});

  @override
  State<SheetMusicScreen> createState() => _SheetMusicScreenState();
}

class _SheetMusicScreenState extends State<SheetMusicScreen> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _recommendations = [];

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    setState(() => _isLoading = true);
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    
    // Mock data
    _recommendations = [
      {
        'title': 'Moonlight Sonata',
        'composer': 'Ludwig van Beethoven',
        'difficulty': 'Intermediate',
        'genre': 'Classical',
        'rating': 4.8,
        'match': 95,
        'description': 'Perfect for practicing expressive playing',
      },
      {
        'title': 'Clair de Lune',
        'composer': 'Claude Debussy',
        'difficulty': 'Advanced',
        'genre': 'Impressionist',
        'rating': 4.9,
        'match': 92,
        'description': 'Excellent for developing touch sensitivity',
      },
      {
        'title': 'Autumn Leaves',
        'composer': 'Joseph Kosma',
        'difficulty': 'Beginner',
        'genre': 'Jazz',
        'rating': 4.6,
        'match': 88,
        'description': 'Great for learning jazz harmony',
      },
    ];
    
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Builder(builder: (context){final lang=Provider.of<SettingsProvider>(context).language;return Text(LocalizationService.translate('sheet_music_finder_title', lang),style: const TextStyle(fontWeight: FontWeight.bold));}),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                  ),
                  const SizedBox(height: 16),
                  Builder(builder:(context){final lang=Provider.of<SettingsProvider>(context).language;return Text(
                    LocalizationService.translate('ai_analyzing_prefs', lang),
                    style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(179)),
                  );}),
                ],
              ),
            )
          : Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.auto_awesome,
                            color: Color(0xFF6366F1),
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Builder(builder:(context){final lang=Provider.of<SettingsProvider>(context).language;return Text(
                            LocalizationService.translate('personalized_for_you', lang),
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          );}),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Builder(builder:(context){final lang=Provider.of<SettingsProvider>(context).language;return Text(
                        LocalizationService.translate('based_on_skill', lang),
                        style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(179)),
                      );}),
                    ],
                  ),
                ),
                
                // Recommendations list
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                    itemCount: _recommendations.length,
                    itemBuilder: (context, index) {
                      final recommendation = _recommendations[index];
                      return _buildRecommendationCard(recommendation);
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadRecommendations,
        backgroundColor: const Color(0xFF6366F1),
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }

  Widget _buildRecommendationCard(Map<String, dynamic> recommendation) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with match percentage
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recommendation['title'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        recommendation['composer'],
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(153),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withAlpha(51),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${recommendation['match']}% ${LocalizationService.translate('match_word', Provider.of<SettingsProvider>(context,listen:false).language)}',
                    style: const TextStyle(
                      color: Color(0xFF6366F1),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Details
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildDetailChip(_difficultyLabel(recommendation['difficulty']), Icons.trending_up),
                  const SizedBox(width: 8),
                  _buildDetailChip(recommendation['genre'], Icons.music_note),
                  const SizedBox(width: 8),
                  _buildRatingChip(recommendation['rating']),
                ],
              ),
            ),
            const SizedBox(height: 12),
            
            // Description
            Text(
              recommendation['description'],
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(153),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            
            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        // Preview sheet music
                      },
                      icon: Icon(Icons.visibility, color: Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(153)),
                    ),
                    IconButton(
                      onPressed: () {
                        // Play audio preview
                      },
                      icon: Icon(Icons.play_arrow, color: Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(153)),
                    ),
                    IconButton(
                      onPressed: () {
                        // Add to favorites
                      },
                      icon: Icon(Icons.favorite_border, color: Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(153)),
                    ),
                  ],
                ),
                SizedBox(
                  width: 150,
                  child: ElevatedButton(
                    onPressed: () {
                      // Download/Add to library
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(LocalizationService.translate('added_to_library', Provider.of<SettingsProvider>(context,listen:false).language)),
                          backgroundColor: const Color(0xFF059669),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      foregroundColor: Colors.white,
                    ),
                    child: Builder(builder:(context){
                        final lang=Provider.of<SettingsProvider>(context).language;
                        return FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            LocalizationService.translate('add_to_library', lang),
                            style: const TextStyle(fontSize: 12),
                          ),
                        );
                    }),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailChip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).textTheme.bodyLarge?.color?.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(153)),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(153),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingChip(double rating) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).textTheme.bodyLarge?.color?.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, size: 14, color: Colors.amber),
          const SizedBox(width: 4),
          Text(
            rating.toString(),
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(153),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  String _difficultyLabel(String difficulty) {
    switch (difficulty) {
      case 'Beginner':
        return 'Beginner';
      case 'Intermediate':
        return 'Intermediate';
      case 'Advanced':
        return 'Advanced';
      default:
        throw Exception('Unknown difficulty');
    }
  }
} 