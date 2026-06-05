import 'package:flutter/material.dart';
import '../../core/utils/app_error_formatter.dart';

enum AppToastType {
  success,
  error,
  info,
}

class AppToast {
  static void show(
    BuildContext context, {
    required String message,
    AppToastType type = AppToastType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final overlayState = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _ToastWidget(
        message: message,
        type: type,
        duration: duration,
        onDismissed: () {
          overlayEntry.remove();
        },
      ),
    );

    overlayState.insert(overlayEntry);
  }

  static void success(BuildContext context, {required String message, Duration duration = const Duration(seconds: 3)}) {
    show(context, message: message, type: AppToastType.success, duration: duration);
  }

  static void error(BuildContext context, {required String message, Duration duration = const Duration(seconds: 3)}) {
    final sanitized = AppErrorFormatter.sanitizeMessageString(message);
    show(context, message: sanitized, type: AppToastType.error, duration: duration);
  }

  static void info(BuildContext context, {required String message, Duration duration = const Duration(seconds: 3)}) {
    show(context, message: message, type: AppToastType.info, duration: duration);
  }
}

class _ToastWidget extends StatefulWidget {
  final String message;
  final AppToastType type;
  final Duration duration;
  final VoidCallback onDismissed;

  const _ToastWidget({
    required this.message,
    required this.type,
    required this.duration,
    required this.onDismissed,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _opacityAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<double>(begin: -50.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();

    Future.delayed(widget.duration - const Duration(milliseconds: 350), () {
      if (mounted) {
        _controller.reverse().then((_) {
          widget.onDismissed();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getBackgroundColor(ThemeData theme) {
    switch (widget.type) {
      case AppToastType.success:
        return const Color(0xFFE2F4E6); // Verde suave
      case AppToastType.error:
        return const Color(0xFFFBEBEB); // Vermelho/Rosa suave
      case AppToastType.info:
        return theme.colorScheme.surface;
    }
  }

  Color _getTextColor(ThemeData theme) {
    switch (widget.type) {
      case AppToastType.success:
        return const Color(0xFF1E6B30);
      case AppToastType.error:
        return const Color(0xFFC0392B);
      case AppToastType.info:
        return theme.colorScheme.onSurface;
    }
  }

  IconData _getIcon() {
    switch (widget.type) {
      case AppToastType.success:
        return Icons.check_circle_outline_rounded;
      case AppToastType.error:
        return Icons.error_outline_rounded;
      case AppToastType.info:
        return Icons.info_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = _getBackgroundColor(theme);
    final textColor = _getTextColor(theme);
    final icon = _getIcon();

    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _slideAnimation.value),
              child: Opacity(
                opacity: _opacityAnimation.value,
                child: child,
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.only(top: 24, left: 16, right: 16),
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                  border: Border.all(
                    color: textColor.withValues(alpha: 0.15),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: textColor, size: 22),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        widget.message,
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
