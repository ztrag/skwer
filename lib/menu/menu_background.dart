import 'package:flutter/widgets.dart';
import 'package:skwer/colors.dart';

class MenuBackground extends StatelessWidget {
  const MenuBackground({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          radius: 0.5,
          stops: const [0.3, 0.6, 1],
          colors: [
            Color.lerp(
              Color.lerp(skRed, skBlue, 0.2)!,
              skBlack,
              0.5,
            )!,
            Color.lerp(
              Color.lerp(skRed, skBlue, 0.5)!,
              skBlack,
              0.6,
            )!,
            Color.lerp(skRed, skBlack, 0.85)!,
          ],
        ),
      ),
    );
  }
}
