import 'package:flutter/widgets.dart';
import 'package:skwer/games.dart';
import 'package:skwer/menu/menu_widget.dart';

class MenuWrapper extends StatefulWidget {
  const MenuWrapper({Key? key}) : super(key: key);

  @override
  State<MenuWrapper> createState() => _MenuWrapperState();
}

class _MenuWrapperState extends State<MenuWrapper> {
  final ValueNotifier<Games?> selection = ValueNotifier(null);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      child: ValueListenableBuilder(
        valueListenable: selection,
        builder: (_, __, ___) => PopScope(
          canPop: selection.value == null,
          onPopInvokedWithResult: (_, __) {
            selection.value = null;
          },
          child: selection.value?.widget(() => selection.value = null) ??
              MenuWidget(menuSelection: selection),
        ),
      ),
    );
  }
}
