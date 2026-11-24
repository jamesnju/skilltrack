class FocusSound {
  final String id;
  final String name;
  final String description;
  final String assetPath;

  const FocusSound({
    required this.id,
    required this.name,
    required this.description,
    required this.assetPath,
  });

  static const List<FocusSound> all = [
    FocusSound(
      id: 'lofi',
      name: 'Lo-fi beats',
      description: 'Gentle instrumental background music',
      assetPath: 'assets/sounds/lofi.mp3',
    ),

    FocusSound(
      id: 'brown_noise',
      name: 'Brown noise',
      description: 'Low, steady noise for masking distractions',
      assetPath: 'assets/sounds/brown_noise.mp3',
    ),

    FocusSound(
      id: 'white_noise',
      name: 'White noise',
      description: 'Even background noise',
      assetPath: 'assets/sounds/white_noise.mp3',
    ),

    FocusSound(
      id: 'rain',
      name: 'Rain',
      description: 'Soft rainfall ambience',
      assetPath: 'assets/sounds/rain.mp3',
    ),

    FocusSound(
      id: 'nature',
      name: 'Nature',
      description: 'Calm outdoor ambience',
      assetPath: 'assets/sounds/nature.mp3',
    ),

    FocusSound(
      id: 'ambient',
      name: 'Ambient focus',
      description: 'Quiet atmospheric soundscape',
      assetPath: 'assets/sounds/ambient.mp3',
    ),
  ];
}
