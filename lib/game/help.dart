import 'package:flutter/material.dart';
import 'package:skwer/colors.dart';
import 'package:skwer/platform.dart';

class Help extends StatelessWidget {
  const Help({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: skBlack.withOpacity(0.9),
        gradient: SweepGradient(
          colors: [
            skRed,
            skBlue,
            Color.lerp(skBlue, skRed, 0.5)!,
            skRed,
          ].map((e) => Color.lerp(e, skBlack, 0.5)!).toList(),
        ),
        border: Border.all(
          color: Color.lerp(skRed, skBlue, 0.5)!,
        ),
        borderRadius: const BorderRadius.only(topRight: Radius.circular(8)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: skBlack.withOpacity(0.75),
          gradient: RadialGradient(
            colors: [
              Color.lerp(Color.lerp(skRed, skBlue, 0.5)!, skBlack, 0.5)!,
              Colors.transparent,
            ],
          ),
          border: Border.all(
            color: Color.lerp(skRed, skBlue, 0.5)!,
          ),
          borderRadius: const BorderRadius.only(topRight: Radius.circular(8)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...const [
                Text(
                  'help',
                  style: TextStyle(fontSize: 40, color: skRed),
                ),
                Text(
                  'return to base state',
                  style: TextStyle(fontSize: 24),
                ),
                Text(''),
                Text('red -> surrounding'),
                Text('green -> cross'),
                Text('blue -> diagonals'),
              ],
              ..._keyboardHelp(),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _keyboardHelp() {
    if (Platform.isMobile) {
      return [];
    }
    return const [
      Text(''),
      Text('[arrows] ------> move', style: TextStyle(color: Colors.grey)),
      Text('[space/enter] -> press', style: TextStyle(color: Colors.grey)),
      Text('[tab] ---------> toggle', style: TextStyle(color: Colors.grey)),
      Text('[1-9] ---------> puzzle', style: TextStyle(color: Colors.grey)),
      Text('[r]  ----------> reset', style: TextStyle(color: Colors.grey)),
      Text('[h] -----------> help', style: TextStyle(color: Colors.grey)),
      Text('[escape] ------> cancel', style: TextStyle(color: Colors.grey)),
    ];
  }
}
