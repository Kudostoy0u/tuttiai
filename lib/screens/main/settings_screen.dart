import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF0F0F23),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile section
          _buildProfileSection(context),
          const SizedBox(height: 24),
          
          // Preferences section
          _buildSection(
            'Preferences',
            [
              _buildSettingsTile(
                Icons.notifications,
                'Notifications',
                'Manage your notification preferences',
                () {},
              ),
              _buildSettingsTile(
                Icons.dark_mode,
                'Dark Mode',
                'Currently enabled',
                () {},
                trailing: Switch(
                  value: true,
                  onChanged: (value) {},
                  activeColor: const Color(0xFF6366F1),
                ),
              ),
              _buildSettingsTile(
                Icons.language,
                'Language',
                'English',
                () {},
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Practice section
          _buildSection(
            'Practice',
            [
              _buildSettingsTile(
                Icons.timer,
                'Practice Reminders',
                'Set daily practice reminders',
                () {},
              ),
              _buildSettingsTile(
                Icons.tune,
                'Default Tuning',
                'A4 = 440 Hz',
                () {},
              ),
              _buildSettingsTile(
                Icons.straighten,
                'Metronome Settings',
                'Configure default tempo and sounds',
                () {},
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Support section
          _buildSection(
            'Support',
            [
              _buildSettingsTile(
                Icons.help,
                'Help & FAQ',
                'Get help with TuttiAI',
                () {},
              ),
              _buildSettingsTile(
                Icons.feedback,
                'Send Feedback',
                'Tell us how we can improve',
                () {},
              ),
              _buildSettingsTile(
                Icons.info,
                'About',
                'Version 1.0.0',
                () {},
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Account section
          _buildSection(
            'Account',
            [
              _buildSettingsTile(
                Icons.logout,
                'Sign Out',
                'Sign out of your account',
                () => _showSignOutDialog(context),
                isDestructive: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E3F),
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
                    const Text(
                      'Your Profile',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      auth.userProfile['instrument'] ?? 'No instrument selected',
                      style: const TextStyle(
                        color: Colors.white70,
                      ),
                    ),
                    Text(
                      auth.userProfile['skillLevel'] ?? 'No skill level set',
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  // Edit profile
                },
                icon: const Icon(
                  Icons.edit,
                  color: Colors.white60,
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
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E3F),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: children,
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
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : const Color(0xFF6366F1),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.red : Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          color: Colors.white70,
        ),
      ),
      trailing: trailing ?? const Icon(
        Icons.chevron_right,
        color: Colors.white60,
      ),
      onTap: onTap,
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E3F),
          title: const Text(
            'Sign Out',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Are you sure you want to sign out?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white60),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Provider.of<AuthProvider>(context, listen: false).signOut();
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