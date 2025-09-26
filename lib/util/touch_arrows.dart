import 'package:flutter/material.dart';

const double kVLimit1 = 0.8;
const double kVLimit2 = 0.9;

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
  final Size size;
  final Widget child;

  const TouchArrows(
      {Key? key,
      required this.child,
      required this.size,
      this.onTouchEvent,
      this.controller})
      : super(key: key);

  @override
  State<TouchArrows> createState() => _TouchArrowsState();
}

class _TouchArrowsState extends State<TouchArrows> {
  late final TouchArrowsController controller =
      widget.controller ?? TouchArrowsController();

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _onPointerDown,
      onPointerMove: _onPointerMove,
      onPointerUp: _onPointerUp,
      onPointerCancel: _onPointerUp,
      child: widget.child,
    );
  }

  void _onPointerDown(PointerDownEvent down) {
    final direction = _directionFromTouch(down);
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

  void _onPointerMove(PointerMoveEvent move) {
    final direction = _directionFromTouch(move);
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

  Direction? _directionFromTouch(PointerEvent event) {
    final w = widget.size.width;
    final h = widget.size.height;

    if (event.localPosition.dy < h * kVLimit1) {
      if (event.localPosition.dx < w / 4) {
        return Direction.left;
      } else if (event.localPosition.dx > 3 * w / 4) {
        return Direction.right;
      }
      return Direction.up;
    } else if (event.localPosition.dy > h * kVLimit2 &&
        event.localPosition.dx > w / 3 &&
        event.localPosition.dx < 2 * w / 3) {
      return Direction.down;
    } else if (event.localPosition.dx < w / 2) {
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
