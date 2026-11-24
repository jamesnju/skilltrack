
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/focus_sound.dart';
import '../services/focus_audio_service.dart';
import '../services/focus_mode_service.dart';

class DeepFocusScreen extends StatefulWidget {
  const DeepFocusScreen({super.key});

  @override
  State<DeepFocusScreen> createState() => _DeepFocusScreenState();
}

class _DeepFocusScreenState extends State<DeepFocusScreen>
    with WidgetsBindingObserver {
  final FocusAudioService _audio = FocusAudioService.instance;
  final FocusModeService _focusMode = FocusModeService.instance;

  static const Color primary = Color(0xFF16845B);
  static const Color dark = Color(0xFF102A21);
  static const Color background = Color(0xFFF5F8F6);

  String? _selectedId;

  bool _dndEnabledByApp = false;
  bool _hasDndAccess = false;
  bool _busy = false;
  bool _showTips = false;

  double _volume = 0.65;
  String? _message;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await _audio.initialize();

      final access = await _focusMode.hasDndAccess;

      if (!mounted) return;

      setState(() {
        _hasDndAccess = access;
        _selectedId = _audio.selectedSound?.id;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _message = 'Unable to initialize Deep Focus.';
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshDndAccess();
    }
  }

  Future<void> _refreshDndAccess() async {
    try {
      final access = await _focusMode.hasDndAccess;

      if (!mounted) return;

      setState(() {
        _hasDndAccess = access;
      });
    } catch (_) {}
  }

  Future<void> _toggleDnd() async {
    setState(() {
      _busy = true;
      _message = null;
    });

    try {
      if (!_hasDndAccess) {
        await _focusMode.openDndSettings();

        if (mounted) {
          setState(() {
            _message =
                'Allow FocusTech in Do Not Disturb access, then return here.';
          });
        }
      } else if (_dndEnabledByApp) {
        final restored = await _focusMode.restoreDnd();

        if (mounted) {
          setState(() {
            _dndEnabledByApp = false;
            _message = restored
                ? 'Your previous Do Not Disturb setting was restored.'
                : 'Could not restore your previous DND setting.';
          });
        }
      } else {
        final enabled = await _focusMode.enableDnd();

        if (mounted) {
          setState(() {
            _dndEnabledByApp = enabled;
            _message = enabled
                ? 'Do Not Disturb is enabled.'
                : 'Android did not enable Do Not Disturb.';
          });
        }
      }
    } on PlatformException catch (e) {
      if (mounted) {
        setState(() {
          _message = e.message ?? 'Android permission error.';
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _message = 'Unable to change Do Not Disturb.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  Future<void> _selectSound(FocusSound sound) async {
    setState(() {
      _busy = true;
      _message = null;
      _selectedId = sound.id;
    });

    try {
      await _audio.play(sound);
    } catch (_) {
      if (mounted) {
        setState(() {
          _selectedId = null;
          _message =
              'Audio file missing. Please add ${sound.assetPath} to your project.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  Future<void> _togglePlayback() async {
    try {
      if (_audio.isPlaying) {
        await _audio.pause();
      } else if (_audio.selectedSound != null) {
        await _audio.resume();
      } else {
        await _selectSound(FocusSound.all.first);
        return;
      }

      if (mounted) {
        setState(() {});
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _message = 'Unable to play this sound. Check the audio file.';
        });
      }
    }
  }

  Future<void> _stopAll() async {
    setState(() {
      _busy = true;
    });

    try {
      await _audio.stop();

      bool restored = true;

      if (_dndEnabledByApp) {
        restored = await _focusMode.restoreDnd();
      }

      if (!mounted) return;

      setState(() {
        _selectedId = null;
        _dndEnabledByApp = false;
        _message = restored
            ? 'Deep Focus has been stopped.'
            : 'Audio stopped, but Android could not restore Do Not Disturb.';
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _message = 'Unable to stop Deep Focus completely.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playing = _audio.isPlaying;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        surfaceTintColor: background,
        elevation: 0,
        title: const Text(
          'Deep Focus',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: dark,
            fontSize: 21,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F3EA),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Row(
              children: [
                Icon(Icons.bolt, color: primary, size: 16),
                SizedBox(width: 4),
                Text(
                  'FOCUS MODE',
                  style: TextStyle(
                    color: primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 10,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
        children: [
          _buildHero(playing),

          const SizedBox(height: 22),

          _buildSectionHeading(
            'Distraction control',
            'Create a quieter environment',
            Icons.shield_moon_outlined,
          ),

          const SizedBox(height: 12),

          _buildDndCard(),

          const SizedBox(height: 24),

          _buildSectionHeading(
            'Focus atmosphere',
            'Choose the sound that works for you',
            Icons.graphic_eq_rounded,
          ),

          const SizedBox(height: 14),

          _buildSoundGrid(),

          const SizedBox(height: 24),

          _buildAudioPlayer(playing),

          if (_message != null) ...[
            const SizedBox(height: 16),
            _buildMessage(),
          ],

          const SizedBox(height: 24),

          _buildTipsCard(),

          const SizedBox(height: 16),

          const Text(
            'Note: Android Do Not Disturb follows your phone settings '
            'and permitted exceptions. It does not prevent opening other '
            'applications. Background playback with the screen locked '
            'requires an additional media-service implementation.',
            style: TextStyle(
              color: Colors.black45,
              fontSize: 11,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  // HERO SECTION

  Widget _buildHero(bool playing) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF102A21),
            Color(0xFF176C4B),
            Color(0xFF16845B),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(0.20),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -18,
            top: -25,
            child: Icon(
              Icons.headphones_rounded,
              size: 145,
              color: Colors.white.withOpacity(0.07),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.13),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      playing
                          ? Icons.graphic_eq
                          : Icons.spa_outlined,
                      color: Colors.white,
                      size: 15,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      playing ? 'SOUND PLAYING' : 'YOUR FOCUS SPACE',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Lock in.\nTune out.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 31,
                  height: 1.1,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                'Build your personal study environment '
                'and give your attention one clear direction.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 13,
                  height: 1.6,
                ),
              ),

              const SizedBox(height: 22),

              Row(
                children: [
                  Expanded(
                    child: _heroFeature(
                      Icons.notifications_off_outlined,
                      'Less noise',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _heroFeature(
                      Icons.music_note_rounded,
                      'Focus audio',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _heroFeature(
                      Icons.self_improvement_rounded,
                      'Stay calm',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroFeature(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 11,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // SECTION HEADING

  Widget _buildSectionHeading(
    String title,
    String subtitle,
    IconData icon,
  ) {
    return Row(
      children: [
        Container(
          height: 42,
          width: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFE3F3EA),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, color: primary, size: 22),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: dark,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // DND CARD

  Widget _buildDndCard() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                height: 47,
                width: 47,
                decoration: BoxDecoration(
                  color: _dndEnabledByApp
                      ? const Color(0xFFE3F3EA)
                      : const Color(0xFFF1F3F2),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  Icons.notifications_off_rounded,
                  color: _dndEnabledByApp ? primary : Colors.grey,
                  size: 23,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Do Not Disturb',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: dark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      !_hasDndAccess
                          ? 'Permission required'
                          : _dndEnabledByApp
                              ? 'Enabled by FocusTech'
                              : 'Silence interruptions',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: _dndEnabledByApp,
                activeColor: primary,
                onChanged: _busy ? null : (_) => _toggleDnd(),
              ),
            ],
          ),

          if (!_hasDndAccess) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _busy ? null : _toggleDnd,
                icon: const Icon(Icons.settings_outlined, size: 18),
                label: const Text('Grant DND permission'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: primary,
                  side: const BorderSide(color: primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // SOUND GRID

  Widget _buildSoundGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: FocusSound.all.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: 142,
      ),
      itemBuilder: (context, index) {
        final sound = FocusSound.all[index];
        final selected = _selectedId == sound.id;
        final isPlaying = selected && _audio.isPlaying;

        return InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: _busy ? null : () => _selectSound(sound),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: selected ? const Color(0xFFE5F4EB) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selected
                    ? primary
                    : const Color(0xFFE9EEEA),
                width: selected ? 1.7 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.025),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      height: 42,
                      width: 42,
                      decoration: BoxDecoration(
                        color: selected
                            ? primary.withOpacity(0.13)
                            : const Color(0xFFF1F5F2),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Icon(
                        _iconFor(sound.id),
                        color: primary,
                        size: 22,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      isPlaying
                          ? Icons.equalizer_rounded
                          : selected
                              ? Icons.check_circle_rounded
                              : Icons.play_circle_outline_rounded,
                      color: primary,
                      size: 22,
                    ),
                  ],
                ),

                const Spacer(),

                Text(
                  sound.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: dark,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  sound.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 10,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // AUDIO PLAYER

  Widget _buildAudioPlayer(bool playing) {
    return Container(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: dark,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: dark.withOpacity(0.15),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.headphones_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Focus player',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _selectedId == null
                          ? 'Choose a sound to begin'
                          : playing
                              ? 'Now playing'
                              : 'Ready to resume',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.65),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              if (playing)
                const Icon(
                  Icons.graphic_eq_rounded,
                  color: Color(0xFF67DDA6),
                  size: 25,
                ),
            ],
          ),

          const SizedBox(height: 22),

          Row(
            children: [
              const Icon(
                Icons.volume_down_rounded,
                color: Colors.white70,
                size: 20,
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: const Color(0xFF67DDA6),
                    inactiveTrackColor: Colors.white24,
                    thumbColor: Colors.white,
                    overlayColor: primary.withOpacity(0.2),
                    trackHeight: 4,
                  ),
                  child: Slider(
                    value: _volume,
                    min: 0,
                    max: 1,
                    onChanged: (value) {
                      setState(() {
                        _volume = value;
                      });
                      _audio.setVolume(value);
                    },
                  ),
                ),
              ),
              Text(
                '${(_volume * 100).round()}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 49,
                  child: FilledButton.icon(
                    onPressed: _busy ? null : _togglePlayback,
                    icon: Icon(
                      playing
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                    ),
                    label: Text(
                      playing ? 'Pause sound' : 'Play / Resume',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF67DDA6),
                      foregroundColor: dark,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 49,
                child: OutlinedButton(
                  onPressed: _busy ? null : _stopAll,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white30),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Icon(Icons.stop_rounded),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // MESSAGE

  Widget _buildMessage() {
    final isSuccess = _message!.contains('enabled') ||
        _message!.contains('restored') ||
        _message!.contains('stopped');

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isSuccess
            ? const Color(0xFFE3F3EA)
            : const Color(0xFFFFF1E8),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(
            isSuccess
                ? Icons.check_circle_outline
                : Icons.info_outline,
            color: isSuccess ? primary : Colors.deepOrange,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _message!,
              style: TextStyle(
                color: isSuccess
                    ? const Color(0xFF176C4B)
                    : Colors.deepOrange.shade800,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // TIPS

  Widget _buildTipsCard() {
    return Container(
      decoration: _cardDecoration(),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 17,
              vertical: 4,
            ),
            leading: Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF2D9),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(
                Icons.lightbulb_outline_rounded,
                color: Color(0xFFD69A2D),
              ),
            ),
            title: const Text(
              'Get the most out of Deep Focus',
              style: TextStyle(
                color: dark,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
            subtitle: const Text(
              'Simple ways to improve your session',
              style: TextStyle(fontSize: 10),
            ),
            trailing: Icon(
              _showTips
                  ? Icons.keyboard_arrow_up
                  : Icons.keyboard_arrow_down,
              color: primary,
            ),
            onTap: () {
              setState(() {
                _showTips = !_showTips;
              });
            },
          ),

          AnimatedCrossFade(
            duration: const Duration(milliseconds: 250),
            crossFadeState: _showTips
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox(
              width: double.infinity,
              height: 1,
            ),
            secondChild: const Padding(
              padding: EdgeInsets.fromLTRB(18, 0, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(),
                  _TipRow(
                    number: '01',
                    text: 'Connect your headphones or earphones.',
                  ),
                  _TipRow(
                    number: '02',
                    text: 'Choose a background sound you enjoy.',
                  ),
                  _TipRow(
                    number: '03',
                    text: 'Enable Do Not Disturb to reduce interruptions.',
                  ),
                  _TipRow(
                    number: '04',
                    text: 'Return to your study timer and focus on one subject.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFFEBF0EC)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.025),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  IconData _iconFor(String id) {
    switch (id) {
      case 'lofi':
        return Icons.music_note_rounded;
      case 'brown_noise':
      case 'white_noise':
        return Icons.graphic_eq_rounded;
      case 'rain':
        return Icons.water_drop_outlined;
      case 'nature':
        return Icons.forest_outlined;
      default:
        return Icons.spa_outlined;
    }
  }
}

class _TipRow extends StatelessWidget {
  const _TipRow({
    required this.number,
    required this.text,
  });

  final String number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            number,
            style: const TextStyle(
              color: Color(0xFF16845B),
              fontWeight: FontWeight.w900,
              fontSize: 11,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF53665C),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
