import 'dart:math' as math;
import 'dart:typed_data';

/// Dynamic Time Warping distance between two MFCC sequences: the frames are lined
/// up so slow or fast speech still matches. Frame cost = Euclidean distance; the
/// total is divided by (a.length + b.length) so long and short clips compare.
/// 0 = the same sound; larger = less alike. Empty input gives infinity.
double dtwDistance(List<Float64List> a, List<Float64List> b) {
  if (a.isEmpty || b.isEmpty) return double.infinity;
  final m = b.length;
  var previous = Float64List(m + 1)..fillRange(1, m + 1, double.infinity);
  var current = Float64List(m + 1);
  for (var i = 1; i <= a.length; i++) {
    current[0] = double.infinity;
    final row = a[i - 1];
    for (var j = 1; j <= m; j++) {
      final other = b[j - 1];
      var sum = 0.0;
      for (var k = 0; k < row.length; k++) {
        final d = row[k] - other[k];
        sum += d * d;
      }
      final best = math.min(previous[j - 1], math.min(previous[j], current[j - 1]));
      current[j] = math.sqrt(sum) + best;
    }
    final t = previous;
    previous = current;
    current = t;
  }
  return previous[m] / (a.length + m);
}
