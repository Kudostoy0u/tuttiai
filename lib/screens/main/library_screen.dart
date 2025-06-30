import 'package:flutter/material.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Library',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF0F0F23),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF6366F1),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(text: 'Sheet Music'),
            Tab(text: 'Recordings'),
            Tab(text: 'Practice Log'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSheetMusicTab(),
          _buildRecordingsTab(),
          _buildPracticeLogTab(),
        ],
      ),
    );
  }

  Widget _buildSheetMusicTab() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search bar
          TextField(
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search sheet music...',
              hintStyle: const TextStyle(color: Colors.white60),
              prefixIcon: const Icon(Icons.search, color: Colors.white60),
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All', true),
                _buildFilterChip('Favorites', false),
                _buildFilterChip('Recently Added', false),
                _buildFilterChip('Classical', false),
                _buildFilterChip('Jazz', false),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Sheet music list
          Expanded(
            child: ListView.builder(
              itemCount: 5, // Mock data
              itemBuilder: (context, index) {
                return _buildSheetMusicItem(
                  'Sonata No. ${index + 1}',
                  'Wolfgang Amadeus Mozart',
                  'Classical',
                  4.5,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordingsTab() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Date filter
          Row(
            children: [
              Expanded(
                child: TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search recordings...',
                    hintStyle: const TextStyle(color: Colors.white60),
                    prefixIcon: const Icon(Icons.search, color: Colors.white60),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: () {
                  // Show date picker
                },
                icon: const Icon(Icons.calendar_today, color: Colors.white60),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Recordings list
          Expanded(
            child: ListView.builder(
              itemCount: 8, // Mock data
              itemBuilder: (context, index) {
                return _buildRecordingItem(
                  'Practice Session ${index + 1}',
                  '${3 + index % 5} min ${20 + index % 40} sec',
                  DateTime.now().subtract(Duration(days: index)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPracticeLogTab() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Stats cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard('This Week', '5 hrs 30 min', Icons.timer),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard('Streak', '12 days', Icons.local_fire_department),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Practice sessions
          Expanded(
            child: ListView.builder(
              itemCount: 10, // Mock data
              itemBuilder: (context, index) {
                return _buildPracticeLogItem(
                  DateTime.now().subtract(Duration(days: index)),
                  '${30 + index % 60} minutes',
                  'Scales, Etudes',
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (value) {
          // Handle filter selection
        },
        backgroundColor: Colors.white.withOpacity(0.1),
        selectedColor: const Color(0xFF6366F1),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.white70,
        ),
        checkmarkColor: Colors.white,
      ),
    );
  }

  Widget _buildSheetMusicItem(String title, String composer, String genre, double rating) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFF6366F1).withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.music_note,
            color: Color(0xFF6366F1),
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              composer,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  genre,
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                ),
                const SizedBox(width: 8),
                Icon(Icons.star, size: 16, color: Colors.amber),
                Text(
                  rating.toString(),
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.white60),
          onPressed: () {
            // Show options menu
          },
        ),
      ),
    );
  }

  Widget _buildRecordingItem(String title, String duration, DateTime date) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFF7C3AED).withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.mic,
            color: Color(0xFF7C3AED),
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              duration,
              style: const TextStyle(color: Colors.white70),
            ),
            Text(
              '${date.day}/${date.month}/${date.year}',
              style: const TextStyle(color: Colors.white60, fontSize: 12),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.play_arrow, color: Colors.white60),
              onPressed: () {
                // Play recording
              },
            ),
            IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.white60),
              onPressed: () {
                // Show options menu
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPracticeLogItem(DateTime date, String duration, String activities) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFF059669).withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              '${date.day}',
              style: const TextStyle(
                color: Color(0xFF059669),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),
        title: Text(
          duration,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              activities,
              style: const TextStyle(color: Colors.white70),
            ),
            Text(
              '${date.day}/${date.month}/${date.year}',
              style: const TextStyle(color: Colors.white60, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E3F),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: const Color(0xFF6366F1),
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
} 