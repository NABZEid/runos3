import 'package:flutter/material.dart';
import 'core.dart';
import 'widgets.dart';
import 'screens_run.dart';

// ===================== RIWAYAT =====================
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  Future<bool> _confirm(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: C.card,
        title: const Text('Hapus lari ini?'),
        content: const Text('Data lari akan dihapus permanen.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Hapus', style: TextStyle(color: C.bad))),
        ],
      ),
    );
    return ok ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Store.i,
      builder: (context, _) {
        final runs = Store.i.runs;
        return SafeArea(
          bottom: false,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: FadeIn(
                child: Row(children: [
                  const Expanded(
                      child: Text('Riwayat',
                          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900))),
                  Text('${runs.length} lari',
                      style: const TextStyle(color: C.cyan, fontWeight: FontWeight.w800)),
                ]),
              ),
            ),
            Expanded(
              child: runs.isEmpty
                  ? const _Empty()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                      itemCount: runs.length,
                      itemBuilder: (context, i) {
                        final r = runs[i];
                        return FadeIn(
                          index: i < 8 ? i : 8,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Dismissible(
                              key: ValueKey(r.id),
                              direction: DismissDirection.endToStart,
                              confirmDismiss: (_) => _confirm(context),
                              onDismissed: (_) => Store.i.remove(r.id),
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 24),
                                decoration: BoxDecoration(
                                    color: al(C.bad, .8), borderRadius: BorderRadius.circular(26)),
                                child: const Icon(Icons.delete_outline_rounded, size: 30),
                              ),
                              child: Glass(
                                onTap: () => Navigator.push(
                                    context, fadeRoute(SummaryScreen(record: r))),
                                child: Row(children: [
                                  Container(
                                    width: 56,
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    decoration: BoxDecoration(
                                        color: al(C.blue, .2),
                                        borderRadius: BorderRadius.circular(16)),
                                    child: Column(children: [
                                      Text('${r.date.day}',
                                          style: const TextStyle(
                                              fontSize: 22, fontWeight: FontWeight.w900)),
                                      Text(fmtDate(r.date).split(' ')[1].toUpperCase(),
                                          style: const TextStyle(color: C.cyan, fontSize: 11)),
                                    ]),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(children: [
                                            Text('${fmtKm(r.dist)} km',
                                                style: const TextStyle(
                                                    fontSize: 20, fontWeight: FontWeight.w900)),
                                            if (r.targetHit) ...[
                                              const SizedBox(width: 8),
                                              const Icon(Icons.flag_rounded,
                                                  size: 16, color: C.good),
                                            ],
                                          ]),
                                          const SizedBox(height: 3),
                                          Text(
                                              '${fmtDur(r.dur)}  |  ${fmtPace(r.pace)}/km  |  ${r.kcal.round()} kkal',
                                              style: const TextStyle(color: C.sub, fontSize: 12.5)),
                                        ]),
                                  ),
                                  const Icon(Icons.chevron_right_rounded, color: C.sub),
                                ]),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ]),
        );
      },
    );
  }
}

class _Empty extends StatefulWidget {
  const _Empty();
  @override
  State<_Empty> createState() => _EmptyState();
}

class _EmptyState extends State<_Empty> with SingleTickerProviderStateMixin {
  late final AnimationController c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
        ..repeat(reverse: true);
  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          AnimatedBuilder(
            animation: c,
            builder: (_, __) => Transform.translate(
              offset: Offset(0, -14 * Curves.easeInOut.transform(c.value)),
              child: ShaderMask(
                shaderCallback: (r) => C.grad.createShader(r),
                child: const Icon(Icons.directions_run_rounded, size: 90, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Belum ada lari', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          const Text('Tekan tombol lari untuk memulai.', style: TextStyle(color: C.sub)),
          const SizedBox(height: 90),
        ]),
      );
}

// ===================== PROFIL =====================
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  double weight = Store.i.weight;
  double goal = Store.i.goalKm;

  Future<void> _editName() async {
    final ctrl = TextEditingController(text: Store.i.name);
    final res = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: C.card,
        title: const Text('Nama kamu'),
        content: TextField(controller: ctrl, autofocus: true, maxLength: 18),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
              child: const Text('Simpan')),
        ],
      ),
    );
    if (res != null && res.isNotEmpty) Store.i.setProfile(n: res);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Store.i,
      builder: (context, _) {
        final s = Store.i;
        return SafeArea(
          bottom: false,
          child: ListView(padding: const EdgeInsets.fromLTRB(20, 16, 20, 120), children: [
            FadeIn(
              child: Row(children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    gradient: C.grad,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: al(C.cyan, .35), blurRadius: 18)],
                  ),
                  alignment: Alignment.center,
                  child: Text(s.name.isEmpty ? 'R' : s.name[0].toUpperCase(),
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(s.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                    Row(children: [
                      const Icon(Icons.local_fire_department_rounded, size: 16, color: C.flame),
                      const SizedBox(width: 4),
                      Text('Streak terbaik ${s.bestStreak} hari',
                          style: const TextStyle(color: C.sub, fontSize: 13)),
                    ]),
                  ]),
                ),
                IconButton(onPressed: _editName, icon: const Icon(Icons.edit_rounded, color: C.cyan)),
              ]),
            ),
            const SizedBox(height: 20),
            FadeIn(
              index: 1,
              child: Column(children: [
                Row(children: [
                  Expanded(
                      child: StatTile(
                          label: 'TOTAL JARAK',
                          value: s.totalKm.toStringAsFixed(1),
                          unit: 'km',
                          icon: Icons.straighten_rounded)),
                  const SizedBox(width: 10),
                  Expanded(
                      child: StatTile(
                          label: 'TOTAL LARI',
                          value: '${s.runs.length}',
                          unit: 'aktivitas',
                          icon: Icons.directions_run_rounded)),
                ]),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(
                      child: StatTile(
                          label: 'TOTAL WAKTU',
                          value: fmtDur(s.totalSec),
                          unit: 'jam:menit:detik',
                          icon: Icons.timer_outlined)),
                  const SizedBox(width: 10),
                  Expanded(
                      child: StatTile(
                          label: 'TOTAL KALORI',
                          value: '${s.totalKcal.round()}',
                          unit: 'kkal',
                          icon: Icons.local_fire_department_rounded,
                          color: C.flame)),
                ]),
              ]),
            ),
            const SizedBox(height: 14),
            FadeIn(
              index: 2,
              child: Glass(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Pengaturan', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  const SizedBox(height: 14),
                  Row(children: [
                    const Icon(Icons.monitor_weight_outlined, size: 18, color: C.cyan),
                    const SizedBox(width: 8),
                    const Expanded(child: Text('Berat badan')),
                    Text('${weight.round()} kg', style: const TextStyle(fontWeight: FontWeight.w900)),
                  ]),
                  Slider(
                    value: weight,
                    min: 35,
                    max: 150,
                    divisions: 115,
                    onChanged: (v) => setState(() => weight = v),
                    onChangeEnd: (v) => Store.i.setProfile(w: v),
                  ),
                  const Text('Dipakai untuk menghitung kalori dan dehidrasi.',
                      style: TextStyle(color: C.sub, fontSize: 12)),
                  const SizedBox(height: 14),
                  Row(children: [
                    const Icon(Icons.flag_rounded, size: 18, color: C.cyan),
                    const SizedBox(width: 8),
                    const Expanded(child: Text('Target harian')),
                    Text('${goal.toStringAsFixed(1)} km',
                        style: const TextStyle(fontWeight: FontWeight.w900)),
                  ]),
                  Slider(
                    value: goal,
                    min: 1,
                    max: 20,
                    divisions: 38,
                    onChanged: (v) => setState(() => goal = v),
                    onChangeEnd: (v) => Store.i.setProfile(g: v),
                  ),
                ]),
              ),
            ),
            const SizedBox(height: 14),
            FadeIn(
              index: 3,
              child: Glass(
                child: Column(children: [
                  Row(children: [
                    ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset('assets/logo.png', width: 56, height: 56)),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('RunOS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                        Text('Versi 1.0.0', style: TextStyle(color: C.sub, fontSize: 12)),
                      ]),
                    ),
                  ]),
                  const SizedBox(height: 16),
                  _credit('Logo & prompter', 'ChatGPT'),
                  _credit('Builder & projects', 'Claude AI'),
                  _credit('Ide, setup dll', 'skyy'),
                ]),
              ),
            ),
          ]),
        );
      },
    );
  }

  Widget _credit(String role, String who) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(children: [
          const Icon(Icons.circle, size: 7, color: C.cyan),
          const SizedBox(width: 10),
          Expanded(child: Text(role, style: const TextStyle(color: C.sub))),
          Text(who, style: const TextStyle(fontWeight: FontWeight.w800)),
        ]),
      );
}
