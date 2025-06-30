# Metronome Setup Instructions

## Overview
The metronome screen now uses the full `metronome` package (v2.0.6) with professional audio files! The implementation automatically falls back to system sounds if audio files fail to load.

## Current Status: Full Metronome Package ✅
The metronome now includes:
- **Professional audio files** with 6 different sound styles
- **Classic tick.wav and accent.wav files** as the default style
- **High-precision timing** using the native metronome package
- **Custom audio switching** between different percussion sounds
- **Volume control** from 0-100%
- **Full visual interface** with animations

## Optional: Enable Full Metronome Package

To enable the full metronome package with custom audio files, you need to add proper audio files to the `assets/audio/` directory.

### Required Files:
- `assets/audio/tick.wav` - Main metronome tick sound
- `assets/audio/tock.wav` - Accented beat sound (different from tick)
- `assets/audio/accent.wav` - Alternative accent sound

### File Requirements:
- Format: WAV files (44.1kHz sample rate recommended)
- Duration: Short clips (50-200ms) work best
- Quality: High-quality, clear metronome sounds

## Where to Get Audio Files

### Option 1: Download Free Metronome Sounds
- [freesound.org](https://freesound.org) - Search for "metronome", "tick", "click"
- [zapsplat.com](https://zapsplat.com) - Professional sound effects
- [BBC Sound Effects](https://sound-effects.bbcrewind.co.uk/) - Free BBC archive

### Option 2: Generate Your Own
You can create simple metronome sounds using audio software:
- **Audacity** (free): Generate tone → 800Hz, 100ms for tick
- **GarageBand** (Mac): Create short percussion sounds
- **Any DAW**: Generate sine wave tones at different frequencies

### Recommended Frequencies:
- **Main tick**: 600-800Hz
- **Accent**: 1200-1800Hz (higher pitch)
- **Subdivision**: 300-500Hz (lower pitch)

## Enabling Full Metronome Package

Once you have proper audio files:

1. **Add audio files** to `assets/audio/` (tick.wav, tock.wav, accent.wav)
2. **Update the code** in `lib/screens/features/metronome_screen.dart`:
   
   Replace the `_initializeMetronome()` method:
   ```dart
   Future<void> _initializeMetronome() async {
     try {
       await _metronome.init(
         _audioOptions[_selectedAudioIndex]['main']!,
         accentedPath: _audioOptions[_selectedAudioIndex]['accent']!,
         bpm: _bpm,
         volume: _volume,
         enableTickCallback: true,
         timeSignature: _timeSignature,
         sampleRate: 44100,
       );
       
       setState(() {
         _isInitialized = _metronome.isInitialized;
       });
       
       // Set up tick stream...
     } catch (e) {
       print('Failed to initialize metronome: $e');
       _initializeFallbackMetronome();
     }
   }
   ```

3. **Re-enable audio controls** in the UI by updating the sound settings section

## Current Fallback Behavior

The fallback implementation:
- Uses system sounds (click) with haptic feedback
- Provides accurate timer-based timing
- Supports all time signatures and BPM ranges
- Includes full visual metronome functionality

## Available Audio Files 🎵

The metronome now includes these professional percussion sounds:

✅ **Classic**: Traditional tick.wav/accent.wav metronome sounds (default)  
✅ **Claves**: Traditional wooden claves with woodblock accent  
✅ **Sticks**: Drumsticks with snare drum accent  
✅ **Hi-Hat**: Hi-hat cymbal with bass drum accent  
✅ **Base**: Bass drum with snare accent  
✅ **Mute**: Muted click with claves accent  

## Full Feature Set

The metronome includes all professional features:

✅ **High-Precision Timing**: Native metronome package for ultra-accurate BPM  
✅ **Time Signatures**: Support for 2/4, 3/4, 4/4, 5/4, 6/4, 3/8, 6/8, 12/8  
✅ **Accent Patterns**: Multiple accent patterns (Strong-Weak, Waltz, March, etc.)  
✅ **Subdivisions**: Quarter notes, eighth notes, sixteenth notes  
✅ **BPM Range**: 40-300 BPM with tap tempo  
✅ **Volume Control**: 0-100% independent volume adjustment  
✅ **Sound Switching**: Live switching between different percussion sounds  
✅ **Visual Feedback**: Animated pendulum and beat indicators  
✅ **Haptic Feedback**: Different vibration patterns for different beats  
✅ **Fallback Support**: Automatically uses system sounds if audio fails  

## Ready to Use! 🎵

The metronome is now fully loaded with professional audio:

1. **Open the app** and navigate to the metronome
2. **Choose your sound style** (Classic, Claves, Sticks, Hi-Hat, Base, or Mute)
3. **Set your BPM** using the slider or tap tempo
4. **Adjust volume** with the volume slider
5. **Choose time signature** and accent patterns
6. **Press play** and enjoy professional metronome sounds!

### Try Different Sounds:
- **Classic**: Traditional metronome tick.wav/accent.wav - perfect for all practice
- **Claves**: Perfect for Latin rhythms
- **Sticks**: Great for rock and pop practice
- **Hi-Hat**: Excellent for jazz and swing
- **Base**: Powerful for orchestral work
- **Mute**: Subtle for quiet practice

All audio files are now included and ready to use! 