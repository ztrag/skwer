import 'dart:math';

import 'package:flutter/material.dart';
import 'package:skwer/colors.dart';
import 'package:skwer/game/game_props.dart';
import 'package:skwer/game/game_zone.dart';
import 'package:skwer/game/puzzle.dart';
import 'package:skwer/platform.dart';

class GameBackground extends StatelessWidget {
  final GameProps props;
  final Size size;
  final double tileSize;

  const GameBackground({
    Key? key,
    required this.props,
    required this.size,
    required this.tileSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: props.numTiles,
      builder: (_, numTiles, __) => ValueListenableBuilder(
        valueListenable: props.skwer,
        builder: (_, skwer, __) => ValueListenableBuilder<Puzzle?>(
          valueListenable: props.puzzle,
          builder: (_, puzzle, __) {
            final zone = GameZone(numTiles.x, numTiles.y);
            final zoneSize = min(
                  zone.size.x / size.width,
                  zone.size.y / size.height,
                ) *
                tileSize;
            const centerShade = [0.4, 0.3, 0.55];
            return Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  radius: 1 - zoneSize,
                  stops: [zoneSize * 0.6, zoneSize * 0.6 + 0.3, 1],
                  colors: [
                    Color.lerp(
                        Color.lerp(
                          skTileColors[(skwer + 0) % 3],
                          const Color.fromARGB(255, 5, 110, 230),
                          0.2,
                        )!,
                        skBlack,
                        centerShade[skwer % 3] *
                            (props.hasPuzzle ? 0.8 : 1.4))!,
                    Color.lerp(
                      Color.lerp(
                        const Color.fromARGB(255, 5, 110, 230),
                        skRed,
                        0.5,
                      )!,
                      skBlack,
                      0.7,
                    )!,
                    Color.lerp(
                      skTileColors[skwer % 3],
                      skBlack,
                      0.92,
                    )!,
                  ],
                ),
              ),
              child: puzzle == null || zone.size.x == 0 || zone.size.y == 0
                  ? Container()
                  : Center(
                      child: Container(
                        width: zone.size.x * tileSize + (tileSize * 0.04),
                        height: zone.size.y * tileSize + (tileSize * 0.04),
                        decoration: BoxDecoration(
                          color: skBlack,
                          border: Border.all(
                            width: Platform.isMobile ? 2 : 4,
                            strokeAlign: BorderSide.strokeAlignOutside,
                            color: Color.lerp(
                                skTileColors[skwer % 3], skBlack, 0.3)!,
                          ),
                        ),
                      ),
                    ),
            );
          },
        ),
      ),
    );
  }
}
