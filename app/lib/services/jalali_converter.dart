/// Exact Gregorian <-> Jalali (Persian) calendar conversion, fully
/// client-side (no backend round-trip needed). Implements the standard
/// "jalaali" algorithm (the same one used by the jalaali-js library),
/// verified against known reference dates:
/// - 1 Farvardin 1405 = March 21, 2026
/// - 1 Shahrivar 1405 = August 23, 2026
/// - 22 Bahman 1357 = February 11, 1979 (Iranian Revolution)
library jalali_converter;

class JalaliDate {
  final int year;
  final int month; // 1 to 12
  final int day;
  const JalaliDate(this.year, this.month, this.day);

  @override
  String toString() => '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
}

class _JalCalResult {
  final int leap;
  final int gy;
  final int march;
  const _JalCalResult(this.leap, this.gy, this.march);
}

class JalaliConverter {
  JalaliConverter._();

  static int _div(int a, int b) {
    final q = a / b;
    return q >= 0 ? q.toInt() : -(-q).toInt();
  }

  static int _mod(int a, int b) => a - b * _div(a, b);

  static const List<int> _breaks = [
    -61, 9, 38, 199, 426, 686, 756, 818, 1111, 1181, 1210,
    1635, 2060, 2097, 2192, 2262, 2324, 2394, 2456, 3178,
  ];

  static _JalCalResult _jalCal(int jy) {
    final bl = _breaks.length;
    final gy = jy + 621;
    var leapJ = -14;
    var jp = _breaks[0];
    var jump = 0;
    for (var i = 1; i < bl; i++) {
      final jm = _breaks[i];
      jump = jm - jp;
      if (jy < jm) break;
      leapJ = leapJ + _div(jump, 33) * 8 + _div(_mod(jump, 33), 4);
      jp = jm;
    }
    var n = jy - jp;
    leapJ = leapJ + _div(n, 33) * 8 + _div(_mod(n, 33) + 3, 4);
    if (_mod(jump, 33) == 4 && (jump - n) == 4) leapJ += 1;
    final leapG = _div(gy, 4) - _div((_div(gy, 100) + 1) * 3, 4) - 150;
    final march = 20 + leapJ - leapG;
    if (jump - n < 6) {
      n = n - jump + _div(jump + 4, 33) * 33;
    }
    var leap = _mod(_mod(n + 1, 33) - 1, 4);
    if (leap == -1) leap = 4;
    return _JalCalResult(leap, gy, march);
  }

  static int _g2d(int gy, int gm, int gd) {
    var d = _div((gy + _div(gm - 8, 6) + 100100) * 1461, 4) +
        _div(153 * _mod(gm + 9, 12) + 2, 5) +
        gd -
        34840408;
    d = d - _div(_div(gy + 100100 + _div(gm - 8, 6), 100) * 3, 4) + 752;
    return d;
  }

  static List<int> _d2g(int jdn) {
    var j = 4 * jdn + 139361631;
    j = j + _div(_div(4 * jdn + 183187720, 146097) * 3, 4) * 4 - 3908;
    final i = _div(_mod(j, 1461), 4) * 5 + 308;
    final gd = _div(_mod(i, 153), 5) + 1;
    final gm = _mod(_div(i, 153), 12) + 1;
    final gy = _div(j, 1461) - 100100 + _div(8 - gm, 6);
    return [gy, gm, gd];
  }

  static int _j2d(int jy, int jm, int jd) {
    final r = _jalCal(jy);
    return _g2d(r.gy, 3, r.march) + (jm - 1) * 31 - _div(jm, 7) * (jm - 7) + jd - 1;
  }

  /// Number of days in a given Jalali month (29, 30, or 31).
  static int monthLength(int jy, int jm) {
    if (jm <= 6) return 31;
    if (jm <= 11) return 30;
    return isLeapYear(jy) ? 30 : 29;
  }

  static bool isLeapYear(int jy) => _jalCal(jy).leap == 0;

  /// Converts a Gregorian date to Jalali.
  static JalaliDate toJalali(DateTime g) {
    final jdn = _g2d(g.year, g.month, g.day);
    final gy0 = _d2g(jdn)[0];
    var jy = gy0 - 621;
    var r = _jalCal(jy);
    final jdn1f = _g2d(r.gy, 3, r.march);
    var k = jdn - jdn1f;
    int jm, jd;
    if (k >= 0) {
      if (k <= 185) {
        jm = 1 + _div(k, 31);
        jd = _mod(k, 31) + 1;
        return JalaliDate(jy, jm, jd);
      } else {
        k -= 186;
      }
    } else {
      jy -= 1;
      k += 179;
      if (r.leap == 1) k += 1;
    }
    jm = 7 + _div(k, 30);
    jd = _mod(k, 30) + 1;
    return JalaliDate(jy, jm, jd);
  }

  /// Converts a Jalali date to Gregorian.
  static DateTime toGregorian(int jy, int jm, int jd) {
    final jdn = _j2d(jy, jm, jd);
    final g = _d2g(jdn);
    return DateTime(g[0], g[1], g[2]);
  }


  static (DateTime, DateTime) monthGregorianRange(int jy, int jm) {
    final start = toGregorian(jy, jm, 1);
    final end = toGregorian(jy, jm, monthLength(jy, jm));
    return (start, end);
  }
}
