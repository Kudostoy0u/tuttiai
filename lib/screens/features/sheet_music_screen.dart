import 'package:flutter/material.dart';

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
        title: const Text(
          'Sheet Music Recommendations',
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
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'AI is analyzing your preferences...',
                    style: TextStyle(color: Colors.white70),
                  ),
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
                          Text(
                            'Personalized for You',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Based on your skill level, preferences, and practice history',
                        style: TextStyle(color: Colors.white70),
                      ),
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
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        recommendation['composer'],
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${recommendation['match']}% Match',
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
                  _buildDetailChip(recommendation['difficulty'], Icons.trending_up),
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
              style: const TextStyle(
                color: Colors.white60,
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
                      icon: const Icon(Icons.visibility, color: Colors.white60),
                    ),
                    IconButton(
                      onPressed: () {
                        // Play audio preview
                      },
                      icon: const Icon(Icons.play_arrow, color: Colors.white60),
                    ),
                    IconButton(
                      onPressed: () {
                        // Add to favorites
                      },
                      icon: const Icon(Icons.favorite_border, color: Colors.white60),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    // Download/Add to library
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Added "${recommendation['title']}" to your library'),
                        backgroundColor: const Color(0xFF059669),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Add to Library'),
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
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white60),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white60,
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
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, size: 14, color: Colors.amber),
          const SizedBox(width: 4),
          Text(
            rating.toString(),
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
} 