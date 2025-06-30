import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class OnboardingModal extends StatefulWidget {
  const OnboardingModal({super.key});

  @override
  State<OnboardingModal> createState() => _OnboardingModalState();
}

class _OnboardingModalState extends State<OnboardingModal> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  // User responses
  String? _selectedInstrument;
  String? _skillLevel;
  final List<String> _musicGenres = [];
  String? _practiceFrequency;
  bool _hasTeacher = false;
  final List<String> _goals = [];

  final List<String> _instruments = [
    'Piano', 'Guitar', 'Violin', 'Cello', 'Flute', 'Clarinet', 
    'Saxophone', 'Trumpet', 'Drums', 'Voice', 'Other'
  ];

  final List<String> _skillLevels = [
    'Beginner', 'Intermediate', 'Advanced', 'Professional'
  ];

  final List<String> _genres = [
    'Classical', 'Jazz', 'Pop', 'Rock', 'Blues', 'Country', 
    'Electronic', 'R&B', 'Folk', 'World Music'
  ];

  final List<String> _frequencies = [
    'Daily', '3-4 times a week', '1-2 times a week', 'Occasionally'
  ];

  final List<String> _goalOptions = [
    'Learn new pieces', 'Improve technique', 'Prepare for performances',
    'Music theory', 'Sight-reading', 'Improvisation', 'Recording'
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 5) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeOnboarding() async {
    final profile = {
      'instrument': _selectedInstrument,
      'skillLevel': _skillLevel,
      'genres': _musicGenres,
      'practiceFrequency': _practiceFrequency,
      'hasTeacher': _hasTeacher,
      'goals': _goals,
    };

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.completeOnboarding(profile);
    
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E3F),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            // Progress indicator
            LinearProgressIndicator(
              value: (_currentPage + 1) / 6,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
            ),
            const SizedBox(height: 24),
            
            // Content
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                children: [
                  _buildWelcomePage(),
                  _buildInstrumentPage(),
                  _buildSkillLevelPage(),
                  _buildGenresPage(),
                  _buildPracticeFrequencyPage(),
                  _buildGoalsPage(),
                ],
              ),
            ),
            
            // Navigation buttons
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: _currentPage > 0 ? _previousPage : null,
                  child: Text(
                    'Back',
                    style: TextStyle(
                      color: _currentPage > 0 ? Colors.white70 : Colors.transparent,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: _canProceed() ? _nextPage : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                  child: Text(_currentPage == 5 ? 'Complete' : 'Next'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool _canProceed() {
    switch (_currentPage) {
      case 0: return true;
      case 1: return _selectedInstrument != null;
      case 2: return _skillLevel != null;
      case 3: return _musicGenres.isNotEmpty;
      case 4: return _practiceFrequency != null;
      case 5: return _goals.isNotEmpty;
      default: return false;
    }
  }

  Widget _buildWelcomePage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.music_note,
          size: 80,
          color: Color(0xFF6366F1),
        ),
        const SizedBox(height: 24),
        Text(
          'Welcome to TuttiAI!',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'Let\'s personalize your musical experience. We\'ll ask you a few questions to better understand your musical journey.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Colors.white70,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildInstrumentPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What instrument do you play?',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _instruments.length,
            itemBuilder: (context, index) {
              final instrument = _instruments[index];
              final isSelected = _selectedInstrument == instrument;
              
              return GestureDetector(
                onTap: () => setState(() => _selectedInstrument = instrument),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF6366F1) : Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF6366F1) : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      instrument,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSkillLevelPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What\'s your skill level?',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        ..._skillLevels.map((level) {
          final isSelected = _skillLevel == level;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: GestureDetector(
              onTap: () => setState(() => _skillLevel = level),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF6366F1) : Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      level,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildGenresPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What genres do you enjoy?',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Select all that apply',
          style: TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _genres.length,
            itemBuilder: (context, index) {
              final genre = _genres[index];
              final isSelected = _musicGenres.contains(genre);
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _musicGenres.remove(genre);
                    } else {
                      _musicGenres.add(genre);
                    }
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF6366F1) : Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      genre,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPracticeFrequencyPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How often do you practice?',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        ..._frequencies.map((frequency) {
          final isSelected = _practiceFrequency == frequency;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: GestureDetector(
              onTap: () => setState(() => _practiceFrequency = frequency),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF6366F1) : Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      frequency,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 24),
        GestureDetector(
          onTap: () => setState(() => _hasTeacher = !_hasTeacher),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _hasTeacher ? const Color(0xFF6366F1) : Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  _hasTeacher ? Icons.check_box : Icons.check_box_outline_blank,
                  color: Colors.white,
                ),
                const SizedBox(width: 12),
                const Text(
                  'I have a music teacher',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGoalsPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What are your musical goals?',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Select all that apply',
          style: TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1,
              childAspectRatio: 6,
              mainAxisSpacing: 12,
            ),
            itemCount: _goalOptions.length,
            itemBuilder: (context, index) {
              final goal = _goalOptions[index];
              final isSelected = _goals.contains(goal);
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _goals.remove(goal);
                    } else {
                      _goals.add(goal);
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF6366F1) : Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        goal,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
} 