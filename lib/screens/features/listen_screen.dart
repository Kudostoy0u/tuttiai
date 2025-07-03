import 'package:flutter/material.dart';

class ListenScreen extends StatefulWidget {
  const ListenScreen({super.key});

  @override
  State<ListenScreen> createState() => _ListenScreenState();
}

class _ListenScreenState extends State<ListenScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String? _selectedPiece;

  final List<String> _libraryPieces = [
    'Sonata No. 14 "Moonlight"',
    'Clair de Lune',
    'Für Elise',
    'Nocturne in E-flat Major, Op. 9 No. 2',
    'Prelude in C Major, BWV 846',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Listen'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Hear a Piece'),
            Tab(text: 'Accompaniment'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildListenTab(),
          _buildAccompanimentTab(),
        ],
      ),
    );
  }

  Widget _buildListenTab() {
    return _buildTabView(
      'Search for a piece to listen to',
      'Select a piece from your library',
    );
  }

  Widget _buildAccompanimentTab() {
    return _buildTabView(
      'Search for accompaniment',
      'Select a piece for accompaniment',
    );
  }

  Widget _buildTabView(String searchHint, String dropdownHint) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Find a Piece',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          // Search Input
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: searchHint,
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface.withOpacity(0.1),
            ),
          ),
          const SizedBox(height: 16),
          // Or select from library
          const Row(
            children: [
              Expanded(child: Divider()),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Text('OR'),
              ),
              Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: 16),
          // Dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: _selectedPiece,
                hint: Text(dropdownHint),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedPiece = newValue;
                    _searchController.text = newValue ?? '';
                  });
                },
                items: _libraryPieces.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 32),
          // Player placeholder
          _buildPlayerPlaceholder(),
        ],
      ),
    );
  }

  Widget _buildPlayerPlaceholder() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.music_note, size: 40),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedPiece ?? 'Select a piece',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Text('Ready to play'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const LinearProgressIndicator(value: 0.0),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(icon: const Icon(Icons.replay_10), onPressed: () {}),
              IconButton(icon: const Icon(Icons.play_arrow, size: 36), onPressed: () {}),
              IconButton(icon: const Icon(Icons.forward_10), onPressed: () {}),
            ],
          ),
        ],
      ),
    );
  }
} 