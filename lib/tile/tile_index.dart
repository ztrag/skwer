class TileIndex {
  final int x;
  final int y;

  const TileIndex(this.x, this.y);

  TileIndex translate(int x, int y) => TileIndex(this.x + x, this.y + y);

  @override
  int get hashCode => x * 1000 + y;

  @override
  bool operator ==(Object other) {
    if (other is! TileIndex) {
      return false;
    }
    return other.x == x && other.y == y;
  }

  @override
  String toString() {
    return '[$x, $y]';
  }
}
