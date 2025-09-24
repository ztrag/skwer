import 'package:flutter/material.dart';

class PopupWindowCoordinator {
  static _PopupWindowState? _popup;

  static bool canPop() {
    return _popup == null || _popup!.widget.canPop;
  }

  static void pop() {
    _popup?.widget.onPop();
  }
}

class PopupWindow extends StatefulWidget {
  final Widget child;
  final bool canPop;
  final VoidCallback onPop;

  const PopupWindow({
    Key? key,
    required this.canPop,
    required this.onPop,
    required this.child,
  }) : super(key: key);

  @override
  State<PopupWindow> createState() => _PopupWindowState();
}

class _PopupWindowState extends State<PopupWindow> {
  @override
  void initState() {
    super.initState();
    PopupWindowCoordinator._popup = this;
  }

  @override
  void dispose() {
    PopupWindowCoordinator._popup = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
