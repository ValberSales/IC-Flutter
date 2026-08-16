import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class MascoteFeedbackWidget extends StatefulWidget {
  final String feedbackType; // 'ACERTO' | 'ERRO' | 'VAZIO'
  final VoidCallback clearFeedback;
  final double scale;

  const MascoteFeedbackWidget({
    super.key,
    required this.feedbackType,
    required this.clearFeedback,
    this.scale = 1.0,
  });

  @override
  State<MascoteFeedbackWidget> createState() => _MascoteFeedbackWidgetState();
}

class _MascoteFeedbackWidgetState extends State<MascoteFeedbackWidget> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimerIfNeeded();
  }

  @override
  void didUpdateWidget(covariant MascoteFeedbackWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.feedbackType != widget.feedbackType) {
      _startTimerIfNeeded();
    }
  }

  void _startTimerIfNeeded() {
    _timer?.cancel();
    if (widget.feedbackType != 'VAZIO') {
      _timer = Timer(const Duration(seconds: 2), () {
        if (mounted) {
          widget.clearFeedback();
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.feedbackType == 'VAZIO') {
      // Retorna o guaxinim neutro
      return Image.asset(
        'assets/raccoon/raccoon.png',
        width: 160 * widget.scale,
        height: 160 * widget.scale,
      );
    }

    final isCorrect = widget.feedbackType == 'ACERTO';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.elasticOut,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: (isCorrect ? AppColors.accent : AppColors.error).withValues(alpha: 0.25),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: (isCorrect ? AppColors.accent : AppColors.error),
          width: 3,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // GIF do Mascote
          Image.asset(
            isCorrect
                ? 'assets/raccoon/gif/victory-dance.gif'
                : 'assets/raccoon/gif/crouch.gif',
            width: 140 * widget.scale,
            height: 140 * widget.scale,
          ),
          const SizedBox(width: 12),
          
          // Badge Animada de Feedback
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 500),
            curve: Curves.elasticOut,
            builder: (context, val, child) {
              return Transform.scale(
                scale: val,
                child: child,
              );
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isCorrect
                    ? AppColors.accentLight.withValues(alpha: 0.4)
                    : AppColors.errorLight.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCorrect ? Icons.thumb_up_rounded : Icons.thumb_down_rounded,
                color: isCorrect ? AppColors.accent : AppColors.error,
                size: 48 * widget.scale,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
