import 'package:flutter/material.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';

void main() {
  runApp(const CharacterApp());
}

class CharacterApp extends StatelessWidget {
  const CharacterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '3D Character',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF6C5CE7),
        brightness: Brightness.dark,
        fontFamily: 'Roboto',
      ),
      home: const CharacterHomePage(),
    );
  }
}

class CharacterAction {
  final String label;
  final String assetPath;
  final IconData icon;
  final Color color;

  const CharacterAction({
    required this.label,
    required this.assetPath,
    required this.icon,
    required this.color,
  });
}

class CharacterHomePage extends StatefulWidget {
  const CharacterHomePage({super.key});

  @override
  State<CharacterHomePage> createState() => _CharacterHomePageState();
}

class _CharacterHomePageState extends State<CharacterHomePage> {
  final Flutter3DController controller = Flutter3DController();

  final List<CharacterAction> actions = const [
    CharacterAction(
      label: 'Jog',
      assetPath: 'assets/models/Jogging.glb',
      icon: Icons.directions_run_rounded,
      color: Color(0xFF00B894),
    ),
    CharacterAction(
      label: 'Box',
      assetPath: 'assets/models/Boxing.glb',
      icon: Icons.sports_mma_rounded,
      color: Color(0xFFE17055),
    ),
    CharacterAction(
      label: 'Sit-ups',
      assetPath: 'assets/models/Situps.glb',
      icon: Icons.fitness_center_rounded,
      color: Color(0xFF0984E3),
    ),
    CharacterAction(
      label: 'Dance',
      assetPath: 'assets/models/dance.glb',
      icon: Icons.music_note_rounded,
      color: Color(0xFFE84393),
    ),
  ];

  int selectedIndex = 0;
  bool isLoading = true;

  String get currentAsset => actions[selectedIndex].assetPath;

  void selectAction(int index) {
    if (index == selectedIndex) return;
    setState(() {
      selectedIndex = index;
      isLoading = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final current = actions[selectedIndex];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F1128)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'My Character',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Tap an action below',
                          style: TextStyle(fontSize: 14, color: Colors.white54),
                        ),
                      ],
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: current.color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: current.color.withOpacity(0.5),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(current.icon, size: 16, color: current.color),
                          const SizedBox(width: 6),
                          Text(
                            current.label,
                            style: TextStyle(
                              color: current.color,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.06),
                          Colors.white.withOpacity(0.02),
                        ],
                      ),
                      border: Border.all(color: Colors.white.withOpacity(0.08)),
                      boxShadow: [
                        BoxShadow(
                          color: current.color.withOpacity(0.15),
                          blurRadius: 40,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Flutter3DViewer(
                            key: ValueKey(currentAsset),
                            src: currentAsset,
                            controller: controller,
                            progressBarColor: current.color,
                            onLoad: (_) {
                              if (mounted) {
                                setState(() => isLoading = false);

                                controller.playAnimation();
                              }
                            },
                            onError: (error) {
                              debugPrint('Model failed to load: $error');
                              if (mounted) {
                                setState(() => isLoading = false);
                              }
                            },
                          ),
                        ),
                        if (isLoading)
                          Positioned.fill(
                            child: Container(
                              color: const Color(0xFF16213E).withOpacity(0.85),
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircularProgressIndicator(
                                      color: current.color,
                                    ),
                                    const SizedBox(height: 14),
                                    Text(
                                      'Loading ${current.label}...',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Row(
                  children: List.generate(actions.length, (index) {
                    final action = actions[index];
                    final isSelected = index == selectedIndex;
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: index == 0 ? 0 : 6,
                          right: index == actions.length - 1 ? 0 : 6,
                        ),
                        child: GestureDetector(
                          onTap: () => selectAction(index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOut,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? action.color
                                  : Colors.white.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: isSelected
                                    ? action.color
                                    : Colors.white.withOpacity(0.1),
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: action.color.withOpacity(0.4),
                                        blurRadius: 16,
                                        offset: const Offset(0, 6),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  action.icon,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.white60,
                                  size: 22,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  action.label,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.white60,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
