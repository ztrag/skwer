class SkwerTileIndex {
  final int x;
  final int y;

  const SkwerTileIndex(this.x, this.y);

  SkwerTileIndex translate(int x, int y) =>
      SkwerTileIndex(this.x + x, this.y + y);

  @override
  int get hashCode => x * 1000 + y;

  @override
  bool operator ==(Object other) {
    if (other is! SkwerTileIndex) {
      return false;
    }
    return other.x == x && other.y == y;
  }
}
