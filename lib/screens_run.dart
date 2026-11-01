import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'core.dart';
import 'tracker.dart';
import 'widgets.dart';

// ===================== ATUR TARGET =====================
class RunSetupScreen extends StatefulWidget {
  const RunSetupScreen({super.key});
  @override
  State<RunSetupScreen> createState() => _RunSetupScreenState();
}

class _RunSetupScreenState extends State<RunSetupScreen> {
  TargetType type = TargetType.free;
  double km = 5;
  double minutes = 30;
  bool sim = false;

  Widget _typeChip(TargetType t, IconData ic, String label) {
    final on = type == t;
    return Expanded(
      child: Pressable(
        onTap: () => setState(() => type = t),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient: on ? C.grad : null,
            color: on ? null : C.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: al(Colors.white, on ? 0 : .07)),
            boxShadow: on ? [BoxShadow(color: al(C.cyan, .3), blurRadius: 16)] : null,
          ),
          child: Column(children: [
            Icon(ic, size: 26, color: on ? Colors.white : C.sub),
            const SizedBox(height: 6),
            Text(label,
                style: TextStyle(
                    fontWeight: FontWeight.w800, color: on ? Colors.white : C.sub, fontSize: 13)),
          ]),
        ),
      ),
    );
  }

  Widget _pill(String label, bool on, VoidCallback tap) => Pressable(
        onTap: tap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          decoration: BoxDecoration(
            color: on ? al(C.cyan, .18) : al(Colors.white, .06),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: on ? C.cyan : Colors.transparent),
          ),
          child: Text(label,
              style: TextStyle(fontWeight: FontWeight.w700, color: on ? C.cyan : C.sub)),
        ),
      );

  Widget _body() {
    switch (type) {
      case TargetType.free:
        return const Glass(
          key: ValueKey('free'),
          child: Row(children: [
            Icon(Icons.all_inclusive_rounded, size: 36, color: C.cyan),
            SizedBox(width: 14),
            Expanded(
                child: Text('Lari bebas tanpa target. Jarak, pace, dan kalori tetap dihitung.',
                    style: TextStyle(color: C.sub, height: 1.4))),
          ]),
        );
      case TargetType.distance:
        return Glass(
          key: const ValueKey('dist'),
          child: Column(children: [
            Text(km.toStringAsFixed(1),
                style: const TextStyle(
                    fontSize: 72, fontWeight: FontWeight.w900, height: 1.1, fontFeatures: tabular)),
            const Text('kilometer', style: TextStyle(color: C.sub)),
            const SizedBox(height: 14),
            Wrap(spacing: 8, runSpacing: 8, alignment: WrapAlignment.center, children: [
              for (final v in [1.0, 3.0, 5.0, 10.0, 15.0, 21.0, 42.0])
                _pill('${v.toInt()} km', km == v, () => setState(() => km = v)),
            ]),
            Slider(value: km, min: 1, max: 42, divisions: 82, onChanged: (v) => setState(() => km = v)),
          ]),
        );
      case TargetType.time:
        return Glass(
          key: const ValueKey('time'),
          child: Column(children: [
            Text(minutes.toInt().toString(),
                style: const TextStyle(
                    fontSize: 72, fontWeight: FontWeight.w900, height: 1.1, fontFeatures: tabular)),
            const Text('menit', style: TextStyle(color: C.sub)),
            const SizedBox(height: 14),
            Wrap(spacing: 8, runSpacing: 8, alignment: WrapAlignment.center, children: [
              for (final v in [10.0, 20.0, 30.0, 45.0, 60.0, 90.0])
                _pill('${v.toInt()} mnt', minutes == v, () => setState(() => minutes = v)),
            ]),
            Slider(
                value: minutes,
                min: 5,
                max: 180,
                divisions: 35,
                onChanged: (v) => setState(() => minutes = v)),
          ]),
        );
    }
  }

  Widget _estimate() {
    // asumsi pace 6'30"/km untuk perkiraan
    final distM = type == TargetType.distance ? km * 1000 : minutes * 60 / 390 * 1000;
    final sec = type == TargetType.distance ? (km * 390).round() : (minutes * 60).round();
    return Glass(
      key: ValueKey('est$type'),
      child: Row(children: [
        _est(Icons.local_fire_department_rounded, C.flame,
            '${Calc.kcal(Store.i.weight, distM).round()}', 'kkal'),
        _est(Icons.water_drop_rounded, C.cyan, '${Calc.sweat(sec, distM).round()}', 'ml keringat'),
        type == TargetType.distance
            ? _est(Icons.schedule_rounded, C.good, fmtDur(sec), 'perkiraan waktu')
            : _est(Icons.straighten_rounded, C.good, (distM / 1000).toStringAsFixed(1), 'perkiraan km'),
      ]),
    );
  }

  Widget _est(IconData ic, Color c, String v, String l) => Expanded(
        child: Column(children: [
          Icon(ic, color: c),
          const SizedBox(height: 6),
          Text(v, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
          Text(l, style: const TextStyle(color: C.sub, fontSize: 11), textAlign: TextAlign.center),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
            child: Row(children: [
              IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded)),
              const Text('Atur Target',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
            ]),
          ),
          Expanded(
            child: ListView(padding: const EdgeInsets.fromLTRB(20, 14, 20, 20), children: [
              FadeIn(
                child: Row(children: [
                  _typeChip(TargetType.free, Icons.all_inclusive_rounded, 'Bebas'),
                  _typeChip(TargetType.distance, Icons.straighten_rounded, 'Jarak'),
                  _typeChip(TargetType.time, Icons.timer_rounded, 'Waktu'),
                ]),
              ),
              const SizedBox(height: 16),
              FadeIn(
                index: 1,
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOutCubic,
                  child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300), child: _body()),
                ),
              ),
              if (type != TargetType.free) ...[
                const SizedBox(height: 14),
                FadeIn(index: 2, child: _estimate()),
              ],
              const SizedBox(height: 14),
              FadeIn(
                index: 3,
                child: Glass(
                  child: Row(children: [
                    const Icon(Icons.science_rounded, color: C.warn),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Mode simulasi',
                            style: TextStyle(fontWeight: FontWeight.w800)),
                        Text('Tanpa GPS, untuk mencoba di emulator atau di dalam rumah.',
                            style: TextStyle(color: C.sub, fontSize: 12)),
                      ]),
                    ),
                    AniSwitch(value: sim, onChanged: (v) => setState(() => sim = v)),
                  ]),
                ),
              ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: GradButton(
              label: 'MULAI',
              icon: Icons.play_arrow_rounded,
              onTap: () => Navigator.push(
                context,
                fadeRoute(RunScreen(
                  type: type,
                  value: type == TargetType.distance ? km : minutes,
                  sim: sim,
                )),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

// ===================== LAYAR LARI =====================
class RunScreen extends StatefulWidget {
  const RunScreen({super.key, required this.type, required this.value, required this.sim});
  final TargetType type;
  final double value;
  final bool sim;
  @override
  State<RunScreen> createState() => _RunScreenState();
}

class _RunScreenState extends State<RunScreen> {
  late final RunTracker t = RunTracker(
    type: widget.type,
    targetValue: widget.value,
    simulate: widget.sim,
    weightKg: Store.i.weight,
  );
  String countText = '3';
  bool starting = true;
  bool finishing = false;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    _countdown();
  }

  Future<void> _countdown() async {
    for (final s in ['3', '2', '1', 'GO!']) {
      if (!mounted) return;
      setState(() => countText = s);
      HapticFeedback.selectionClick();
      await Future.delayed(Duration(milliseconds: s == 'GO!' ? 600 : 850));
    }
    if (!mounted) return;
    final ok = await t.start();
    if (!mounted) return;
    if (!ok) {
      _failDialog();
      return;
    }
    setState(() => starting = false);
  }

  void _failDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: C.card,
        title: const Text('GPS bermasalah'),
        content: Text(t.error ?? 'Tidak bisa memulai pelacakan.'),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              child: const Text('Kembali')),
          TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pushReplacement(
                    context, fadeRoute(RunScreen(type: widget.type, value: widget.value, sim: true)));
              },
              child: const Text('Pakai simulasi')),
        ],
      ),
    );
  }

  void _confirmExit() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: C.card,
        title: const Text('Hentikan lari?'),
        content: const Text('Data lari ini tidak akan disimpan.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Lanjut lari')),
          TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                finishing = true;
                t.finish();
                Navigator.pop(context);
              },
              child: const Text('Buang', style: TextStyle(color: C.bad))),
        ],
      ),
    );
  }

  void _finish() {
    if (finishing) return;
    finishing = true;
    HapticFeedback.heavyImpact();
    final r = t.finish();
    if (r.dur < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lari terlalu singkat, tidak disimpan.')));
      Navigator.pop(context);
      return;
    }
    Store.i.add(r);
    Navigator.pushReplacement(context, fadeRoute(SummaryScreen(record: r, fresh: true)));
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    t.dispose();
    super.dispose();
  }

  String get _targetLabel {
    switch (widget.type) {
      case TargetType.free:
        return 'Lari bebas';
      case TargetType.distance:
        return 'Target ${widget.value.toStringAsFixed(1)} km';
      case TargetType.time:
        return 'Target ${widget.value.toInt()} menit';
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !starting) _confirmExit();
      },
      child: Scaffold(
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 450),
          child: starting ? _countView() : _runView(),
        ),
      ),
    );
  }

  Widget _countView() => Container(
        key: const ValueKey('count'),
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
              center: Alignment(0, -.1), radius: 1, colors: [Color(0xFF0B3A9C), C.bg]),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text('BERSIAP', style: TextStyle(color: C.sub, letterSpacing: 6, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (c, a) => ScaleTransition(
              scale: Tween(begin: 1.8, end: 1.0).animate(CurvedAnimation(parent: a, curve: Curves.easeOutBack)),
              child: FadeTransition(opacity: a, child: c),
            ),
            child: Text(countText,
                key: ValueKey(countText),
                style: TextStyle(
                    fontSize: countText == 'GO!' ? 110 : 150,
                    fontWeight: FontWeight.w900,
                    color: countText == 'GO!' ? C.cyan : Colors.white)),
          ),
          const SizedBox(height: 10),
          Text(_targetLabel, style: const TextStyle(color: C.sub, fontSize: 16)),
        ]),
      );

  Widget _runView() {
    return ListenableBuilder(
      key: const ValueKey('run'),
      listenable: t,
      builder: (context, _) {
        final paused = t.phase == Phase.paused;
        final w = MediaQuery.of(context).size.width;
        final ringSize = math.min(w - 90, 290.0);
        final kmh = t.elapsed > 0 ? t.dist / t.elapsed * 3.6 : 0.0;
        String sub;
        switch (widget.type) {
          case TargetType.distance:
            sub = '${(t.progress * 100).clamp(0, 100).toInt()}% menuju ${widget.value.toStringAsFixed(1)} km';
            break;
          case TargetType.time:
            sub = 'Sisa ${fmtDur(math.max(0, (widget.value * 60).round() - t.elapsed))}';
            break;
          case TargetType.free:
            sub = 'Putaran KM ${t.splits.length + 1}';
        }
        return AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: paused
                  ? [const Color(0xFF3A1D05), C.bg]
                  : [const Color(0xFF0A2C75), C.bg],
            ),
          ),
          child: Stack(children: [
            SafeArea(
              child: Column(children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                  child: Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                          color: al(Colors.white, .08), borderRadius: BorderRadius.circular(20)),
                      child: Text(_targetLabel,
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                          color: al(widget.sim ? C.warn : C.good, .15),
                          borderRadius: BorderRadius.circular(20)),
                      child: Row(children: [
                        Icon(widget.sim ? Icons.science_rounded : Icons.gps_fixed_rounded,
                            size: 14, color: widget.sim ? C.warn : C.good),
                        const SizedBox(width: 5),
                        Text(widget.sim ? 'SIMULASI' : 'GPS',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: widget.sim ? C.warn : C.good)),
                      ]),
                    ),
                  ]),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
                    child: Column(children: [
                      AnimatedRing(
                        value: t.progress,
                        size: ringSize,
                        stroke: 16,
                        colors: paused
                            ? const [C.flame, C.warn, C.flame]
                            : const [C.blue, C.cyan, C.blue],
                        child: Column(mainAxisSize: MainAxisSize.min, children: [
                          Text(paused ? 'JEDA' : 'WAKTU',
                              style: TextStyle(
                                  color: paused ? C.flame : C.sub,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 3,
                                  fontSize: 12)),
                          Text(fmtDur(t.elapsed),
                              style: const TextStyle(
                                  fontSize: 56, fontWeight: FontWeight.w900, fontFeatures: tabular)),
                          Text(sub, style: const TextStyle(color: C.sub, fontSize: 13)),
                        ]),
                      ),
                      const SizedBox(height: 20),
                      Row(children: [
                        Expanded(
                            child: StatTile(
                                label: 'JARAK',
                                value: fmtKm(t.dist),
                                unit: 'km',
                                icon: Icons.straighten_rounded)),
                        const SizedBox(width: 10),
                        Expanded(
                            child: StatTile(
                                label: 'PACE',
                                value: fmtPace(t.curPace),
                                unit: '/km sekarang',
                                icon: Icons.speed_rounded)),
                        const SizedBox(width: 10),
                        Expanded(
                            child: StatTile(
                                label: 'KALORI',
                                value: '${t.kcal.round()}',
                                unit: 'kkal',
                                icon: Icons.local_fire_department_rounded,
                                color: C.flame)),
                      ]),
                      const SizedBox(height: 10),
                      Row(children: [
                        Expanded(
                            child: StatTile(
                                label: 'PACE RATA-RATA',
                                value: fmtPace(t.avgPace),
                                unit: '/km',
                                icon: Icons.timeline_rounded)),
                        const SizedBox(width: 10),
                        Expanded(
                            child: StatTile(
                                label: 'KECEPATAN',
                                value: kmh.toStringAsFixed(1),
                                unit: 'km/jam',
                                icon: Icons.bolt_rounded,
                                color: C.warn)),
                      ]),
                      const SizedBox(height: 14),
                      _hydration(),
                      const SizedBox(height: 14),
                      Glass(
                          padding: const EdgeInsets.all(10),
                          child: RouteView(points: t.route, height: 170)),
                    ]),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 6, 20, 14),
                  child: Column(children: [
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Pressable(
                        onTap: paused ? t.resume : t.pause,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 82,
                          height: 82,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                                colors: paused ? [C.flame, C.warn] : [C.blue, C.cyan]),
                            boxShadow: [
                              BoxShadow(
                                  color: al(paused ? C.flame : C.cyan, .45), blurRadius: 24)
                            ],
                          ),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: Icon(
                                paused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                                key: ValueKey(paused),
                                size: 44),
                          ),
                        ),
                      ),
                      const SizedBox(width: 28),
                      _HoldFinish(onDone: _finish),
                    ]),
                    const SizedBox(height: 8),
                    const Text('Tahan tombol merah untuk selesai',
                        style: TextStyle(color: C.sub, fontSize: 11)),
                  ]),
                ),
              ]),
            ),
            if (t.targetHit) const Positioned.fill(child: Confetti()),
            Positioned(
                top: MediaQuery.of(context).padding.top + 56,
                left: 0,
                right: 0,
                child: FloatToast(text: t.toast)),
          ]),
        );
      },
    );
  }

  Widget _hydration() {
    final pct = t.lossPct;
    final Color col;
    final String status;
    if (pct < .7) {
      col = C.good;
      status = 'Terhidrasi baik';
    } else if (pct < 1.5) {
      col = C.warn;
      status = 'Mulai kehilangan cairan';
    } else {
      col = C.bad;
      status = 'Risiko dehidrasi! Minum sekarang';
    }
    return Glass(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.water_drop_rounded, color: col),
          const SizedBox(width: 8),
          Expanded(
              child: Text(status, style: TextStyle(fontWeight: FontWeight.w800, color: col))),
          Text('-${pct.toStringAsFixed(1)}% berat',
              style: const TextStyle(color: C.sub, fontSize: 12)),
        ]),
        const SizedBox(height: 12),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: (pct / 2.5).clamp(0.0, 1.0)),
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeOutCubic,
          builder: (_, v, __) => ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
                value: v,
                minHeight: 9,
                backgroundColor: al(Colors.white, .08),
                valueColor: AlwaysStoppedAnimation(col)),
          ),
        ),
        const SizedBox(height: 10),
        Text(
            'Keringat ~${t.sweat.round()} ml  |  Diminum ${t.water.round()} ml  |  Defisit ${t.netLoss.round()} ml',
            style: const TextStyle(color: C.sub, fontSize: 12)),
        const SizedBox(height: 12),
        Row(children: [
          for (final ml in [100.0, 200.0, 300.0])
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Pressable(
                  onTap: () => t.drink(ml),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    decoration: BoxDecoration(
                        color: al(C.cyan, .14), borderRadius: BorderRadius.circular(14)),
                    alignment: Alignment.center,
                    child: Text('+${ml.toInt()} ml',
                        style: const TextStyle(fontWeight: FontWeight.w800, color: C.cyan)),
                  ),
                ),
              ),
            ),
        ]),
      ]),
    );
  }
}

class _HoldFinish extends StatefulWidget {
  const _HoldFinish({required this.onDone});
  final VoidCallback onDone;
  @override
  State<_HoldFinish> createState() => _HoldFinishState();
}

class _HoldFinishState extends State<_HoldFinish> with SingleTickerProviderStateMixin {
  late final AnimationController c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))
        ..addStatusListener((s) {
          if (s == AnimationStatus.completed) widget.onDone();
        });

  void _release() {
    if (c.status != AnimationStatus.completed) c.reverse();
  }

  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTapDown: (_) {
          HapticFeedback.selectionClick();
          c.forward();
        },
        onTapUp: (_) => _release(),
        onTapCancel: _release,
        child: AnimatedBuilder(
          animation: c,
          builder: (_, __) => Transform.scale(
            scale: 1 - .08 * c.value,
            child: SizedBox(
              width: 82,
              height: 82,
              child: Stack(alignment: Alignment.center, children: [
                Container(
                  width: 66,
                  height: 66,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: al(C.bad, .9),
                    boxShadow: [BoxShadow(color: al(C.bad, .4), blurRadius: 18)],
                  ),
                  child: const Icon(Icons.stop_rounded, size: 36),
                ),
                SizedBox(
                  width: 82,
                  height: 82,
                  child: CircularProgressIndicator(
                      value: c.value,
                      strokeWidth: 5,
                      color: Colors.white,
                      backgroundColor: Colors.transparent),
                ),
              ]),
            ),
          ),
        ),
      );
}

// ===================== RINGKASAN =====================
class SummaryScreen extends StatelessWidget {
  const SummaryScreen({super.key, required this.record, this.fresh = false});
  final RunRecord record;
  final bool fresh;

  @override
  Widget build(BuildContext context) {
    final r = record;
    final net = math.max(0.0, r.sweat - r.water);
    final fastest = r.splits.isEmpty ? 1 : r.splits.reduce(math.min);
    return PopScope(
      canPop: !fresh,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.popUntil(context, (route) => route.isFirst);
      },
      child: Scaffold(
        body: Stack(children: [
          SafeArea(
            child: ListView(padding: const EdgeInsets.fromLTRB(20, 10, 20, 30), children: [
              Row(children: [
                if (!fresh)
                  IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded)),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(fresh ? 'Lari Selesai!' : 'Detail Lari',
                        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
                    Text('${fmtDay(r.date)}, ${fmtDate(r.date)}  |  ${fmtTime(r.date)}',
                        style: const TextStyle(color: C.sub, fontSize: 13)),
                  ]),
                ),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.elasticOut,
                  builder: (_, v, __) => Transform.scale(
                    scale: v,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(gradient: C.grad, shape: BoxShape.circle),
                      child: const Icon(Icons.check_rounded, size: 30),
                    ),
                  ),
                ),
              ]),
              const SizedBox(height: 18),
              FadeIn(
                child: Column(children: [
                  ShaderMask(
                    shaderCallback: (b) => C.grad.createShader(b),
                    child: CountUp(
                      value: r.dist / 1000,
                      fmt: (v) => v.toStringAsFixed(2),
                      style: const TextStyle(
                          fontSize: 84,
                          fontWeight: FontWeight.w900,
                          height: 1.05,
                          color: Colors.white,
                          fontFeatures: tabular),
                    ),
                  ),
                  const Text('kilometer', style: TextStyle(color: C.sub)),
                  if (r.targetHit) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                          color: al(C.good, .15), borderRadius: BorderRadius.circular(20)),
                      child: const Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.flag_rounded, size: 16, color: C.good),
                        SizedBox(width: 6),
                        Text('Target tercapai',
                            style: TextStyle(color: C.good, fontWeight: FontWeight.w800)),
                      ]),
                    ),
                  ],
                ]),
              ),
              const SizedBox(height: 18),
              FadeIn(
                index: 1,
                child: Glass(
                    padding: const EdgeInsets.all(10),
                    child: RouteView(points: r.route, height: 230, animate: true)),
              ),
              const SizedBox(height: 14),
              FadeIn(
                index: 2,
                child: Column(children: [
                  Row(children: [
                    Expanded(
                        child: StatTile(
                            label: 'WAKTU',
                            value: fmtDur(r.dur),
                            unit: 'durasi',
                            icon: Icons.timer_outlined)),
                    const SizedBox(width: 10),
                    Expanded(
                        child: StatTile(
                            label: 'PACE RATA-RATA',
                            value: fmtPace(r.pace),
                            unit: '/km',
                            icon: Icons.speed_rounded)),
                  ]),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(
                        child: StatTile(
                            label: 'KALORI',
                            value: '${r.kcal.round()}',
                            unit: 'kkal terbakar',
                            icon: Icons.local_fire_department_rounded,
                            color: C.flame)),
                    const SizedBox(width: 10),
                    Expanded(
                        child: StatTile(
                            label: 'KECEPATAN',
                            value: r.kmh.toStringAsFixed(1),
                            unit: 'km/jam',
                            icon: Icons.bolt_rounded,
                            color: C.warn)),
                  ]),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(
                        child: StatTile(
                            label: 'KERINGAT (EST.)',
                            value: '${r.sweat.round()}',
                            unit: 'ml cairan hilang',
                            icon: Icons.water_drop_outlined)),
                    const SizedBox(width: 10),
                    Expanded(
                        child: StatTile(
                            label: 'AIR DIMINUM',
                            value: '${r.water.round()}',
                            unit: 'ml',
                            icon: Icons.water_drop_rounded,
                            color: C.good)),
                  ]),
                ]),
              ),
              const SizedBox(height: 14),
              FadeIn(
                index: 3,
                child: Glass(
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Icon(Icons.water_drop_rounded, color: net > 50 ? C.warn : C.good),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('Pemulihan cairan',
                            style: TextStyle(fontWeight: FontWeight.w800)),
                        const SizedBox(height: 4),
                        Text(
                            net > 50
                                ? 'Kamu kehilangan sekitar ${net.round()} ml cairan. Minum ~${(net * 1.5).round()} ml air dalam 2 jam ke depan.${r.dur > 3600 ? ' Tambahkan elektrolit karena lari lebih dari 1 jam.' : ''}'
                                : 'Cairan tubuhmu seimbang. Pertahankan!',
                            style: const TextStyle(color: C.sub, height: 1.4, fontSize: 13)),
                      ]),
                    ),
                  ]),
                ),
              ),
              if (r.splits.isNotEmpty) ...[
                const SizedBox(height: 14),
                FadeIn(
                  index: 4,
                  child: Glass(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Split per kilometer',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                      const SizedBox(height: 12),
                      for (var i = 0; i < r.splits.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 9),
                          child: Row(children: [
                            SizedBox(
                                width: 44,
                                child: Text('KM ${i + 1}',
                                    style: const TextStyle(color: C.sub, fontSize: 12))),
                            Expanded(
                              child: TweenAnimationBuilder<double>(
                                tween: Tween(
                                    begin: 0,
                                    end: (fastest / r.splits[i]).clamp(0.35, 1.0)),
                                duration: Duration(milliseconds: 600 + i * 120),
                                curve: Curves.easeOutCubic,
                                builder: (_, v, __) => Align(
                                  alignment: Alignment.centerLeft,
                                  child: FractionallySizedBox(
                                    widthFactor: v,
                                    child: Container(
                                      height: 12,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        gradient: LinearGradient(
                                            colors: r.splits[i] == fastest
                                                ? [C.good, C.cyan]
                                                : [C.blue, C.cyan]),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(fmtPace(r.splits[i].toDouble()),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w800, fontFeatures: tabular)),
                          ]),
                        ),
                    ]),
                  ),
                ),
              ],
              if (fresh) ...[
                const SizedBox(height: 14),
                FadeIn(
                  index: 5,
                  child: Glass(
                    color: al(C.flame, .12),
                    child: Row(children: [
                      const Flame(size: 50),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text('Streak kamu sekarang ${Store.i.streak} hari. Lanjutkan besok!',
                            style: const TextStyle(fontWeight: FontWeight.w800)),
                      ),
                    ]),
                  ),
                ),
              ],
              const SizedBox(height: 22),
              GradButton(
                label: fresh ? 'SELESAI' : 'KEMBALI',
                icon: Icons.check_rounded,
                onTap: () => Navigator.popUntil(context, (route) => route.isFirst),
              ),
            ]),
          ),
          if (fresh && r.targetHit) const Positioned.fill(child: Confetti()),
        ]),
      ),
    );
  }
}
