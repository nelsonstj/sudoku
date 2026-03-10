import 'package:flutter/material.dart';

class GameCompletionCurtain extends StatefulWidget {
  final String title;
  final String time;
  final Duration appearDuration;
  final Duration holdDuration;
  final Duration disappearDuration;
  final VoidCallback? onComplete;

  const GameCompletionCurtain({
    super.key,
    required this.title,
    required this.time,
    this.appearDuration = const Duration(milliseconds: 800),
    this.holdDuration = const Duration(seconds: 4),
    this.disappearDuration = const Duration(milliseconds: 800),
    this.onComplete,
  });

  @override
  State<GameCompletionCurtain> createState() => _GameCompletionCurtainState();
}

class _GameCompletionCurtainState extends State<GameCompletionCurtain>
    with TickerProviderStateMixin {
  late AnimationController _appearController;
  late AnimationController _disappearController;

  @override
  void initState() {
    super.initState();

    // Controller para animação de entrada (de baixo para cima)
    _appearController = AnimationController(
      duration: widget.appearDuration,
      vsync: this,
    );

    // Controller para animação de saída (de cima para baixo)
    _disappearController = AnimationController(
      duration: widget.disappearDuration,
      vsync: this,
    );

    _startAnimation();
  }

  void _startAnimation() async {
    // Fase 1: Subir (de baixo para cima)
    await _appearController.forward();

    // Fase 2: Ficar parado
    await Future.delayed(widget.holdDuration);

    if (mounted) {
      // Fase 3: Descer (de cima para baixo)
      await _disappearController.forward();

      // Callback ao completar
      widget.onComplete?.call();
    }
  }

  @override
  void dispose() {
    _appearController.dispose();
    _disappearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_appearController, _disappearController]),
      builder: (context, child) {
        // Se a animação de desaparecimento terminou, não renderizar nada
        if (_disappearController.isCompleted) {
          return const SizedBox.shrink();
        }

        // Calcular a posição dependendo de qual animation controller está ativo
        Offset currentOffset;
        if (_appearController.isAnimating || 
            (_appearController.isCompleted && !_disappearController.isAnimating)) {
          // Durante a entrada, slide de 1 (baixo) para 0 (topo)
          currentOffset = Offset(
            0,
            1 - _appearController.value,
          );
        } else {
          // Durante a saída, slide de 0 (topo) para 1 (baixo)
          currentOffset = Offset(
            0,
            _disappearController.value,
          );
        }

        return Transform.translate(
          offset: currentOffset * MediaQuery.of(context).size.height * 0.3,
          child: child,
        );
      },
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
          constraints: const BoxConstraints(minWidth: 300),
          decoration: BoxDecoration(
            color: const Color.fromARGB(200, 255, 162, 0),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '🎉',
                style: TextStyle(fontSize: 48),
              ),
              const SizedBox(height: 12),
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '⏱ ${widget.time}',
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
