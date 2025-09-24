import 'package:flutter/material.dart';

const double kVLimit1 = 0.75;
const double kVLimit2 = 0.85;

enum Direction {
  left,
  right,
  up,
  down,
}

enum TouchArrowEventType {
  down,
  repeat,
  up,
}

class TouchArrowEvent {
  final TouchArrowEventType type;
  final Duration touchTime;
  final Direction direction;

  TouchArrowEvent._(this.type, this.touchTime, this.direction);
}

class _DirectionlessEvent extends TouchArrowEvent {
  _DirectionlessEvent()
      : super._(TouchArrowEventType.up, Duration.zero, Direction.left);
}

typedef OnTouchEvent = void Function(TouchArrowEvent event);

class TouchArrows extends StatefulWidget {
  final TouchArrowsController? controller;
  final OnTouchEvent? onTouchEvent;
  final Widget child;

  const TouchArrows(
      {Key? key, required this.child, this.onTouchEvent, this.controller})
      : super(key: key);

  @override
  State<TouchArrows> createState() => _TouchArrowsState();
}

class _TouchArrowsState extends State<TouchArrows> {
  late final TouchArrowsController controller =
      widget.controller ?? TouchArrowsController();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) => Stack(
        children: [
          Listener(
            onPointerDown: (e) => _onPointerDown(e, constraints),
            onPointerMove: (e) => _onPointerMove(e, constraints),
            onPointerUp: _onPointerUp,
            onPointerCancel: _onPointerUp,
            child: widget.child,
          ),
        ],
      ),
    );
  }

  void _onPointerDown(PointerDownEvent down, BoxConstraints constraints) {
    final direction = _directionFromTouch(down, constraints);
    final event = direction == null
        ? _DirectionlessEvent()
        : TouchArrowEvent._(
            TouchArrowEventType.down,
            down.timeStamp,
            direction,
          );
    controller._touching[down.pointer] = event;
    if (event is! _DirectionlessEvent && widget.onTouchEvent != null) {
      widget.onTouchEvent!(event);
    }
    _startRepeatTicker(down);
  }

  void _onPointerMove(PointerMoveEvent move, BoxConstraints constraints) {
    final direction = _directionFromTouch(move, constraints);
    final current = controller._touching[move.pointer]!;
    if (current.direction == direction) {
      return;
    }

    final event = direction == null
        ? _DirectionlessEvent()
        : TouchArrowEvent._(
            TouchArrowEventType.down,
            move.timeStamp,
            direction,
          );
    controller._touching[move.pointer] = event;

    if (current is! _DirectionlessEvent && widget.onTouchEvent != null) {
      widget.onTouchEvent!(
        TouchArrowEvent._(
          TouchArrowEventType.up,
          move.timeStamp,
          current.direction,
        ),
      );
    }

    if (event is! _DirectionlessEvent && widget.onTouchEvent != null) {
      widget.onTouchEvent!(event);
    }
  }

  void _onPointerUp(PointerEvent up) {
    final current = controller._touching[up.pointer]!;
    controller._touching.remove(up.pointer);

    if (current is! _DirectionlessEvent && widget.onTouchEvent != null) {
      widget.onTouchEvent!(
        TouchArrowEvent._(
          TouchArrowEventType.up,
          up.timeStamp,
          current.direction,
        ),
      );
    }
  }

  Direction? _directionFromTouch(
      PointerEvent event, BoxConstraints constraints) {
    final w = constraints.maxWidth;
    final h = constraints.maxHeight;

    if (event.position.dy < h * kVLimit1) {
      return Direction.up;
    } else if (event.position.dy > h * kVLimit2 &&
        event.position.dx > w / 3 &&
        event.position.dx < 2 * w / 3) {
      return Direction.down;
    } else if (event.position.dx < w / 2) {
      return Direction.left;
    } else {
      return Direction.right;
    }
  }

  void _startRepeatTicker(PointerEvent event) async {
    if (widget.onTouchEvent == null) {
      return;
    }

    await Future.delayed(const Duration(milliseconds: 200));
    while (true) {
      await Future.delayed(const Duration(milliseconds: 50));
      if (!mounted) {
        return;
      }
      final touchArrowEvent = controller._touching[event.pointer];
      if (touchArrowEvent == null) {
        return;
      }

      if (touchArrowEvent is! _DirectionlessEvent &&
          widget.onTouchEvent != null) {
        widget.onTouchEvent!(TouchArrowEvent._(
          TouchArrowEventType.repeat,
          touchArrowEvent.touchTime,
          touchArrowEvent.direction,
        ));
      }
    }
  }
}

class TouchArrowsController {
  final Map<int, TouchArrowEvent> _touching = {};

  Duration? getLastDirectionTouchTime(Direction direction) {
    Duration? last;
    for (final event in _touching.values) {
      if (event is! _DirectionlessEvent &&
          event.direction == direction &&
          (last == null || last < event.touchTime)) {
        last = event.touchTime;
      }
    }
    return last;
  }
}
