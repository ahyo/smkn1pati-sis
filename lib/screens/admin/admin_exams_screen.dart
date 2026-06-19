import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/exam.dart';
import '../../models/user_role.dart';
import '../../providers/data_provider.dart';
import '../../widgets/app_table.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/page_header.dart';
import '../../widgets/paginated_list_view.dart';
import '../../widgets/role_scaffold.dart';

class AdminExamsScreen extends StatefulWidget {
  const AdminExamsScreen({super.key});

  @override
  State<AdminExamsScreen> createState() => _AdminExamsScreenState();
}

class _AdminExamsScreenState extends State<AdminExamsScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';
  String? _classId;
  String? _subjectId;
  String? _teacherId;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  bool _matches(Exam e) {
    if (_classId != null && e.classId != _classId) return false;
    if (_subjectId != null && e.subjectId != _subjectId) return false;
    if (_teacherId != null && e.teacherId != _teacherId) return false;
    if (_query.isEmpty) return true;
    final q = _query.toLowerCase();
    return e.title.toLowerCase().contains(q) ||
        e.description.toLowerCase().contains(q);
  }

  void _reset() {
    setState(() {
      _query = '';
      _searchCtrl.clear();
      _classId = null;
      _subjectId = null;
      _teacherId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();
    final df = DateFormat('dd MMM yyyy HH:mm', 'id_ID');
    final all = [...data.exams]..sort((a, b) => b.startAt.compareTo(a.startAt));
    final filtered = all.where(_matches).toList();
    final teachers =
        data.users.where((u) => u.role == UserRole.teacher).toList();

    final hasActiveFilter = _query.isNotEmpty ||
        _classId != null ||
        _subjectId != null ||
        _teacherId != null;

    // Aggregate stats across filtered exams
    final totalQs = filtered.fold<int>(0, (s, e) => s + e.questions.length);
    final totalEssays = filtered.fold<int>(0, (s, e) => s + e.essayCount);
    final allSubs = filtered.fold<int>(
        0, (s, e) => s + data.submissionsForExam(e.id).length);
    final avg = filtered.isEmpty
        ? 0.0
        : (filtered.fold<double>(0, (sum, e) {
              final subs = data.submissionsForExam(e.id);
              if (subs.isEmpty) return sum;
              final localAvg =
                  subs.map((s) => s.percentage).reduce((a, b) => a + b) /
                      subs.length;
              return sum + localAvg;
            }) /
            filtered.where((e) => data.submissionsForExam(e.id).isNotEmpty).length
                .clamp(1, double.infinity));

    return RoleScaffold(
      title: 'Pantau Ujian',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeader(
            title: 'Pantau Ujian',
            subtitle: hasActiveFilter
                ? '${filtered.length} dari ${all.length} ujian'
                : '${all.length} ujian tercatat di semua kelas & mapel',
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    LayoutBuilder(builder: (context, c) {
                      final wide = c.maxWidth >= 720;
                      final search = TextField(
                        controller: _searchCtrl,
                        onChanged: (v) => setState(() => _query = v),
                        decoration: InputDecoration(
                          hintText: 'Cari judul ujian atau deskripsi...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _query.isEmpty
                              ? null
                              : IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () {
                                    _searchCtrl.clear();
                                    setState(() => _query = '');
                                  },
                                ),
                        ),
                      );
                      final reset = OutlinedButton.icon(
                        onPressed: hasActiveFilter ? _reset : null,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reset'),
                      );
                      if (wide) {
                        return Row(
                          children: [
                            Expanded(child: search),
                            const SizedBox(width: 12),
                            reset,
                          ],
                        );
                      }
                      return Column(
                        children: [
                          search,
                          const SizedBox(height: 12),
                          Align(
                              alignment: Alignment.centerRight, child: reset),
                        ],
                      );
                    }),
                    const SizedBox(height: 12),
                    LayoutBuilder(builder: (context, c) {
                      final wide = c.maxWidth >= 720;
                      final classDD = DropdownButtonFormField<String?>(
                        initialValue: _classId,
                        items: [
                          const DropdownMenuItem(
                              value: null, child: Text('Semua kelas')),
                          ...data.classes.map((c) => DropdownMenuItem(
                              value: c.id, child: Text(c.name))),
                        ],
                        onChanged: (v) => setState(() => _classId = v),
                        decoration: const InputDecoration(
                          labelText: 'Kelas',
                          prefixIcon: Icon(Icons.class_outlined),
                        ),
                      );
                      final subjectDD = DropdownButtonFormField<String?>(
                        initialValue: _subjectId,
                        items: [
                          const DropdownMenuItem(
                              value: null, child: Text('Semua mapel')),
                          ...data.subjects.map((s) => DropdownMenuItem(
                              value: s.id, child: Text(s.name))),
                        ],
                        onChanged: (v) => setState(() => _subjectId = v),
                        decoration: const InputDecoration(
                          labelText: 'Mata Pelajaran',
                          prefixIcon: Icon(Icons.menu_book_outlined),
                        ),
                      );
                      final teacherDD = DropdownButtonFormField<String?>(
                        initialValue: _teacherId,
                        items: [
                          const DropdownMenuItem(
                              value: null, child: Text('Semua guru')),
                          ...teachers.map((t) => DropdownMenuItem(
                              value: t.id, child: Text(t.name))),
                        ],
                        onChanged: (v) => setState(() => _teacherId = v),
                        decoration: const InputDecoration(
                          labelText: 'Guru Pembuat',
                          prefixIcon: Icon(Icons.school_outlined),
                        ),
                      );
                      if (wide) {
                        return Row(
                          children: [
                            Expanded(child: classDD),
                            const SizedBox(width: 12),
                            Expanded(child: subjectDD),
                            const SizedBox(width: 12),
                            Expanded(child: teacherDD),
                          ],
                        );
                      }
                      return Column(
                        children: [
                          classDD,
                          const SizedBox(height: 12),
                          subjectDD,
                          const SizedBox(height: 12),
                          teacherDD,
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
          if (filtered.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _MetricChip(
                    label: 'Ujian',
                    value: '${filtered.length}',
                    icon: Icons.quiz_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  _MetricChip(
                    label: 'Total Soal',
                    value: '$totalQs',
                    icon: Icons.help_outline,
                    color: Colors.indigo.shade700,
                  ),
                  _MetricChip(
                    label: 'Soal Essay',
                    value: '$totalEssays',
                    icon: Icons.notes_outlined,
                    color: Colors.deepPurple,
                  ),
                  _MetricChip(
                    label: 'Total Submisi',
                    value: '$allSubs',
                    icon: Icons.assignment_turned_in_outlined,
                    color: Colors.green.shade700,
                  ),
                  _MetricChip(
                    label: 'Rata-rata Nilai',
                    value: '${avg.toStringAsFixed(1)}%',
                    icon: Icons.trending_up,
                    color: Colors.teal.shade700,
                  ),
                ],
              ),
            ),
          Expanded(
            child: ResponsiveView(
              desktop: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: SingleChildScrollView(
                  child: AppTable<Exam>(
                    items: filtered,
                    onRowTap: (e) => context.go('/admin/exams/${e.id}'),
                    columns: [
                      AppTableColumn(
                        label: 'Judul',
                        build: (e) => Text(e.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontWeight: FontWeight.w500)),
                      ),
                      AppTableColumn(
                        label: 'Mapel',
                        build: (e) =>
                            Text(data.subjectById(e.subjectId)?.name ?? '-'),
                      ),
                      AppTableColumn(
                        label: 'Kelas',
                        build: (e) =>
                            Text(data.classById(e.classId)?.name ?? '-'),
                      ),
                      AppTableColumn(
                        label: 'Guru',
                        build: (e) =>
                            Text(data.userById(e.teacherId)?.name ?? '-',
                                maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                      AppTableColumn(
                        label: 'Soal',
                        numeric: true,
                        build: (e) => Text(
                            '${e.questions.length} (${e.mcCount} PG · ${e.essayCount} Essay)'),
                      ),
                      AppTableColumn(
                        label: 'Submisi',
                        numeric: true,
                        build: (e) =>
                            Text('${data.submissionsForExam(e.id).length}'),
                      ),
                      AppTableColumn(
                        label: 'Rata-rata',
                        build: (e) {
                          final subs = data.submissionsForExam(e.id);
                          if (subs.isEmpty) {
                            return Text('-',
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant));
                          }
                          final a = subs
                                  .map((s) => s.percentage)
                                  .reduce((a, b) => a + b) /
                              subs.length;
                          return _AvgPill(percent: a);
                        },
                      ),
                      AppTableColumn(
                        label: 'Jadwal',
                        build: (e) => Text(df.format(e.startAt)),
                      ),
                      AppTableColumn(
                        label: 'Status',
                        build: (e) => _StatusChip(exam: e),
                      ),
                    ],
                    actions: [
                      AppTableAction(
                        icon: Icons.visibility_outlined,
                        tooltip: 'Lihat soal',
                        onPressed: (ctx, e) =>
                            ctx.go('/admin/exams/${e.id}'),
                      ),
                    ],
                    emptyIcon: hasActiveFilter
                        ? Icons.search_off
                        : Icons.quiz_outlined,
                    emptyTitle: hasActiveFilter
                        ? 'Tidak ada ujian sesuai filter'
                        : 'Belum ada ujian',
                    emptyMessage: hasActiveFilter
                        ? 'Coba ubah filter atau kata kunci.'
                        : 'Ujian akan muncul saat guru membuatnya.',
                  ),
                ),
              ),
              mobile: filtered.isEmpty
                  ? EmptyState(
                      icon: hasActiveFilter
                          ? Icons.search_off
                          : Icons.quiz_outlined,
                      title: hasActiveFilter
                          ? 'Tidak ada ujian sesuai filter'
                          : 'Belum ada ujian',
                      action: hasActiveFilter
                          ? OutlinedButton.icon(
                              onPressed: _reset,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Reset'),
                            )
                          : null,
                    )
                  : PaginatedListView<Exam>(
                      items: filtered,
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                      itemBuilder: (_, e, i) {
                        final subs = data.submissionsForExam(e.id);
                        final avgLocal = subs.isEmpty
                            ? null
                            : subs
                                    .map((s) => s.percentage)
                                    .reduce((a, b) => a + b) /
                                subs.length;
                        return Card(
                          child: ListTile(
                            onTap: () => context.go('/admin/exams/${e.id}'),
                            leading: const Icon(Icons.quiz_outlined),
                            title: Text('${i + 1}. ${e.title}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                            subtitle: Text(
                                '${data.subjectById(e.subjectId)?.name ?? '-'} • ${data.classById(e.classId)?.name ?? '-'} • ${data.userById(e.teacherId)?.name ?? '-'}\n'
                                '${e.questions.length} soal (${e.mcCount} PG · ${e.essayCount} Essay) • ${subs.length} submisi${avgLocal != null ? ' • avg ${avgLocal.toStringAsFixed(0)}%' : ''}'),
                            isThreeLine: true,
                            trailing: _StatusChip(exam: e),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(value,
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 16)),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                  color: color.withValues(alpha: 0.85),
                  fontSize: 12,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _AvgPill extends StatelessWidget {
  const _AvgPill({required this.percent});
  final double percent;

  @override
  Widget build(BuildContext context) {
    final c = percent >= 75
        ? Colors.green.shade700
        : percent >= 60
            ? Colors.orange.shade700
            : Theme.of(context).colorScheme.error;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text('${percent.toStringAsFixed(0)}%',
          style: TextStyle(
              color: c, fontWeight: FontWeight.w600, fontSize: 12)),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.exam});
  final Exam exam;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final String label;
    final Color color;
    if (exam.isActive) {
      label = 'Aktif';
      color = Colors.green.shade700;
    } else if (exam.startAt.isAfter(now)) {
      label = 'Terjadwal';
      color = Colors.orange.shade700;
    } else {
      label = 'Berakhir';
      color = Colors.grey.shade600;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontWeight: FontWeight.w600, fontSize: 12)),
    );
  }
}
