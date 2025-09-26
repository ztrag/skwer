import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fullscreen_window/fullscreen_window.dart';

class FastKeyEvent {
  final FastKeyEventType type;
  final LogicalKeyboardKey logicalKey;

  FastKeyEvent(this.type, this.logicalKey);
}

enum FastKeyEventType {
  down,
  repeat,
  up,
}

typedef FastKeyEventCallback = KeyEventResult Function(FastKeyEvent event);

class FastKeyFocusController {
  static bool isFullscreen = false;

  final Map<LogicalKeyboardKey, Duration> _downKeys = {};

  Duration? getKeyDownTime(LogicalKeyboardKey key) => _downKeys[key];

  KeyEventResult _onKeyEvent(
      KeyEvent event, State state, FastKeyEventCallback onKeyEvent) {
    if (event is KeyDownEvent) {
      _downKeys[event.logicalKey] = event.timeStamp;
      if (Platform.isWindows &&
          (_downKeys[LogicalKeyboardKey.altLeft] != null ||
              _downKeys[LogicalKeyboardKey.altRight] != null) &&
          event.logicalKey == LogicalKeyboardKey.enter) {
        isFullscreen = !isFullscreen;
        FullScreenWindow.setFullScreen(isFullscreen);
        return KeyEventResult.handled;
      }

      final result =
          onKeyEvent(FastKeyEvent(FastKeyEventType.down, event.logicalKey));
      if (result == KeyEventResult.handled) {
        _startRepeatTicker(event, state, onKeyEvent);
      }
      return result;
    } else if (event is KeyUpEvent) {
      _downKeys.remove(event.logicalKey);
      final result =
          onKeyEvent(FastKeyEvent(FastKeyEventType.up, event.logicalKey));
      return result;
    } else if (event is KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.ignored;
  }

  void _startRepeatTicker(
      KeyDownEvent event, State state, FastKeyEventCallback onKeyEvent) async {
    await Future.delayed(const Duration(milliseconds: 200));
    while (true) {
      await Future.delayed(const Duration(milliseconds: 50));
      if (!state.mounted) {
        return;
      }
      if (_downKeys[event.logicalKey] != event.timeStamp) {
        return;
      }
      onKeyEvent(FastKeyEvent(FastKeyEventType.repeat, event.logicalKey));
    }
  }
}

class FastKeyFocusScope extends StatefulWidget {
  final FastKeyFocusController? controller;
  final bool autofocus;
  final FocusScopeNode node;
  final FastKeyEventCallback onKeyEvent;
  final Widget child;

  const FastKeyFocusScope({
    Key? key,
    this.controller,
    this.autofocus = false,
    required this.node,
    required this.onKeyEvent,
    required this.child,
  }) : super(key: key);

  @override
  State<FastKeyFocusScope> createState() => _FastKeyFocusScopeState();
}

class _FastKeyFocusScopeState extends State<FastKeyFocusScope> {
  late final FastKeyFocusController controller =
      widget.controller ?? FastKeyFocusController();

  @override
  Widget build(BuildContext context) {
    return FocusScope(
      autofocus: widget.autofocus,
      node: widget.node,
      onKeyEvent: (_, e) => controller._onKeyEvent(e, this, widget.onKeyEvent),
      child: widget.child,
    );
  }
}

class FastKeyFocus extends StatefulWidget {
  final FastKeyFocusController? controller;
  final bool autofocus;
  final FocusNode node;
  final ValueChanged<bool>? onFocusChange;
  final FastKeyEventCallback onKeyEvent;
  final Widget child;

  const FastKeyFocus({
    Key? key,
    this.controller,
    this.autofocus = false,
    this.onFocusChange,
    required this.node,
    required this.onKeyEvent,
    required this.child,
  }) : super(key: key);

  @override
  State<FastKeyFocus> createState() => _FastKeyFocusState();
}

class _FastKeyFocusState extends State<FastKeyFocus> {
  late final FastKeyFocusController controller =
      widget.controller ?? FastKeyFocusController();

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: widget.autofocus,
      focusNode: widget.node,
      onFocusChange: widget.onFocusChange,
      onKeyEvent: (_, e) => controller._onKeyEvent(e, this, widget.onKeyEvent),
      child: widget.child,
    );
  }
}
