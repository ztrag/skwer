import 'package:flutter/material.dart';
import 'package:skwer/skwer/game_widget.dart' as s;
import 'package:skwer/tetris/game_widget.dart' as t;

enum Games {
  skwer('skwer'),
  tetris('tetris'),
  frogger('frogger');

  final String name;

  const Games(this.name);

  Widget widget() {
    switch (this) {
      case Games.skwer:
        return const s.GameWidget();
      case Games.tetris:
        return const t.GameWidget();
      case Games.frogger:
        throw UnimplementedError();
    }
  }
}
