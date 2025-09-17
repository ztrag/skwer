import 'package:flutter/material.dart';
import 'package:skwer/colors.dart';
import 'package:skwer/platform.dart';

class Help extends StatelessWidget {
  const Help({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ...[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Return to base state.',
                          style: TextStyle(fontSize: 20),
                        ),
                        const Text(''),
                        const Text('Tile actions:'),
                        const Text(
                          '[red] -> surrounding',
                          style: TextStyle(color: skYellow),
                        ),
                        const Text(
                          '[green] -> cross',
                          style: TextStyle(color: skYellow),
                        ),
                        const Text(
                          '[blue] -> diagonals',
                          style: TextStyle(color: skYellow),
                        ),
                        ..._keyboardHelp(),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _keyboardHelp() {
    if (Platform.isMobile) {
      return [];
    }
    const textStyle = TextStyle(color: skYellow);
    return const [
      Text(''),
      Text('Keyboard actions:'),
      Text('[arrows] ------> move', style: textStyle),
      Text('[space/enter] -> press', style: textStyle),
      Text('[tab] ---------> toggle', style: textStyle),
      Text('[1-9] ---------> puzzle', style: textStyle),
      Text('[r]  ----------> reset', style: textStyle),
      Text('[backspace] ---> undo', style: textStyle),
      Text('[escape] ------> cancel', style: textStyle),
    ];
  }
}
