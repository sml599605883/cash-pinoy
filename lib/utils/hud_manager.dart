import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'screen_adapter.dart';

enum HudMode { loading, success, failure, message }

class HudManager {
  // static GlobalKey<OverlayState>? _overlayKey;
  static Completer<void>? _completer;
  static Timer? _timer;
  static int _operationId = 0;
  static final ValueNotifier<_HudViewState> _state =
      ValueNotifier<_HudViewState>(_HudViewState.hidden());

  static void init(GlobalKey<OverlayState> key) {
    // _overlayKey = key;
  }

  static Widget overlayLayer() {
    return ValueListenableBuilder<_HudViewState>(
      valueListenable: _state,
      builder: (_, state, __) {
        if (!state.visible) return const SizedBox.shrink();
        return _HudOverlay(mode: state.mode!, message: state.message);
      },
    );
  }

  static Future<void> showLoading({String? message}) {
    _show(
      mode: HudMode.loading,
      message: message,
      autoDismiss: false,
      awaitable: false,
    );
    return Future.value();
  }

  static Future<void> showSuccess({
    String? message,
    Duration duration = const Duration(seconds: 2),
    VoidCallback? onDismiss,
  }) {
    return _show(
      mode: HudMode.success,
      message: message,
      autoDismiss: true,
      duration: duration,
      onDismiss: onDismiss,
    );
  }

  static Future<void> showFailure({
    String? message,
    Duration duration = const Duration(seconds: 2),
    VoidCallback? onDismiss,
  }) {
    return _show(
      mode: HudMode.failure,
      message: message,
      autoDismiss: true,
      duration: duration,
      onDismiss: onDismiss,
    );
  }

  static Future<void> showMessage({
    required String message,
    Duration duration = const Duration(seconds: 2),
    VoidCallback? onDismiss,
  }) {
    return _show(
      mode: HudMode.message,
      message: message,
      autoDismiss: true,
      duration: duration,
      onDismiss: onDismiss,
    );
  }

  static void dismiss() {
    final operationId = ++_operationId;
    _timer?.cancel();
    _timer = null;
    _setStateSafely(_HudViewState.hidden(), operationId);
    _completer?.complete();
    _completer = null;
  }

  static bool get isShowing => _state.value.visible;

  static Future<void> _show({
    required HudMode mode,
    String? message,
    required bool autoDismiss,
    bool awaitable = true,
    Duration duration = const Duration(seconds: 2),
    VoidCallback? onDismiss,
  }) {
    _timer?.cancel();
    _timer = null;

    _completer?.complete();
    _completer = null;

    final operationId = ++_operationId;

    _completer = awaitable ? Completer<void>() : null;

    _setStateSafely(
      _HudViewState(visible: true, mode: mode, message: message),
      operationId,
    );

    if (autoDismiss) {
      _timer = Timer(duration, () {
        if (operationId != _operationId) return;
        dismiss();
        onDismiss?.call();
      });
    } else if (onDismiss != null) {
      _completer?.future.whenComplete(onDismiss);
    }

    return _completer?.future ?? Future.value();
  }

  static void _setStateSafely(_HudViewState next, int operationId) {
    void apply() {
      if (operationId != _operationId) return;
      _state.value = next;
    }

    final phase = SchedulerBinding.instance.schedulerPhase;
    if (phase == SchedulerPhase.idle ||
        phase == SchedulerPhase.postFrameCallbacks) {
      apply();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) => apply());
    }
  }
}

class _HudViewState {
  final bool visible;
  final HudMode? mode;
  final String? message;

  const _HudViewState({
    required this.visible,
    required this.mode,
    this.message,
  });

  const _HudViewState.hidden() : visible = false, mode = null, message = null;
}

class _HudOverlay extends StatelessWidget {
  final HudMode mode;
  final String? message;

  const _HudOverlay({required this.mode, this.message});

  @override
  Widget build(BuildContext context) {
    final showText = message != null && message!.trim().isNotEmpty;
    return Stack(
      children: [
        Positioned.fill(
          child: AbsorbPointer(
            absorbing: true,
            child: Container(color: Colors.black.withOpacity(0.6)),
          ),
        ),
        Center(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 40.w),
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.78),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildIcon(),
                if (showText) ...[
                  SizedBox(height: 10.h),
                  Text(
                    message!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIcon() {
    switch (mode) {
      case HudMode.loading:
        return SizedBox(
          width: 28.w,
          height: 28.w,
          child: const CircularProgressIndicator(
            strokeWidth: 2.6,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        );
      case HudMode.success:
        return Icon(Icons.check_circle, color: Colors.white, size: 28.w);
      case HudMode.failure:
        return Icon(Icons.cancel, color: Colors.white, size: 28.w);
      case HudMode.message:
        return Icon(Icons.info, color: Colors.white, size: 28.w);
    }
  }
}
