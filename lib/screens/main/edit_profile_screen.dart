import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../onboarding/onboarding_modal.dart';
import '../../providers/settings_provider.dart';
import '../../services/localization_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _emailController;
  late TextEditingController _nameController;
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    _emailController = TextEditingController(text: auth.currentUser?.email ?? '');
    _nameController = TextEditingController(text: auth.userProfile['name'] ?? '');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _saveBasicInfo() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      final auth = context.read<AuthProvider>();
      final newEmail = _emailController.text.trim();
      final newName = _nameController.text.trim();
      final newPassword = _passwordController.text.trim();
      final updates = <Future<void>>[];

      if (newEmail.isNotEmpty && newEmail != auth.currentUser?.email) {
        updates.add(auth.updateEmail(newEmail));
      }
      
      if (newPassword.isNotEmpty) {
        updates.add(auth.updatePassword(newPassword));
      }

      if (newName.isNotEmpty && newName != auth.userProfile['name']) {
        updates.add(auth.updateProfileData({'name': newName}));
      }

      await Future.wait(updates);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        _passwordController.clear();
        _confirmPasswordController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateMusicalPreferences() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const OnboardingModal(),
    );
    setState(() {}); // Refresh to show updated preferences
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Builder(builder:(context){final lang=Provider.of<SettingsProvider>(context).language;return Text(LocalizationService.translate('edit_profile_title',lang));}),
        elevation: 0,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, auth, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Header
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: Text(
                          (auth.userProfile['name']?.toString().substring(0, 1) ?? 
                           auth.currentUser?.email?.substring(0, 1) ?? 'U').toUpperCase(),
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        auth.userProfile['name'] ?? LocalizationService.translate('no_name_set', Provider.of<SettingsProvider>(context,listen:false).language),
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        auth.currentUser?.email ?? '',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withAlpha(179),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Basic Information Section
                _buildSection(
                  LocalizationService.translate('basic_information', Provider.of<SettingsProvider>(context,listen:false).language),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: LocalizationService.translate('full_name', Provider.of<SettingsProvider>(context,listen:false).language),
                            prefixIcon: const Icon(Icons.person),
                          ),
                          validator: (val) => val?.trim().isEmpty == true 
                              ? 'Name is required' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: LocalizationService.translate('email', Provider.of<SettingsProvider>(context,listen:false).language),
                            prefixIcon: const Icon(Icons.email),
                          ),
                          validator: (val) => val != null && val.contains('@')
                              ? null : 'Enter valid email',
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: LocalizationService.translate('new_password_optional', Provider.of<SettingsProvider>(context,listen:false).language),
                            prefixIcon: const Icon(Icons.lock),
                          ),
                          obscureText: true,
                          validator: (val) {
                            if (val != null && val.isNotEmpty && val.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _confirmPasswordController,
                          decoration: InputDecoration(
                            labelText: LocalizationService.translate('confirm_new_password', Provider.of<SettingsProvider>(context,listen:false).language),
                            prefixIcon: const Icon(Icons.lock_outline),
                          ),
                          obscureText: true,
                          validator: (val) {
                            if (_passwordController.text.isNotEmpty && val != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _saveBasicInfo,
                            child: _isLoading 
                                ? const CircularProgressIndicator()
                                : Builder(builder:(context){final l=Provider.of<SettingsProvider>(context).language;return Text(LocalizationService.translate('save_basic_information', l));}),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Musical Preferences Section
                _buildSection(
                  LocalizationService.translate('musical_preferences', Provider.of<SettingsProvider>(context,listen:false).language),
                  Column(
                    children: [
                      _buildPreferenceRow(
                        LocalizationService.translate('instrument_label', Provider.of<SettingsProvider>(context,listen:false).language),
                        auth.userProfile['instrument'] ?? LocalizationService.translate('not_set', Provider.of<SettingsProvider>(context,listen:false).language),
                        Icons.music_note,
                      ),
                      _buildPreferenceRow(
                        LocalizationService.translate('skill_level_label', Provider.of<SettingsProvider>(context,listen:false).language),
                        auth.userProfile['skillLevel'] ?? LocalizationService.translate('not_set', Provider.of<SettingsProvider>(context,listen:false).language),
                        Icons.star,
                      ),
                      _buildPreferenceRow(
                        LocalizationService.translate('practice_frequency_label', Provider.of<SettingsProvider>(context,listen:false).language),
                        auth.userProfile['practiceFrequency'] ?? LocalizationService.translate('not_set', Provider.of<SettingsProvider>(context,listen:false).language),
                        Icons.schedule,
                      ),
                      _buildPreferenceRow(
                        LocalizationService.translate('genres_label', Provider.of<SettingsProvider>(context,listen:false).language),
                        (auth.userProfile['genres'] as List?)?.join(', ') ?? LocalizationService.translate('not_set', Provider.of<SettingsProvider>(context,listen:false).language),
                        Icons.library_music,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _updateMusicalPreferences,
                          icon: const Icon(Icons.edit),
                          label: Builder(builder:(context){final l=Provider.of<SettingsProvider>(context).language;return Text(LocalizationService.translate('update_musical_preferences', l));}),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Subscription & Billing Section
                _buildSection(
                  LocalizationService.translate('subscription_billing', Provider.of<SettingsProvider>(context,listen:false).language),
                  Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.credit_card),
                        title: Text(LocalizationService.translate('payment_method', Provider.of<SettingsProvider>(context,listen:false).language)),
                        subtitle: Text(LocalizationService.translate('manage_payment_methods', Provider.of<SettingsProvider>(context,listen:false).language)),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(LocalizationService.translate('coming_soon', Provider.of<SettingsProvider>(context,listen:false).language))),
                          );
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.receipt_long),
                        title: Text(LocalizationService.translate('billing_history', Provider.of<SettingsProvider>(context,listen:false).language)),
                        subtitle: Text(LocalizationService.translate('view_past_invoices', Provider.of<SettingsProvider>(context,listen:false).language)),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Billing history coming soon')),
                          );
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.workspace_premium),
                        title: Text(LocalizationService.translate('subscription_plan', Provider.of<SettingsProvider>(context,listen:false).language)),
                        subtitle: Text(LocalizationService.translate('free_plan', Provider.of<SettingsProvider>(context,listen:false).language)),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Subscription management coming soon')),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection(String title, Widget content) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildPreferenceRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withAlpha(179),
                  ),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 