import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/exam_submission.dart';
import '../../models/user_role.dart';
import '../../providers/data_provider.dart';
import '../../widgets/app_table.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/page_header.dart';
import '../../widgets/paginated_list_view.dart';
import '../../widgets/role_scaffold.dart';

const int _kPassingScore = 70;

class AdminGradesScreen extends StatefulWidget {
  const AdminGradesScreen({super.key});

  @override
  State<AdminGradesScreen> createState() => _AdminGradesScreenState();
}

class _AdminGradesScreenState extends State<AdminGradesScreen> {
  String? _classId;
  String? _subjectId;
  String? _studentId;

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();
    final df = DateFormat('dd MMM yyyy', 'id_ID');

    // If a class is selected, restrict student dropdown to that class.
    final allStudents =
        data.users.where((u) => u.role == UserRole.student).toList()
          ..sort((a, b) => a.name.compareTo(b.name));
    final filteredStudents = _classId == null
        ? allStudents
        : allStudents.where((s) => s.classId == _classId).toList();

    // Build the filtered submissions list.
    final rows = data.submissions.where((s) {
      final exam = data.examById(s.examId);
      if (exam == null) return false;
      if (_classId != null && exam.classId != _classId) return false;
      if (_subjectId != null && exam.subjectId != _subjectId) return false;
      if (_studentId != null && s.studentId != _studentId) return false;
      return true;
    }).toList()
      ..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));

    final total = rows.length;
    final avg = rows.isEmpty
        ? 0.0
        : rows.map((s) => s.percentage).reduce((a, b) => a + b) / rows.length;
    final passed = rows.where((s) => s.percentage >= _kPassingScore).length;
    final passRate = rows.isEmpty ? 0 : (passed / total * 100).round();

    return RoleScaffold(
      title: 'Nilai Siswa',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeader(
            title: 'Nilai Siswa',
            subtitle: total == 0
                ? 'Pilih filter untuk melihat data nilai'
                : '$total submisi • Rata-rata ${avg.toStringAsFixed(1)}% • Lulus $passRate% (KKM $_kPassingScore)',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: LayoutBuilder(builder: (context, constraints) {
                  final wide = constraints.maxWidth >= 720;
                  final classDropdown = DropdownButtonFormField<String?>(
                    initialValue: _classId,
                    items: [
                      const DropdownMenuItem(
                          value: null, child: Text('Semua kelas')),
                      ...data.classes.map((c) => DropdownMenuItem(
                          value: c.id, child: Text(c.name))),
                    ],
                    onChanged: (v) => setState(() {
                      _classId = v;
                      // Reset student if no longer in class.
                      if (_studentId != null) {
                        final st = data.userById(_studentId!);
                        if (st != null && _classId != null && st.classId != _classId) {
                          _studentId = null;
                        }
                      }
                    }),
                    decoration: const InputDecoration(
                      labelText: 'Kelas',
                      prefixIcon: Icon(Icons.class_outlined),
                    ),
                  );
                  final subjectDropdown =
                      DropdownButtonFormField<String?>(
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
                  final studentDropdown =
                      DropdownButtonFormField<String?>(
                    initialValue: filteredStudents
                            .any((s) => s.id == _studentId)
                        ? _studentId
                        : null,
                    items: [
                      const DropdownMenuItem(
                          value: null, child: Text('Semua siswa')),
                      ...filteredStudents.map((s) => DropdownMenuItem(
                          value: s.id, child: Text(s.name))),
                    ],
                    onChanged: (v) => setState(() => _studentId = v),
                    decoration: const InputDecoration(
                      labelText: 'Siswa',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  );
                  final resetBtn = OutlinedButton.icon(
                    onPressed: (_classId == null &&
                            _subjectId == null &&
                            _studentId == null)
                        ? null
                        : () => setState(() {
                              _classId = null;
                              _subjectId = null;
                              _studentId = null;
                            }),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reset Filter'),
                  );

                  if (wide) {
                    return Column(
                      children: [
                        Row(
                          children: [
                            Expanded(child: classDropdown),
                            const SizedBox(width: 12),
                            Expanded(child: subjectDropdown),
                            const SizedBox(width: 12),
                            Expanded(child: studentDropdown),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Align(
                            alignment: Alignment.centerRight,
                            child: resetBtn),
                      ],
                    );
                  }
                  return Column(
                    children: [
                      classDropdown,
                      const SizedBox(height: 12),
                      subjectDropdown,
                      const SizedBox(height: 12),
                      studentDropdown,
                      const SizedBox(height: 12),
                      Align(
                          alignment: Alignment.centerRight, child: resetBtn),
                    ],
                  );
                }),
              ),
            ),
          ),
          if (total > 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _MetricCard(
                    label: 'Total Submisi',
                    value: '$total',
                    icon: Icons.assignment_turned_in_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  _MetricCard(
                    label: 'Rata-rata',
                    value: '${avg.toStringAsFixed(1)}%',
                    icon: Icons.trending_up,
                    color: Colors.indigo.shade700,
                  ),
                  _MetricCard(
                    label: 'Lulus KKM ($_kPassingScore)',
                    value: '$passed dari $total',
                    icon: Icons.verified_outlined,
                    color: Colors.green.shade700,
                  ),
                  _MetricCard(
                    label: 'Persentase Lulus',
                    value: '$passRate%',
                    icon: Icons.percent,
                    color: passRate >= 75
                        ? Colors.green.shade700
                        : passRate >= 50
                            ? Colors.orange.shade700
                            : Theme.of(context).colorScheme.error,
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          Expanded(
            child: ResponsiveView(
              desktop: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: SingleChildScrollView(
                  child: AppTable<ExamSubmission>(
                    items: rows,
                    columns: [
                      AppTableColumn(
                        label: 'Siswa',
                        build: (s) {
                          final st = data.userById(s.studentId);
                          return Text(st?.name ?? '-',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w500));
                        },
                      ),
                      AppTableColumn(
                        label: 'Kelas',
                        build: (s) {
                          final st = data.userById(s.studentId);
                          return Text(
                              st?.classId == null
                                  ? '-'
                                  : data.classById(st!.classId!)?.name ?? '-');
                        },
                      ),
                      AppTableColumn(
                        label: 'Mapel',
                        build: (s) {
                          final ex = data.examById(s.examId);
                          return Text(ex == null
                              ? '-'
                              : data.subjectById(ex.subjectId)?.name ?? '-');
                        },
                      ),
                      AppTableColumn(
                        label: 'Ujian',
                        build: (s) =>
                            Text(data.examById(s.examId)?.title ?? '-',
                                maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                      AppTableColumn(
                        label: 'Tanggal',
                        build: (s) => Text(df.format(s.submittedAt)),
                      ),
                      AppTableColumn(
                        label: 'Skor',
                        numeric: true,
                        build: (s) => Text('${s.score}/${s.totalPoints}',
                            style: const TextStyle(
                                fontWeight: FontWeight.w600)),
                      ),
                      AppTableColumn(
                        label: 'Nilai',
                        build: (s) => _ScoreBar(percentage: s.percentage),
                      ),
                      AppTableColumn(
                        label: 'Status',
                        build: (s) => _PassChip(percentage: s.percentage),
                      ),
                    ],
                    emptyIcon: Icons.assessment_outlined,
                    emptyTitle: 'Tidak ada data nilai',
                    emptyMessage:
                        'Coba ubah filter atau pastikan siswa sudah mengerjakan ujian.',
                  ),
                ),
              ),
              mobile: rows.isEmpty
                  ? const EmptyState(
                      icon: Icons.assessment_outlined,
                      title: 'Tidak ada data nilai',
                      message: 'Coba ubah filter di atas.',
                    )
                  : PaginatedListView<ExamSubmission>(
                      items: rows,
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                      itemBuilder: (_, s, i) {
                        final st = data.userById(s.studentId);
                        final ex = data.examById(s.examId);
                        final subject = ex == null
                            ? null
                            : data.subjectById(ex.subjectId);
                        return Card(
                          child: ListTile(
                            leading: const Icon(Icons.assessment_outlined),
                            title: Text('${i + 1}. ${st?.name ?? '-'}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                            subtitle: Text(
                                '${ex?.title ?? '-'}\n${subject?.name ?? '-'} • ${df.format(s.submittedAt)}'),
                            isThreeLine: true,
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('${s.score}/${s.totalPoints}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium),
                                _PassChip(percentage: s.percentage),
                              ],
                            ),
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

class _MetricCard extends StatelessWidget {
  const _MetricCard({
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      constraints: const BoxConstraints(minWidth: 180),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label,
                  style: TextStyle(
                      color: color.withValues(alpha: 0.85),
                      fontSize: 12,
                      fontWeight: FontWeight.w500)),
              Text(value,
                  style: TextStyle(
                      color: color,
                      fontSize: 18,
                      fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScoreBar extends StatelessWidget {
  const _ScoreBar({required this.percentage});
  final double percentage;

  @override
  Widget build(BuildContext context) {
    final color = percentage >= 75
        ? Colors.green.shade600
        : percentage >= 60
            ? Colors.orange.shade600
            : Theme.of(context).colorScheme.error;
    return SizedBox(
      width: 140,
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (percentage / 100).clamp(0, 1),
                minHeight: 6,
                backgroundColor:
                    Theme.of(context).colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 38,
            child: Text(
              '${percentage.toStringAsFixed(0)}%',
              style: TextStyle(color: color, fontWeight: FontWeight.w600),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

class _PassChip extends StatelessWidget {
  const _PassChip({required this.percentage});
  final double percentage;

  @override
  Widget build(BuildContext context) {
    final passed = percentage >= _kPassingScore;
    final color =
        passed ? Colors.green.shade700 : Theme.of(context).colorScheme.error;
    final label = passed ? 'Lulus' : 'Tidak Lulus';
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
