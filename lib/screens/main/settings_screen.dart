import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../../screens/main/edit_profile_screen.dart';
import '../../services/localization_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              LocalizationService.translate('settings', settings.language),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Profile section
              _buildProfileSection(context, settings),
              const SizedBox(height: 24),
              
              // Preferences section
              _buildSection(
                LocalizationService.translate('preferences', settings.language),
                [
                  _buildSettingsTile(
                    Icons.notifications,
                    LocalizationService.translate('notifications', settings.language),
                    settings.notificationsEnabled 
                        ? LocalizationService.translate('enabled', settings.language)
                        : LocalizationService.translate('disabled', settings.language),
                    () => _showNotificationSettings(context),
                    trailing: Switch(
                      value: settings.notificationsEnabled,
                      onChanged: (value) => settings.setNotificationsEnabled(value),
                      activeColor: const Color(0xFF6366F1),
                    ),
                  ),
                  _buildSettingsTile(
                    Icons.dark_mode,
                    LocalizationService.translate('dark_mode', settings.language),
                    settings.isDarkMode 
                        ? LocalizationService.translate('enabled', settings.language)
                        : LocalizationService.translate('disabled', settings.language),
                    () {},
                    trailing: Switch(
                      value: settings.isDarkMode,
                      onChanged: (value) => settings.setDarkMode(value),
                      activeColor: const Color(0xFF6366F1),
                    ),
                  ),
                  _buildSettingsTile(
                    Icons.language,
                    LocalizationService.translate('language', settings.language),
                    settings.language,
                    () => _showLanguageDialog(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Practice section
              _buildSection(
                LocalizationService.translate('practice', settings.language),
                [
                  _buildSettingsTile(
                    Icons.timer,
                    LocalizationService.translate('practice_reminders', settings.language),
                    settings.practiceReminders 
                        ? 'Daily at ${settings.reminderTime.format(context)}'
                        : LocalizationService.translate('disabled', settings.language),
                    () => _showPracticeReminderSettings(context),
                  ),
                  _buildSettingsTile(
                    Icons.tune,
                    LocalizationService.translate('default_tuning', settings.language),
                    settings.defaultTuning,
                    () => _showTuningDialog(context),
                  ),
                  _buildSettingsTile(
                    Icons.straighten,
                    LocalizationService.translate('metronome_default_tempo', settings.language),
                    '${settings.metronomeDefaultTempo} BPM',
                    () => _showTempoDialog(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Support section
              _buildSection(
                LocalizationService.translate('support', settings.language),
                [
                  _buildSettingsTile(
                    Icons.help,
                    LocalizationService.translate('help_faq', settings.language),
                    LocalizationService.translate('help_desc', settings.language),
                    () => _showHelpDialog(context),
                  ),
                  _buildSettingsTile(
                    Icons.feedback,
                    LocalizationService.translate('send_feedback', settings.language),
                    LocalizationService.translate('feedback_desc', settings.language),
                    () => _showFeedbackDialog(context),
                  ),
                  _buildSettingsTile(
                    Icons.info,
                    LocalizationService.translate('about', settings.language),
                    'Version 1.0.0',
                    () => _showAboutDialog(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Account section
              _buildSection(
                LocalizationService.translate('account', settings.language),
                [
                  _buildSettingsTile(
                    Icons.logout,
                    LocalizationService.translate('sign_out', settings.language),
                    LocalizationService.translate('sign_out_desc', settings.language),
                    () => _showSignOutDialog(context),
                    isDestructive: true,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileSection(BuildContext context, SettingsProvider settings) {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: const Color(0xFF6366F1),
                child: Text(
                  auth.userProfile['email']?.substring(0, 1).toUpperCase() ?? 'U',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LocalizationService.translate('profile', settings.language),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      auth.userProfile['instrument'] ?? LocalizationService.translate('no_instrument_selected', settings.language),
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(153),
                      ),
                    ),
                    Text(
                      auth.userProfile['skillLevel'] ?? LocalizationService.translate('no_skill_level_set', settings.language),
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(128),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                  );
                },
                icon: Icon(
                  Icons.edit,
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(153),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Builder(
          builder: (context) => Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
        ),
        const SizedBox(height: 12),
        Builder(
          builder: (context) => Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: children,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTile(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap, {
    Widget? trailing,
    bool isDestructive = false,
  }) {
    return Builder(
      builder: (context) => ListTile(
        leading: Icon(
          icon,
          color: isDestructive ? Colors.red : const Color(0xFF6366F1),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDestructive ? Colors.red : null,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(153),
          ),
        ),
        trailing: trailing ?? Icon(
          Icons.chevron_right,
          color: Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(179),
        ),
        onTap: onTap,
      ),
    );
  }

  void _showNotificationSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notification Settings'),
        content: const Text(
          'Manage your notification preferences. You can enable or disable notifications using the switch in the settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final languages = ['English', 'Spanish', 'French', 'German', 'Italian', 'Chinese', 'Hindi'];
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: languages.map((language) => RadioListTile<String>(
            title: Text(language),
            value: language,
            groupValue: settings.language,
            onChanged: (value) {
              if (value != null) {
                settings.setLanguage(value);
                Navigator.pop(context);
              }
            },
          )).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showPracticeReminderSettings(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Practice Reminders'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                title: const Text('Enable Daily Reminders'),
                value: settings.practiceReminders,
                onChanged: (value) {
                  settings.setPracticeReminders(value);
                  setState(() {});
                },
              ),
              if (settings.practiceReminders) ...[
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Reminder Time'),
                  subtitle: Text(settings.reminderTime.format(context)),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: settings.reminderTime,
                    );
                    if (time != null) {
                      settings.setReminderTime(time);
                      setState(() {});
                    }
                  },
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }

  void _showTuningDialog(BuildContext context) {
    final tunings = [
      'A4 = 440 Hz',
      'A4 = 442 Hz',
      'A4 = 444 Hz', 
      'A4 = 438 Hz (Baroque)',
    ];
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Default Tuning'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: tunings.map((tuning) => RadioListTile<String>(
            title: Text(tuning),
            value: tuning,
            groupValue: settings.defaultTuning,
            onChanged: (value) {
              if (value != null) {
                settings.setDefaultTuning(value);
                Navigator.pop(context);
              }
            },
          )).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showTempoDialog(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    int tempTempo = settings.metronomeDefaultTempo;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Default Metronome Tempo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$tempTempo BPM', style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 16),
              Slider(
                value: tempTempo.toDouble(),
                min: 40,
                max: 200,
                divisions: 160,
                label: '$tempTempo BPM',
                onChanged: (value) {
                  setState(() {
                    tempTempo = value.round();
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                settings.setMetronomeDefaultTempo(tempTempo);
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & FAQ'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Frequently Asked Questions:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('Q: How do I tune my instrument?'),
              Text('A: Go to the Tuning feature from the dashboard and follow the instructions.'),
              SizedBox(height: 12),
              Text('Q: How do I record practice sessions?'),
              Text('A: Use the Recording Library feature to record and manage your practice sessions.'),
              SizedBox(height: 12),
              Text('Q: Can I change the metronome tempo?'),
              Text('A: Yes, you can set a default tempo in Settings or adjust it in the Metronome feature.'),
              SizedBox(height: 12),
              Text('Q: How do I get sheet music recommendations?'),
              Text('A: Use the Sheet Music Finder feature, which provides AI-powered suggestions based on your skill level and preferences.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showFeedbackDialog(BuildContext context) {
    final TextEditingController feedbackController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Feedback'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('We\'d love to hear your thoughts and suggestions!'),
            const SizedBox(height: 16),
            TextField(
              controller: feedbackController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Tell us what you think...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement actual feedback submission
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Thank you for your feedback!')),
              );
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Tutti',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.music_note, size: 48, color: Color(0xFF6366F1)),
      children: [
        const Text('Your AI-powered music companion for smart sheet music recommendations and comprehensive music practice tools.'),
        const SizedBox(height: 16),
        const Text('Made with ♪ for musicians everywhere.'),
      ],
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sign Out'),
          content: const Text('Are you sure you want to sign out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                Navigator.of(context).pop(); // Close dialog
                await authProvider.signOut();
              },
              child: const Text(
                'Sign Out',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
} 