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
        colorSchemeSeed: const Color(0xFF2D2D2D),
        brightness: Brightness.light,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFFF5F5F3),
      ),
      home: const CharacterHomePage(),
    );
  }
}

class CharacterAction {
  final String label;
  final String animationName;
  final IconData icon;

  const CharacterAction({
    required this.label,
    required this.animationName,
    required this.icon,
  });
}

class CharacterHomePage extends StatefulWidget {
  const CharacterHomePage({super.key});

  @override
  State<CharacterHomePage> createState() => _CharacterHomePageState();
}

class _CharacterHomePageState extends State<CharacterHomePage> {
  final Flutter3DController controller = Flutter3DController();

  static const String modelPath = 'assets/models/mini_character.glb';
  static const Color accent = Color(0xFF2D2D2D);

  static const CharacterAction idleAction = CharacterAction(
    label: 'Idle',
    animationName: 'Idle',
    icon: Icons.accessibility_new_rounded,
  );

  final List<CharacterAction> actions = const [
    CharacterAction(
      label: 'Walk',
      animationName: 'Walk',
      icon: Icons.directions_walk_rounded,
    ),
    CharacterAction(
      label: 'Run',
      animationName: 'Run',
      icon: Icons.directions_run_rounded,
    ),
    CharacterAction(
      label: 'Jump',
      animationName: 'Jump',
      icon: Icons.arrow_upward_rounded,
    ),
    CharacterAction(
      label: 'Loose',
      animationName: 'Loose',
      icon: Icons.celebration_rounded,
    ),
  ];

  int? selectedIndex;
  bool isLoading = true;
  double cardScale = 1.0;

  void _pulse() async {
    setState(() => cardScale = 0.98);
    await Future.delayed(const Duration(milliseconds: 120));
    if (mounted) setState(() => cardScale = 1.0);
  }

  void _frameCamera() {
    controller.resetCameraOrbit();
    controller.resetCameraTarget();
  }

  void selectAction(int index) {
    if (index == selectedIndex) return;
    setState(() => selectedIndex = index);
    controller.playAnimation(animationName: actions[index].animationName);
    _frameCamera();
    _pulse();
  }

  void goIdle() {
    if (selectedIndex == null) return;
    setState(() => selectedIndex = null);
    controller.playAnimation(animationName: idleAction.animationName);
    _frameCamera();
    _pulse();
  }

  @override
  Widget build(BuildContext context) {
    final current = selectedIndex == null
        ? idleAction
        : actions[selectedIndex!];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Character',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                      letterSpacing: -0.5,
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE0E0DE)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(current.icon, size: 14, color: accent),
                        const SizedBox(width: 6),
                        Text(
                          current.label,
                          style: const TextStyle(
                            color: accent,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
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
                child: AnimatedScale(
                  scale: cardScale,
                  duration: const Duration(milliseconds: 120),
                  curve: Curves.easeOut,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFE8E8E6)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Flutter3DViewer(
                            src: modelPath,
                            controller: controller,
                            progressBarColor: accent,
                            onLoad: (_) {
                              if (mounted) {
                                setState(() => isLoading = false);
                                controller.playAnimation(
                                  animationName: idleAction.animationName,
                                );
                                _frameCamera();
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
                              color: Colors.white,
                              child: const Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircularProgressIndicator(
                                      color: accent,
                                      strokeWidth: 2,
                                    ),
                                    SizedBox(height: 14),
                                    Text(
                                      'Loading character...',
                                      style: TextStyle(
                                        color: Color(0xFF9A9A98),
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
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Row(
                children: [
                  _buildButton(
                    label: idleAction.label,
                    icon: idleAction.icon,
                    isSelected: selectedIndex == null,
                    isFirst: true,
                    isLast: false,
                    onTap: goIdle,
                  ),
                  ...List.generate(actions.length, (index) {
                    final action = actions[index];
                    return _buildButton(
                      label: action.label,
                      icon: action.icon,
                      isSelected: index == selectedIndex,
                      isFirst: false,
                      isLast: index == actions.length - 1,
                      onTap: () => selectAction(index),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required bool isFirst,
    required bool isLast,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(left: isFirst ? 0 : 5, right: isLast ? 0 : 5),
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? accent : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? accent : const Color(0xFFE0E0DE),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  icon,
                  color: isSelected ? Colors.white : const Color(0xFF6B6B69),
                  size: 19,
                ),
                const SizedBox(height: 5),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? Colors.white : const Color(0xFF6B6B69),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
