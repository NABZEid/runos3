import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'core.dart';

enum Phase { idle, running, paused, done }
enum TargetType { free, distance, time }

class RunTracker extends ChangeNotifier {
  RunTracker({
    required this.type,
    required this.targetValue,
    required this.simulate,
    required this.weightKg,
  });

  final TargetType type;
  final double targetValue; // km atau menit
  final bool simulate;
  final double weightKg;

  Phase phase = Phase.idle;
  int elapsed = 0;
  double dist = 0; // meter
  double water = 0; // ml diminum
  double curPace = 0; // detik / km
  final List<List<double>> route = [];
  final List<int> splits = [];
  bool targetHit = false;
  String? error;
  String? toast;

  final int startMs = DateTime.now().millisecondsSinceEpoch;
  int _lastSplitT = 0;
  Timer? _timer, _toastTimer;
  StreamSubscription<Position>? _sub;
  final List<List<double>> _samples = [];
  Position? _last;
  bool _disposed = false;
  bool _w1 = false, _w2 = false;
  int _lastRemind = 0;

  // simulasi
  double _lat = -6.2000, _lon = 106.8166, _head = 0.6;
  final _rnd = math.Random();

  // ---------- getter ----------
  double get kcal => Calc.kcal(weightKg, dist);
  double get sweat => Calc.sweat(elapsed, dist);
  double get netLoss => math.max(0, sweat - water);
  double get lossPct => netLoss / (weightKg * 1000) * 100;
  double get avgPace => dist > 10 ? elapsed / (dist / 1000) : 0;

  double get progress {
    switch (type) {
      case TargetType.distance:
        return dist / (targetValue * 1000);
      case TargetType.time:
        return elapsed / (targetValue * 60);
      case TargetType.free:
        return (dist % 1000) / 1000;
    }
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  void _toast(String s) {
    toast = s;
    notifyListeners();
    _toastTimer?.cancel();
    _toastTimer = Timer(const Duration(seconds: 3), () {
      toast = null;
      notifyListeners();
    });
  }

  // ---------- kontrol ----------
  Future<bool> start() async {
    if (!simulate) {
      if (!await _ensurePermission()) {
        notifyListeners();
        return false;
      }
      _sub = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
          distanceFilter: 3,
        ),
      ).listen(_onPos, onError: (_) {
        error = 'Sinyal GPS bermasalah';
        notifyListeners();
      });
    } else {
      route.add([_lat, _lon]);
    }
    phase = Phase.running;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    notifyListeners();
    return true;
  }

  Future<bool> _ensurePermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      error = 'GPS belum aktif. Nyalakan lokasi dulu.';
      return false;
    }
    var p = await Geolocator.checkPermission();
    if (p == LocationPermission.denied) p = await Geolocator.requestPermission();
    if (p == LocationPermission.denied || p == LocationPermission.deniedForever) {
      error = 'Izin lokasi ditolak. Aktifkan di pengaturan HP.';
      return false;
    }
    return true;
  }

  void pause() {
    if (phase != Phase.running) return;
    phase = Phase.paused;
    _last = null;
    HapticFeedback.lightImpact();
    notifyListeners();
  }

  void resume() {
    if (phase != Phase.paused) return;
    phase = Phase.running;
    HapticFeedback.lightImpact();
    notifyListeners();
  }

  void drink(double ml) {
    water += ml;
    HapticFeedback.selectionClick();
    _toast('+${ml.toInt()} ml air dicatat');
  }

  RunRecord finish() {
    phase = Phase.done;
    _timer?.cancel();
    _sub?.cancel();
    return RunRecord(
      id: startMs.toString(),
      start: startMs,
      dur: elapsed,
      dist: dist,
      kcal: kcal,
      sweat: sweat,
      water: water,
      route: List.of(route),
      splits: List.of(splits),
      tType: type.name,
      tVal: targetValue,
    );
  }

  // ---------- data ----------
  void _onPos(Position p) {
    if (phase != Phase.running) {
      _last = null;
      return;
    }
    if (p.accuracy > 35) return;
    final l = _last;
    if (l == null) {
      route.add([p.latitude, p.longitude]);
      _last = p;
      return;
    }
    final d = Geolocator.distanceBetween(l.latitude, l.longitude, p.latitude, p.longitude);
    final dt = p.timestamp.difference(l.timestamp).inMilliseconds / 1000;
    if (d < 2) return;
    if (dt > 0 && d / dt > 12) return; // loncatan GPS
    dist += d;
    route.add([p.latitude, p.longitude]);
    _last = p;
    _checkSplit();
  }

  void _tick() {
    if (phase != Phase.running) return;
    elapsed++;
    if (simulate) _simStep();

    _samples.add([elapsed.toDouble(), dist]);
    while (_samples.length > 1 && elapsed - _samples.first[0] > 20) {
      _samples.removeAt(0);
    }
    final f = _samples.first;
    final dd = dist - f[1], dt = elapsed - f[0];
    if (dd > 8 && dt >= 5) {
      curPace = dt / dd * 1000;
    } else if (dt >= 10) {
      curPace = 0;
    }

    if (!targetHit && type != TargetType.free && progress >= 1) {
      targetHit = true;
      HapticFeedback.heavyImpact();
      _toast('Target tercapai! Keren banget!');
    }

    final pct = lossPct;
    if (!_w2 && pct >= 2) {
      _w2 = true;
      HapticFeedback.vibrate();
      _toast('Dehidrasi! Segera minum air.');
    } else if (!_w1 && pct >= 1) {
      _w1 = true;
      _toast('Mulai kehilangan cairan, minum air ya.');
    } else if (elapsed - _lastRemind >= 900 && water < sweat * 0.5 && elapsed > 600) {
      _lastRemind = elapsed;
      _toast('Waktunya minum sedikit air.');
    }
    notifyListeners();
  }

  void _simStep() {
    final v = 2.9 + math.sin(elapsed / 25) * 0.5 + _rnd.nextDouble() * 0.2;
    _head += (_rnd.nextDouble() - 0.5) * 0.25 + 0.012;
    _lat += v * math.cos(_head) / 111320;
    _lon += v * math.sin(_head) / (111320 * math.cos(_lat * math.pi / 180));
    dist += v;
    route.add([_lat, _lon]);
    _checkSplit();
  }

  void _checkSplit() {
    while (dist >= (splits.length + 1) * 1000) {
      final t = elapsed - _lastSplitT;
      splits.add(t);
      _lastSplitT = elapsed;
      HapticFeedback.mediumImpact();
      _toast('KM ${splits.length} selesai  ${fmtPace(t.toDouble())}/km');
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    _toastTimer?.cancel();
    _sub?.cancel();
    super.dispose();
  }
}
