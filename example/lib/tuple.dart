/// Represents a 2-tuple or pair.
class Pair<T0, T1> {
  /// First item of the tuple
  T0? i0;

  /// Second item of the tuple
  T1? i1;

  /// Create a new tuple value with the specified items.
  Pair([this.i0, this.i1]);

  @override
  String toString() => '[$i0, $i1]';

  @override
  bool operator ==(Object other) =>
      other is Pair && other.i0 == i0 && other.i1 == i1;

  @override
  int get hashCode => hash(<int>[i0.hashCode, i1.hashCode]);
}

/// Represents a 3-tuple or pair.
class Triple<T0, T1, T2> {
  T0? i0;
  T1? i1;
  T2? i2;

  Triple([this.i0, this.i1, this.i2]);

  @override
  String toString() => '[$i0, $i1, $i2]';

  @override
  bool operator ==(Object other) =>
      other is Triple && other.i0 == i0 && other.i1 == i1 && other.i2 == i2;

  @override
  int get hashCode => hash(<int>[i0.hashCode, i1.hashCode, i2.hashCode]);
}

int hash(Iterable<int> values) {
  int hash = 0;

  /// combine
  for (int value in values) {
    hash = 0x1fffffff & (hash + value);
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    hash = hash ^ (hash >> 6);
  }

  /// finish
  hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
  hash = hash ^ (hash >> 11);
  return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
}
