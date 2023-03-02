import 'package:flutter/widgets.dart';
import 'package:skwer/game/game_widget.dart';
import 'package:skwer/menu/menu_widget.dart';

enum MenuSelection {
  skwer,
  frogger,
}

class MenuWrapper extends StatefulWidget {
  const MenuWrapper({Key? key}) : super(key: key);

  @override
  State<MenuWrapper> createState() => _MenuWrapperState();
}

class _MenuWrapperState extends State<MenuWrapper> {
  final ValueNotifier<MenuSelection?> selection = ValueNotifier(null);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: selection,
      builder: (_, __, ___) {
        switch (selection.value) {
          case null:
            return MenuWidget(menuSelection: selection);
          case MenuSelection.skwer:
            return const GameWidget();
          case MenuSelection.frogger:
            throw UnimplementedError();
        }
      },
    );
  }
}
