import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'core.dart';
import 'widgets.dart';
import 'screens_run.dart';
import 'screens_other.dart';

// ===================== SPLASH =====================
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late final intro =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..forward();
  late final loop =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))..repeat();

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 3000), () {
      if (mounted) Navigator.pushReplacement(context, fadeRoute(const Shell()));
    });
  }

  @override
  void dispose() {
    intro.dispose();
    loop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
              center: Alignment(0, -.2), radius: 1.1, colors: [Color(0xFF0B2A6B), C.bg]),
        ),
        child: SafeArea(
          child: Column(children: [
            Expanded(
              child: Center(
                child: AnimatedBuilder(
                  animation: Listenable.merge([intro, loop]),
                  builder: (_, __) {
                    final s = Curves.elasticOut.transform(math.min(intro.value / .75, 1.0));
                    return Stack(alignment: Alignment.center, children: [
                      for (var k = 0; k < 3; k++)
                        Builder(builder: (_) {
                          final t = (loop.value + k / 3) % 1;
                          return Container(
                            width: 170 + t * 260,
                            height: 170 + t * 260,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: al(C.cyan, (1 - t) * .35), width: 2),
                            ),
                          );
                        }),
                      Opacity(
                        opacity: math.min(intro.value * 3, 1.0),
                        child: Transform.scale(
                          scale: .5 + .5 * s,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(44),
                              boxShadow: [BoxShadow(color: al(C.blue, .6), blurRadius: 50)],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(44),
                              child: Image.asset('assets/logo.png', width: 170, height: 170),
                            ),
                          ),
                        ),
                      ),
                    ]);
                  },
                ),
              ),
            ),
            FadeIn(
              index: 3,
              child: Column(children: [
                const Text('Lari lebih jauh. Hidup lebih sehat.',
                    style: TextStyle(color: C.sub, fontWeight: FontWeight.w600)),
                const SizedBox(height: 18),
                SizedBox(
                  width: 140,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: AnimatedBuilder(
                      animation: intro,
                      builder: (_, __) => LinearProgressIndicator(
                        value: intro.value,
                        minHeight: 4,
                        backgroundColor: al(Colors.white, .08),
                        valueColor: const AlwaysStoppedAnimation(C.cyan),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 26),
                Text('Logo & prompter: ChatGPT  |  Builder: Claude AI  |  Ide & setup: skyy',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: al(Colors.white, .35), fontSize: 11)),
                const SizedBox(height: 18),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

// ===================== SHELL + NAV =====================
class Shell extends StatefulWidget {
  const Shell({super.key});
  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int tab = 0;
  void _start() => Navigator.push(context, fadeRoute(const RunSetupScreen()));

  @override
  Widget build(BuildContext context) {
    final pages = [HomeScreen(onStart: _start), const HistoryScreen(), const ProfileScreen()];
    return Scaffold(
      extendBody: true,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: KeyedSubtree(key: ValueKey(tab), child: pages[tab]),
      ),
      bottomNavigationBar: _NavBar(tab: tab, onTab: (i) => setState(() => tab = i), onRun: _start),
    );
  }
}

class _NavBar extends StatelessWidget {
  const _NavBar({required this.tab, required this.onTab, required this.onRun});
  final int tab;
  final ValueChanged<int> onTab;
  final VoidCallback onRun;

  Widget _item(int i, IconData ic, String label) {
    final on = tab == i;
    return Expanded(
      child: Pressable(
        onTap: () => onTab(i),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            AnimatedScale(
                scale: on ? 1.18 : 1,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutBack,
                child: Icon(ic, color: on ? C.cyan : C.sub, size: 26)),
            const SizedBox(height: 3),
            Text(label,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: on ? FontWeight.w800 : FontWeight.w500,
                    color: on ? C.cyan : C.sub)),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: al(const Color(0xFF081331), .96),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border(top: BorderSide(color: al(Colors.white, .07))),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 70,
            child: Row(children: [
              _item(0, Icons.home_rounded, 'Beranda'),
              Expanded(
                child: Center(
                  child: Transform.translate(
                    offset: const Offset(0, -16),
                    child: Pressable(
                      onTap: onRun,
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          gradient: C.grad,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: al(C.cyan, .45), blurRadius: 22)],
                        ),
                        child: const Icon(Icons.directions_run_rounded, size: 34),
                      ),
                    ),
                  ),
                ),
              ),
              _item(1, Icons.history_rounded, 'Riwayat'),
              _item(2, Icons.person_rounded, 'Profil'),
            ]),
          ),
        ),
      );
}

// ===================== BERANDA =====================
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onStart});
  final VoidCallback onStart;

  String _greet() {
    final h = DateTime.now().hour;
    if (h < 11) return 'Selamat pagi';
    if (h < 15) return 'Selamat siang';
    if (h < 18) return 'Selamat sore';
    return 'Selamat malam';
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Store.i,
      builder: (context, _) {
        final s = Store.i;
        final now = DateTime.now();
        final today = dayOf(now);
        final todayRuns = s.runs.where((r) => dayOf(r.date) == today).toList();
        final todayKm = s.distOn(now) / 1000;
        final todaySec = todayRuns.fold<int>(0, (a, r) => a + r.dur);
        final todayKcal = todayRuns.fold<double>(0, (a, r) => a + r.kcal);
        final week = s.weekKm;
        final weekTotal = week.fold<double>(0, (a, b) => a + b);

        return SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 120),
            children: [
              FadeIn(
                child: Row(children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.asset('assets/logo.png', width: 48, height: 48),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('${_greet()}, ${s.name}',
                          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
                      Text('${fmtDay(now)}, ${fmtDate(now)}',
                          style: const TextStyle(color: C.sub, fontSize: 13)),
                    ]),
                  ),
                ]),
              ),
              const SizedBox(height: 20),
              FadeIn(index: 1, child: _StreakCard(s: s)),
              const SizedBox(height: 14),
              FadeIn(
                index: 2,
                child: Glass(
                  child: Row(children: [
                    AnimatedRing(
                      value: todayKm / s.goalKm,
                      size: 124,
                      stroke: 13,
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Text(todayKm.toStringAsFixed(2),
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.w900, fontFeatures: tabular)),
                        Text('/ ${s.goalKm.toStringAsFixed(s.goalKm % 1 == 0 ? 0 : 1)} km',
                            style: const TextStyle(color: C.sub, fontSize: 12)),
                      ]),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('Target hari ini',
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                        const SizedBox(height: 4),
                        Text(
                            todayKm >= s.goalKm
                                ? 'Target harian tercapai!'
                                : 'Sisa ${(s.goalKm - todayKm).toStringAsFixed(2)} km lagi',
                            style: TextStyle(
                                color: todayKm >= s.goalKm ? C.good : C.sub, fontSize: 13)),
                        const SizedBox(height: 12),
                        Row(children: [
                          const Icon(Icons.timer_outlined, size: 16, color: C.cyan),
                          const SizedBox(width: 6),
                          Text(fmtDur(todaySec), style: const TextStyle(fontFeatures: tabular)),
                        ]),
                        const SizedBox(height: 6),
                        Row(children: [
                          const Icon(Icons.local_fire_department_rounded, size: 16, color: C.flame),
                          const SizedBox(width: 6),
                          Text('${todayKcal.round()} kkal'),
                        ]),
                      ]),
                    ),
                  ]),
                ),
              ),
              const SizedBox(height: 14),
              FadeIn(
                index: 3,
                child: Glass(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      const Expanded(
                          child: Text('Minggu ini',
                              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16))),
                      Text('${weekTotal.toStringAsFixed(2)} km',
                          style: const TextStyle(color: C.cyan, fontWeight: FontWeight.w800)),
                    ]),
                    const SizedBox(height: 16),
                    WeekBars(values: week, todayIndex: now.weekday - 1),
                  ]),
                ),
              ),
              if (s.runs.isNotEmpty) ...[
                const SizedBox(height: 14),
                FadeIn(
                  index: 4,
                  child: Glass(
                    onTap: () =>
                        Navigator.push(context, fadeRoute(SummaryScreen(record: s.runs.first))),
                    child: Row(children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                            gradient: C.grad, borderRadius: BorderRadius.circular(16)),
                        child: const Icon(Icons.directions_run_rounded),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Lari terakhir  ${fmtDate(s.runs.first.date)}',
                              style: const TextStyle(color: C.sub, fontSize: 12)),
                          const SizedBox(height: 3),
                          Text(
                              '${fmtKm(s.runs.first.dist)} km  |  ${fmtDur(s.runs.first.dur)}  |  ${fmtPace(s.runs.first.pace)}/km',
                              style: const TextStyle(fontWeight: FontWeight.w800)),
                        ]),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: C.sub),
                    ]),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              FadeIn(
                  index: 5,
                  child: GradButton(
                      label: 'MULAI LARI', icon: Icons.directions_run_rounded, onTap: onStart)),
            ],
          ),
        );
      },
    );
  }
}

class _StreakCard extends StatelessWidget {
  const _StreakCard({required this.s});
  final Store s;
  @override
  Widget build(BuildContext context) {
    final streak = s.streak;
    final today = dayOf(DateTime.now());
    final mon = s.monday;
    const hr = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
            colors: [al(C.flame, .22), C.card],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        border: Border.all(color: al(C.flame, .35)),
      ),
      child: Column(children: [
        Row(children: [
          Flame(size: 64, active: streak > 0),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                CountUp(
                    value: streak.toDouble(),
                    fmt: (v) => v.round().toString(),
                    style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w900, height: 1)),
                const SizedBox(width: 8),
                const Padding(
                    padding: EdgeInsets.only(bottom: 5),
                    child: Text('hari streak',
                        style: TextStyle(fontWeight: FontWeight.w700, color: C.flame))),
              ]),
              const SizedBox(height: 6),
              Text(
                  s.ranToday
                      ? 'Streak aman hari ini. Terbaik: ${s.bestStreak} hari'
                      : streak > 0
                          ? 'Lari hari ini biar streak lanjut!'
                          : 'Mulai lari hari ini, bangun streak-mu!',
                  style: const TextStyle(color: C.sub, fontSize: 12.5)),
            ]),
          ),
        ]),
        const SizedBox(height: 16),
        Row(
          children: List.generate(7, (i) {
            final d = DateTime(mon.year, mon.month, mon.day + i);
            final done = s.days.contains(d);
            final isToday = d == today;
            return Expanded(
              child: Column(children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: Duration(milliseconds: 500 + i * 110),
                  curve: Curves.easeOutBack,
                  builder: (_, v, __) => Transform.scale(
                    scale: v.clamp(0.0, 1.3),
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: done
                            ? const LinearGradient(colors: [Color(0xFFFF4D00), C.flame])
                            : null,
                        color: done ? null : al(Colors.white, .06),
                        border: isToday && !done ? Border.all(color: C.flame, width: 2) : null,
                      ),
                      child: done ? const Icon(Icons.check_rounded, size: 20) : null,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(hr[i],
                    style: TextStyle(
                        fontSize: 11,
                        color: isToday ? C.flame : C.sub,
                        fontWeight: isToday ? FontWeight.w900 : FontWeight.w500)),
              ]),
            );
          }),
        ),
      ]),
    );
  }
}
