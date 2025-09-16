import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

class FastKeyFocusScope extends StatefulWidget {
  final bool autofocus;
  final FocusScopeNode node;
  final FastKeyEventCallback onKeyEvent;
  final Widget child;

  const FastKeyFocusScope({
    Key? key,
    required this.autofocus,
    required this.node,
    required this.onKeyEvent,
    required this.child,
  }) : super(key: key);

  @override
  State<FastKeyFocusScope> createState() => _FastKeyFocusScopeState();
}

class _FastKeyFocusScopeState extends State<FastKeyFocusScope> {
  final Map<PhysicalKeyboardKey, Duration> _downKeys = {};

  @override
  Widget build(BuildContext context) {
    return FocusScope(
      autofocus: widget.autofocus,
      node: widget.node,
      onKeyEvent: _onKeyEvent,
      child: widget.child,
    );
  }

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
      final result = widget
          .onKeyEvent(FastKeyEvent(FastKeyEventType.down, event.logicalKey));
      if (result == KeyEventResult.handled) {
        _downKeys[event.physicalKey] = event.timeStamp;
        _startRepeatTicker(event);
      }
      return result;
    } else if (event is KeyUpEvent) {
      final result = widget
          .onKeyEvent(FastKeyEvent(FastKeyEventType.up, event.logicalKey));
      _downKeys.remove(event.physicalKey);
      return result;
    } else if (event is KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.ignored;
  }

  void _startRepeatTicker(KeyDownEvent event) async {
    await Future.delayed(const Duration(milliseconds: 200));
    while (true) {
      await Future.delayed(const Duration(milliseconds: 50));
      if (_downKeys[event.physicalKey] != event.timeStamp) {
        return;
      }
      widget
          .onKeyEvent(FastKeyEvent(FastKeyEventType.repeat, event.logicalKey));
    }
  }
}
