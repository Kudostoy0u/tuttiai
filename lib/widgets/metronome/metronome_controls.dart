import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/localization_service.dart';

class BpmControls extends StatelessWidget {
  final int bpm;
  final Function(int) onBpmChanged;

  const BpmControls({
    super.key,
    required this.bpm,
    required this.onBpmChanged,
  });

  @override
  Widget build(BuildContext context) {
    const commonBpms = [60, 72, 80, 92, 104, 120, 138, 144, 160, 176, 192, 208];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => onBpmChanged(bpm - 1),
                  icon: Icon(Icons.remove, color: Theme.of(context).iconTheme.color?.withAlpha(153)),
                  style: IconButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).colorScheme.onSurface.withAlpha(26),
                  ),
                ),
                Expanded(
                  child: Slider(
                    value: bpm.toDouble(),
                    min: 40,
                    max: 300,
                    divisions: 260,
                    activeColor: Theme.of(context).colorScheme.secondary,
                    inactiveColor: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withAlpha(77),
                    onChanged: (value) => onBpmChanged(value.round()),
                  ),
                ),
                IconButton(
                  onPressed: () => onBpmChanged(bpm + 1),
                  icon: Icon(Icons.add, color: Theme.of(context).iconTheme.color?.withAlpha(153)),
                  style: IconButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).colorScheme.onSurface.withAlpha(26),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: commonBpms.map((presetBpm) {
                return GestureDetector(
                  onTap: () => onBpmChanged(presetBpm),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: presetBpm == bpm
                          ? Theme.of(context).colorScheme.secondary
                          : Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withAlpha(26),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      presetBpm.toString(),
                      style: TextStyle(
                        color: presetBpm == bpm
                            ? Theme.of(context).colorScheme.onSecondary
                            : Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.color
                                ?.withAlpha(179),
                        fontSize: 10,
                        fontWeight:
                            presetBpm == bpm ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class SubdivisionControls extends StatelessWidget {
  final int subdivision;
  final Function(int) onSubdivisionChanged;

  const SubdivisionControls({
    super.key,
    required this.subdivision,
    required this.onSubdivisionChanged,
  });

  @override
  Widget build(BuildContext context) {
    const subdivisions = [
      {'value': 1, 'label': '♩'},
      {'value': 2, 'label': '♫'},
      {'value': 3, 'label': '³♩'},
      {'value': 4, 'label': '♬'},
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Builder(builder: (context) {
              final settings = Provider.of<SettingsProvider>(context);
              return Text(
                LocalizationService.translate('note_subdivision', settings.language),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              );
            }),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: subdivisions.map((sub) {
                final value = sub['value'] as int;
                final label = sub['label'] as String;
                final isSelected = value == subdivision;
                return GestureDetector(
                  onTap: () => onSubdivisionChanged(value),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withAlpha(26),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      label,
                      style: TextStyle(
                        color: isSelected
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.color
                                ?.withAlpha(179),
                        fontSize: 20,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class TimeAccentControls extends StatelessWidget {
  final int timeSignature;
  final String selectedAccentPattern;
  final List<Map<String, dynamic>> accentPatterns;
  final Function(int) onTimeSignatureChanged;
  final Function(String?) onAccentPatternChanged;

  const TimeAccentControls({
    super.key,
    required this.timeSignature,
    required this.selectedAccentPattern,
    required this.accentPatterns,
    required this.onTimeSignatureChanged,
    required this.onAccentPatternChanged,
  });

  @override
  Widget build(BuildContext context) {
    const timeSignatures = [
      {'beats': 2, 'note': 4, 'display': '2/4'},
      {'beats': 3, 'note': 4, 'display': '3/4'},
      {'beats': 4, 'note': 4, 'display': '4/4'},
      {'beats': 5, 'note': 4, 'display': '5/4'},
      {'beats': 6, 'note': 4, 'display': '6/4'},
      {'beats': 3, 'note': 8, 'display': '3/8'},
      {'beats': 6, 'note': 8, 'display': '6/8'},
      {'beats': 12, 'note': 8, 'display': '12/8'},
    ];

    return IntrinsicHeight(
      child: Row(
        children: [
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Builder(builder: (context) {
                      final settings = Provider.of<SettingsProvider>(context);
                      return Text(
                        LocalizationService.translate('time_signature', settings.language),
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      );
                    }),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 60,
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          mainAxisSpacing: 4,
                          crossAxisSpacing: 4,
                          childAspectRatio: 1.2,
                        ),
                        itemCount: timeSignatures.length,
                        itemBuilder: (context, index) {
                          final ts = timeSignatures[index];
                          final beats = ts['beats'] as int;
                          final display = ts['display'] as String;
                          final isSelected = beats == timeSignature;

                          return GestureDetector(
                            onTap: () => onTimeSignatureChanged(beats),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withAlpha(26),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Center(
                                child: Text(
                                  display,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Theme.of(context).colorScheme.onPrimary
                                        : Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.color
                                            ?.withAlpha(179),
                                    fontSize: 10,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Builder(builder: (context) {
                      final settings = Provider.of<SettingsProvider>(context);
                      return Text(
                        LocalizationService.translate('accent_pattern', settings.language),
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      );
                    }),
                    const SizedBox(height: 6),
                    DropdownButton<String>(
                      alignment: Alignment.center,
                      value: selectedAccentPattern,
                      onChanged: onAccentPatternChanged,
                      dropdownColor: Theme.of(context).cardColor,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface),
                      underline: Container(),
                      items: accentPatterns.map<DropdownMenuItem<String>>((pattern) {
                        return DropdownMenuItem<String>(
                          value: pattern['name'],
                          child: Builder(builder:(context){
                            final lang = Provider.of<SettingsProvider>(context).language;
                            final key = pattern['name'].toString().toLowerCase().replaceAll(' ', '_');
                            return Text(
                              LocalizationService.translate(key + '_pattern', lang),
                              style: const TextStyle(fontSize: 12),
                            );
                          }),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FeedbackControls extends StatelessWidget {
  final double audioVolume;
  final double hapticIntensity;
  final Function(double) onAudioVolumeChanged;
  final Function(double) onHapticIntensityChanged;

  const FeedbackControls({
    super.key,
    required this.audioVolume,
    required this.hapticIntensity,
    required this.onAudioVolumeChanged,
    required this.onHapticIntensityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Builder(builder: (context) {
              final settings = Provider.of<SettingsProvider>(context);
              return Text(LocalizationService.translate('audio_volume', settings.language), style: const TextStyle(fontWeight: FontWeight.bold));
            }),
            Row(
              children: [
                Icon(Icons.volume_off,
                    color: Theme.of(context).iconTheme.color?.withAlpha(102)),
                Expanded(
                  child: Slider(
                    value: audioVolume,
                    min: 0,
                    max: 100,
                    divisions: 100,
                    activeColor: Theme.of(context).colorScheme.secondary,
                    inactiveColor: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withAlpha(77),
                    onChanged: onAudioVolumeChanged,
                  ),
                ),
                Icon(Icons.volume_up, color: Theme.of(context).iconTheme.color),
              ],
            ),
            const SizedBox(height: 16),
            Builder(builder: (context) {
              final settings = Provider.of<SettingsProvider>(context);
              return Text(LocalizationService.translate('haptic_feedback', settings.language), style: const TextStyle(fontWeight: FontWeight.bold));
            }),
            Row(
              children: [
                Icon(Icons.vibration,
                    color: Theme.of(context).iconTheme.color?.withAlpha(102)),
                Expanded(
                  child: Slider(
                    value: hapticIntensity,
                    min: 0,
                    max: 100,
                    divisions: 100,
                    activeColor: Theme.of(context).colorScheme.primary,
                    inactiveColor: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withAlpha(77),
                    onChanged: onHapticIntensityChanged,
                  ),
                ),
                Icon(Icons.vibration, color: Theme.of(context).iconTheme.color),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 