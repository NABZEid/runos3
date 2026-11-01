import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'core.dart';

// ---------- animasi masuk berurutan ----------
class FadeIn extends StatelessWidget {
  const FadeIn({super.key, required this.child, this.index = 0});
  final Widget child;
  final int index;
  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: Duration(milliseconds: 400 + index * 90),
        curve: Curves.easeOutCubic,
        builder: (_, v, c) => Opacity(
          opacity: v,
          child: Transform.translate(offset: Offset(0, (1 - v) * 28), child: c),
        ),
        child: child,
      );
}

// ---------- tombol dengan efek tekan ----------
class Pressable extends StatefulWidget {
  const Pressable({super.key, required this.child, this.onTap});
  final Widget child;
  final VoidCallback? onTap;
  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool down = false;
  @override
  Widget build(BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => down = true),
        onTapUp: (_) => setState(() => down = false),
        onTapCancel: () => setState(() => down = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: down ? .94 : 1,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: widget.child,
        ),
      );
}

class GradButton extends StatelessWidget {
  const GradButton({super.key, required this.label, required this.icon, this.onTap, this.colors});
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final List<Color>? colors;
  @override
  Widget build(BuildContext context) {
    final cs = colors ?? [C.blue, C.cyan];
    return Pressable(
      onTap: onTap,
      child: Container(
        height: 62,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: cs),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [BoxShadow(color: al(cs.last, .35), blurRadius: 24, offset: const Offset(0, 8))],
        ),
        alignment: Alignment.center,
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 26, color: Colors.white),
          const SizedBox(width: 10),
          Text(label,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: .5)),
        ]),
      ),
    );
  }
}

class Glass extends StatelessWidget {
  const Glass({super.key, required this.child, this.padding = const EdgeInsets.all(18), this.color, this.onTap});
  final Widget child;
  final EdgeInsets padding;
  final Color? color;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final box = Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? C.card,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: al(Colors.white, .07)),
      ),
      child: child,
    );
    return onTap == null ? box : Pressable(onTap: onTap, child: box);
  }
}

// ---------- ring progres ----------
class _RingPainter extends CustomPainter {
  _RingPainter(this.p, this.stroke, this.colors);
  final double p, stroke;
  final List<Color> colors;
  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(stroke / 2);
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = al(Colors.white, .08);
    canvas.drawArc(rect, 0, math.pi * 2, false, track);
    final v = p.clamp(0.0, 1.0);
    if (v <= 0) return;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        colors: colors,
        transform: const GradientRotation(-math.pi / 2),
      ).createShader(rect);
    canvas.drawArc(rect, -math.pi / 2, math.pi * 2 * v, false, paint);
  }

  @override
  bool shouldRepaint(_RingPainter o) => o.p != p || o.colors != colors;
}

class AnimatedRing extends StatelessWidget {
  const AnimatedRing({
    super.key,
    required this.value,
    required this.size,
    this.stroke = 14,
    this.colors = const [C.blue, C.cyan, C.blue],
    this.child,
  });
  final double value, size, stroke;
  final List<Color> colors;
  final Widget? child;
  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: value),
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeOutCubic,
        builder: (_, v, __) => SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _RingPainter(v, stroke, colors),
            child: Center(child: child),
          ),
        ),
      );
}

// ---------- hitung naik ----------
class CountUp extends StatelessWidget {
  const CountUp({super.key, required this.value, required this.fmt, this.style});
  final double value;
  final String Function(double) fmt;
  final TextStyle? style;
  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: value),
        duration: const Duration(milliseconds: 1200),
        curve: Curves.easeOutCubic,
        builder: (_, v, __) => Text(fmt(v), style: style),
      );
}

const tabular = [ui.FontFeature.tabularFigures()];

// ---------- api streak ----------
class Flame extends StatefulWidget {
  const Flame({super.key, this.size = 56, this.active = true});
  final double size;
  final bool active;
  @override
  State<Flame> createState() => _FlameState();
}

class _FlameState extends State<Flame> with SingleTickerProviderStateMixin {
  late final AnimationController c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
        ..repeat(reverse: true);
  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: c,
        builder: (_, __) {
          final t = widget.active ? Curves.easeInOut.transform(c.value) : 0.0;
          return Stack(alignment: Alignment.center, children: [
            Container(
              width: widget.size * .6,
              height: widget.size * .6,
              decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [
                BoxShadow(
                    color: al(C.flame, widget.active ? .25 + .3 * t : 0),
                    blurRadius: 20 + 26 * t,
                    spreadRadius: 2 + 6 * t),
              ]),
            ),
            Transform.scale(
              scale: 1 + .09 * t,
              child: ShaderMask(
                shaderCallback: (r) => LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: widget.active
                      ? const [Color(0xFFFF3D00), C.flame, Color(0xFFFFE066)]
                      : [Colors.grey.shade700, Colors.grey.shade500],
                ).createShader(r),
                child: Icon(Icons.local_fire_department_rounded,
                    size: widget.size, color: Colors.white),
              ),
            ),
          ]);
        },
      );
}

// ---------- rute lari ----------
class _RoutePainter extends CustomPainter {
  _RoutePainter(this.pts, this.progress);
  final List<List<double>> pts;
  final double progress;
  @override
  void paint(Canvas canvas, Size size) {
    // grid halus
    final grid = Paint()
      ..color = al(Colors.white, .04)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 28) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (double y = 0; y < size.height; y += 28) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    if (pts.length < 2) return;
    var minLa = pts.first[0], maxLa = minLa, minLo = pts.first[1], maxLo = minLo;
    for (final p in pts) {
      minLa = math.min(minLa, p[0]);
      maxLa = math.max(maxLa, p[0]);
      minLo = math.min(minLo, p[1]);
      maxLo = math.max(maxLo, p[1]);
    }
    final k = math.cos((minLa + maxLa) / 2 * math.pi / 180);
    final w = math.max((maxLo - minLo) * k, 1e-7);
    final h = math.max(maxLa - minLa, 1e-7);
    const pad = 22.0;
    final s = math.min((size.width - pad * 2) / w, (size.height - pad * 2) / h);
    final ox = (size.width - w * s) / 2, oy = (size.height - h * s) / 2;
    Offset map(List<double> p) =>
        Offset(ox + (p[1] - minLo) * k * s, oy + (maxLa - p[0]) * s);

    final path = Path()..moveTo(map(pts.first).dx, map(pts.first).dy);
    for (final p in pts.skip(1)) {
      final o = map(p);
      path.lineTo(o.dx, o.dy);
    }
    Path shown = path;
    Offset? tip;
    final metrics = path.computeMetrics().toList();
    if (progress < 1 && metrics.isNotEmpty) {
      final total = metrics.fold<double>(0, (a, m) => a + m.length);
      var left = total * progress;
      shown = Path();
      for (final m in metrics) {
        final take = math.min(left, m.length);
        shown.addPath(m.extractPath(0, take), Offset.zero);
        tip = m.getTangentForOffset(take)?.position;
        left -= take;
        if (left <= 0) break;
      }
    } else {
      tip = map(pts.last);
    }
    final glow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = al(C.cyan, .35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..shader = const LinearGradient(colors: [C.cyan, C.blue, Color(0xFF8A5CFF)])
          .createShader(Offset.zero & size);
    canvas.drawPath(shown, glow);
    canvas.drawPath(shown, line);
    final a = map(pts.first);
    canvas.drawCircle(a, 7, Paint()..color = C.good);
    canvas.drawCircle(a, 3, Paint()..color = Colors.white);
    if (tip != null) {
      canvas.drawCircle(tip, 10, Paint()..color = al(Colors.white, .25));
      canvas.drawCircle(tip, 6, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(_RoutePainter o) => o.progress != progress || o.pts.length != pts.length;
}

class RouteView extends StatelessWidget {
  const RouteView({super.key, required this.points, this.height = 200, this.animate = false});
  final List<List<double>> points;
  final double height;
  final bool animate;
  @override
  Widget build(BuildContext context) {
    Widget paint(double p) => CustomPaint(
          size: Size(double.infinity, height),
          painter: _RoutePainter(points, p),
        );
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: height,
        width: double.infinity,
        color: al(Colors.black, .25),
        child: points.length < 2
            ? Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.route_rounded, color: al(Colors.white, .25), size: 34),
                const SizedBox(height: 6),
                Text('Rute muncul saat kamu mulai bergerak',
                    style: TextStyle(color: al(Colors.white, .35), fontSize: 12)),
              ]))
            : animate
                ? TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 2200),
                    curve: Curves.easeInOutCubic,
                    builder: (_, v, __) => paint(v),
                  )
                : paint(1),
      ),
    );
  }
}

// ---------- grafik batang mingguan ----------
class WeekBars extends StatelessWidget {
  const WeekBars({super.key, required this.values, required this.todayIndex});
  final List<double> values;
  final int todayIndex;
  @override
  Widget build(BuildContext context) {
    const labels = ['S', 'S', 'R', 'K', 'J', 'S', 'M'];
    final mx = math.max(values.fold<double>(0, math.max), 1.0);
    return SizedBox(
      height: 130,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(7, (i) {
          final h = math.max(values[i] / mx * 90, 5.0);
          final isToday = i == todayIndex;
          return Expanded(
            child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
              if (values[i] > 0)
                Text(values[i].toStringAsFixed(1),
                    style: const TextStyle(fontSize: 10, color: C.sub)),
              const SizedBox(height: 4),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: h),
                duration: Duration(milliseconds: 600 + i * 80),
                curve: Curves.easeOutBack,
                builder: (_, v, __) => Container(
                  width: 22,
                  height: math.max(v, 0),
                  decoration: BoxDecoration(
                    gradient: values[i] > 0
                        ? const LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [C.blue, C.cyan])
                        : null,
                    color: values[i] > 0 ? null : al(Colors.white, .08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(labels[i],
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: isToday ? FontWeight.w900 : FontWeight.w500,
                      color: isToday ? C.cyan : C.sub)),
            ]),
          );
        }),
      ),
    );
  }
}

// ---------- tile statistik ----------
class StatTile extends StatelessWidget {
  const StatTile({super.key, required this.label, required this.value, required this.unit, this.icon, this.color = C.cyan});
  final String label, value, unit;
  final IconData? icon;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: C.card,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: al(Colors.white, .07)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            if (icon != null) Icon(icon, size: 15, color: color),
            if (icon != null) const SizedBox(width: 5),
            Flexible(
                child: Text(label,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, color: C.sub, fontWeight: FontWeight.w600))),
          ]),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value,
                style: const TextStyle(
                    fontSize: 26, fontWeight: FontWeight.w900, fontFeatures: tabular)),
          ),
          Text(unit, style: const TextStyle(fontSize: 11, color: C.sub)),
        ]),
      );
}

// ---------- switch sendiri (aman lintas versi) ----------
class AniSwitch extends StatelessWidget {
  const AniSwitch({super.key, required this.value, required this.onChanged});
  final bool value;
  final ValueChanged<bool> onChanged;
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => onChanged(!value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          width: 54,
          height: 32,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            gradient: value ? C.grad : null,
            color: value ? null : al(Colors.white, .15),
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
              width: 26,
              height: 26,
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
        ),
      );
}

// ---------- confetti ----------
class Confetti extends StatefulWidget {
  const Confetti({super.key});
  @override
  State<Confetti> createState() => _ConfettiState();
}

class _ConfettiState extends State<Confetti> with SingleTickerProviderStateMixin {
  late final AnimationController c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 3600))..forward();
  final rnd = math.Random();
  late final List<List<double>> ps = List.generate(
      70, (_) => [rnd.nextDouble(), rnd.nextDouble() * .4, .5 + rnd.nextDouble(), rnd.nextDouble() * 6, rnd.nextDouble()]);
  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: AnimatedBuilder(
          animation: c,
          builder: (_, __) => CustomPaint(
              size: Size.infinite, painter: _ConfettiPainter(ps, c.value)),
        ),
      );
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.ps, this.t);
  final List<List<double>> ps;
  final double t;
  static const cols = [C.cyan, C.blue, C.flame, C.good, C.warn, Colors.white];
  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < ps.length; i++) {
      final p = ps[i];
      final local = ((t - p[1]) / (1 - p[1])).clamp(0.0, 1.0);
      if (local <= 0) continue;
      final x = p[0] * size.width + math.sin(local * 6 + p[3]) * 24;
      final y = -20 + local * (size.height + 40) * p[2];
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(local * 8 + p[3]);
      canvas.drawRRect(
          RRect.fromRectAndRadius(const Rect.fromLTWH(-5, -3, 10, 6), const Radius.circular(2)),
          Paint()..color = al(cols[i % cols.length], 1 - local * .6));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter o) => o.t != t;
}

// ---------- toast melayang ----------
class FloatToast extends StatelessWidget {
  const FloatToast({super.key, required this.text});
  final String? text;
  @override
  Widget build(BuildContext context) => AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        switchInCurve: Curves.easeOutBack,
        transitionBuilder: (c, a) => FadeTransition(
          opacity: a,
          child: SlideTransition(
              position: Tween(begin: const Offset(0, -.6), end: Offset.zero).animate(a), child: c),
        ),
        child: text == null
            ? const SizedBox.shrink(key: ValueKey('none'))
            : Container(
                key: ValueKey(text),
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                decoration: BoxDecoration(
                  gradient: C.grad,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [BoxShadow(color: al(C.blue, .5), blurRadius: 20)],
                ),
                child: Text(text!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
              ),
      );
}
