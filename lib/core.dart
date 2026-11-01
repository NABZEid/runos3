import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ===================== WARNA & TEMA =====================
class C {
  static const bg = Color(0xFF040A1C);
  static const card = Color(0xFF0D1836);
  static const card2 = Color(0xFF16254F);
  static const blue = Color(0xFF0A6CFF);
  static const cyan = Color(0xFF22E3FF);
  static const flame = Color(0xFFFF8A1F);
  static const good = Color(0xFF2EE59D);
  static const warn = Color(0xFFFFC53D);
  static const bad = Color(0xFFFF5470);
  static const sub = Color(0xFF8FA3D1);
  static const grad = LinearGradient(
      colors: [blue, cyan], begin: Alignment.topLeft, end: Alignment.bottomRight);
}

Color al(Color c, double o) => c.withAlpha((o.clamp(0.0, 1.0) * 255).round());

ThemeData buildTheme() {
  const t = PageTransitionsTheme(builders: {
    TargetPlatform.android: CupertinoPageTransitionsBuilder(),
    TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
    TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
    TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
  });
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: C.bg,
    pageTransitionsTheme: t,
    colorScheme: ColorScheme.fromSeed(
        seedColor: C.blue, brightness: Brightness.dark, primary: C.blue, secondary: C.cyan),
    sliderTheme: SliderThemeData(
      activeTrackColor: C.cyan,
      inactiveTrackColor: al(Colors.white, .1),
      thumbColor: Colors.white,
      overlayColor: al(C.cyan, .2),
      trackHeight: 6,
    ),
  );
}

Route<T> fadeRoute<T>(Widget w) => PageRouteBuilder<T>(
      pageBuilder: (_, __, ___) => w,
      transitionDuration: const Duration(milliseconds: 450),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (_, a, __, c) => FadeTransition(
        opacity: a,
        child: SlideTransition(
          position: Tween(begin: const Offset(0, .05), end: Offset.zero)
              .animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
          child: c,
        ),
      ),
    );

// ===================== FORMAT =====================
String two(int n) => n.toString().padLeft(2, '0');

String fmtDur(int s) {
  final h = s ~/ 3600, m = (s % 3600) ~/ 60, x = s % 60;
  return h > 0 ? '$h:${two(m)}:${two(x)}' : '${two(m)}:${two(x)}';
}

String fmtPace(double secPerKm) {
  if (secPerKm.isNaN || secPerKm.isInfinite || secPerKm <= 0 || secPerKm > 5999) {
    return "--'--\"";
  }
  var m = secPerKm ~/ 60;
  var s = (secPerKm % 60).round();
  if (s == 60) {
    m++;
    s = 0;
  }
  return "$m'${two(s)}\"";
}

String fmtKm(double meters) => (meters / 1000).toStringAsFixed(2);

const _bulan = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
const _hari = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
String fmtDate(DateTime d) => '${d.day} ${_bulan[d.month - 1]} ${d.year}';
String fmtDay(DateTime d) => _hari[d.weekday - 1];
String fmtTime(DateTime d) => '${two(d.hour)}:${two(d.minute)}';
DateTime dayOf(DateTime t) => DateTime(t.year, t.month, t.day);

// ===================== PERHITUNGAN =====================
class Calc {
  /// kalori bersih lari ~ 1.036 kcal per kg per km
  static double kcal(double kg, double distM) => kg * distM / 1000 * 1.036;

  /// laju keringat (ml/jam) naik seiring kecepatan
  static double sweatRate(double kmh) => (350 + kmh * 45).clamp(400.0, 1500.0);

  static double sweat(int sec, double distM) {
    if (sec <= 0) return 0;
    final kmh = distM / sec * 3.6;
    return sweatRate(kmh) * sec / 3600;
  }
}

// ===================== MODEL =====================
class RunRecord {
  final String id;
  final int start; // ms
  final int dur; // detik
  final double dist; // meter
  final double kcal;
  final double sweat; // ml
  final double water; // ml
  final List<List<double>> route;
  final List<int> splits;
  final String tType; // free / distance / time
  final double tVal;

  RunRecord({
    required this.id,
    required this.start,
    required this.dur,
    required this.dist,
    required this.kcal,
    required this.sweat,
    required this.water,
    required this.route,
    required this.splits,
    required this.tType,
    required this.tVal,
  });

  double get pace => dist > 10 ? dur / (dist / 1000) : 0;
  double get kmh => dur > 0 ? dist / dur * 3.6 : 0;
  DateTime get date => DateTime.fromMillisecondsSinceEpoch(start);
  bool get targetHit =>
      (tType == 'distance' && dist >= tVal * 1000) || (tType == 'time' && dur >= tVal * 60);

  Map<String, dynamic> toJson() => {
        'id': id, 'start': start, 'dur': dur, 'dist': dist, 'kcal': kcal,
        'sweat': sweat, 'water': water, 'route': route, 'splits': splits,
        'tType': tType, 'tVal': tVal,
      };

  factory RunRecord.fromJson(Map<String, dynamic> j) => RunRecord(
        id: j['id'] as String,
        start: j['start'] as int,
        dur: j['dur'] as int,
        dist: (j['dist'] as num).toDouble(),
        kcal: (j['kcal'] as num).toDouble(),
        sweat: (j['sweat'] as num).toDouble(),
        water: (j['water'] as num).toDouble(),
        route: (j['route'] as List)
            .map((e) => (e as List).map((x) => (x as num).toDouble()).toList())
            .toList(),
        splits: (j['splits'] as List).map((e) => e as int).toList(),
        tType: j['tType'] as String,
        tVal: (j['tVal'] as num).toDouble(),
      );
}

// ===================== PENYIMPANAN =====================
class Store extends ChangeNotifier {
  Store._();
  static final Store i = Store._();

  late SharedPreferences _p;
  List<RunRecord> runs = [];
  double weight = 65;
  double goalKm = 5;
  String name = 'Runner';

  Future<void> load() async {
    _p = await SharedPreferences.getInstance();
    weight = _p.getDouble('weight') ?? 65;
    goalKm = _p.getDouble('goalKm') ?? 5;
    name = _p.getString('name') ?? 'Runner';
    final raw = _p.getString('runs');
    if (raw != null) {
      try {
        runs = (jsonDecode(raw) as List)
            .map((e) => RunRecord.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {
        runs = [];
      }
    }
  }

  Future<void> _saveRuns() => _p.setString('runs', jsonEncode(runs.map((e) => e.toJson()).toList()));

  Future<void> add(RunRecord r) async {
    runs.insert(0, r);
    notifyListeners();
    await _saveRuns();
  }

  Future<void> remove(String id) async {
    runs.removeWhere((r) => r.id == id);
    notifyListeners();
    await _saveRuns();
  }

  Future<void> setProfile({String? n, double? w, double? g}) async {
    if (n != null) name = n;
    if (w != null) weight = w;
    if (g != null) goalKm = g;
    notifyListeners();
    await _p.setString('name', name);
    await _p.setDouble('weight', weight);
    await _p.setDouble('goalKm', goalKm);
  }

  // ---- statistik ----
  Set<DateTime> get days => runs.map((r) => dayOf(r.date)).toSet();
  bool get ranToday => days.contains(dayOf(DateTime.now()));

  int get streak {
    final d = days;
    final t = dayOf(DateTime.now());
    var cur = d.contains(t) ? t : DateTime(t.year, t.month, t.day - 1);
    var n = 0;
    while (d.contains(cur)) {
      n++;
      cur = DateTime(cur.year, cur.month, cur.day - 1);
    }
    return n;
  }

  int get bestStreak {
    final l = days.toList()..sort();
    var best = 0, cur = 0;
    DateTime? prev;
    for (final d in l) {
      if (prev != null && DateTime(prev.year, prev.month, prev.day + 1) == d) {
        cur++;
      } else {
        cur = 1;
      }
      if (cur > best) best = cur;
      prev = d;
    }
    return best;
  }

  double distOn(DateTime day) => runs
      .where((r) => dayOf(r.date) == dayOf(day))
      .fold(0.0, (a, r) => a + r.dist);

  DateTime get monday {
    final t = dayOf(DateTime.now());
    return DateTime(t.year, t.month, t.day - (t.weekday - 1));
  }

  List<double> get weekKm => List.generate(7, (i) {
        final m = monday;
        return distOn(DateTime(m.year, m.month, m.day + i)) / 1000;
      });

  double get totalKm => runs.fold(0.0, (a, r) => a + r.dist) / 1000;
  int get totalSec => runs.fold(0, (a, r) => a + r.dur);
  double get totalKcal => runs.fold(0.0, (a, r) => a + r.kcal);
}
