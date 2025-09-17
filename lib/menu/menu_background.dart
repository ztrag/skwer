import 'package:flutter/widgets.dart';
import 'package:skwer/colors.dart';

class MenuBackground extends StatelessWidget {
  final double radius;
  final Color color;

  const MenuBackground({
    Key? key,
    this.radius = 0.5,
    this.color = skRed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          radius: radius,
          stops: const [0.3, 0.6, 1],
          colors: [
            Color.lerp(
              Color.lerp(color, skBlue, 0.2)!,
              skBlack,
              0.5,
            )!,
            Color.lerp(
              Color.lerp(color, skBlue, 0.5)!,
              skBlack,
              0.6,
            )!,
            Color.lerp(color, skBlack, 0.85)!,
          ],
        ),
      ),
    );
  }
}
