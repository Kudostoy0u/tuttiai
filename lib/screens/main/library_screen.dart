import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/localization_service.dart';

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
    final settings = Provider.of<SettingsProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          LocalizationService.translate('library', settings.language),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF6366F1),
          labelColor: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
          unselectedLabelColor: Theme.of(context).brightness == Brightness.dark ? Colors.white60 : Colors.black54,
          tabs: [
            Tab(text: LocalizationService.translate('sheet_music_tab', settings.language)),
            Tab(text: LocalizationService.translate('recordings_tab', settings.language)),
            Tab(text: LocalizationService.translate('practice_log_tab', settings.language)),
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
    final settings = Provider.of<SettingsProvider>(context);
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search bar
          TextField(
            style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
            decoration: InputDecoration(
              hintText: LocalizationService.translate('search_sheet_music', settings.language),
              hintStyle: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(153)),
              prefixIcon: Icon(Icons.search, color: Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(153)),
              filled: true,
              fillColor: Theme.of(context).textTheme.bodyLarge?.color?.withAlpha(26),
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
                _buildFilterChip(LocalizationService.translate('all', settings.language), true),
                _buildFilterChip(LocalizationService.translate('favorites', settings.language), false),
                _buildFilterChip(LocalizationService.translate('recently_added', settings.language), false),
                _buildFilterChip(LocalizationService.translate('classical', settings.language), false),
                _buildFilterChip(LocalizationService.translate('jazz', settings.language), false),
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
    final settings = Provider.of<SettingsProvider>(context);
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Date filter
          Row(
            children: [
              Expanded(
                child: TextField(
                  style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                  decoration: InputDecoration(
                    hintText: LocalizationService.translate('search_recordings', settings.language),
                    hintStyle: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(153)),
                    prefixIcon: Icon(Icons.search, color: Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(153)),
                    filled: true,
                    fillColor: Theme.of(context).textTheme.bodyLarge?.color?.withAlpha(26),
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
                icon: Icon(Icons.calendar_today, color: Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(153)),
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
    final settings = Provider.of<SettingsProvider>(context);
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Stats cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  LocalizationService.translate('this_week', settings.language),
                  '5 ${LocalizationService.translate('hrs', settings.language)} 30 ${LocalizationService.translate('min_unit', settings.language)}',
                  Icons.timer,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  LocalizationService.translate('streak', settings.language),
                  '12 ${LocalizationService.translate('days_unit', settings.language)}',
                  Icons.local_fire_department,
                ),
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
        backgroundColor: Theme.of(context).textTheme.bodyLarge?.color?.withAlpha(26),
        selectedColor: const Color(0xFF6366F1),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(179),
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
            color: const Color(0xFF6366F1).withAlpha(51),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.music_note,
            color: Color(0xFF6366F1),
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              composer,
              style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(179)),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  genre,
                  style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(153), fontSize: 12),
                ),
                const SizedBox(width: 8),
                Icon(Icons.star, size: 16, color: Colors.amber),
                Text(
                  rating.toString(),
                  style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(153), fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.more_vert, color: Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(153)),
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
            color: const Color(0xFF7C3AED).withAlpha(51),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.mic,
            color: Color(0xFF7C3AED),
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              duration,
              style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(179)),
            ),
            Text(
              '${date.day}/${date.month}/${date.year}',
              style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(153), fontSize: 12),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.play_arrow, color: Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(153)),
              onPressed: () {
                // Play recording
              },
            ),
            IconButton(
              icon: Icon(Icons.more_vert, color: Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(153)),
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
            color: const Color(0xFF059669).withAlpha(51),
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
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              activities,
              style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(179)),
            ),
            Text(
              '${date.day}/${date.month}/${date.year}',
              style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(153), fontSize: 12),
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
        color: Theme.of(context).cardColor,
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
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(179),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
} 