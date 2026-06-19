import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../models/app_user.dart';
import '../../models/attendance_status.dart';
import '../../models/student_attendance.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';
import '../../widgets/page_header.dart';
import '../../widgets/role_scaffold.dart';
import '../../widgets/status_chip.dart';

class TeacherClassAttendanceEditorScreen extends StatefulWidget {
  const TeacherClassAttendanceEditorScreen({
    super.key,
    this.classId,
    this.date,
  });

  final String? classId;
  final DateTime? date;

  @override
  State<TeacherClassAttendanceEditorScreen> createState() =>
      _TeacherClassAttendanceEditorScreenState();
}

class _TeacherClassAttendanceEditorScreenState
    extends State<TeacherClassAttendanceEditorScreen> {
  String? _classId;
  late DateTime _date;
  final Map<String, AttendanceStatus> _selections = {};
  bool _hydrated = false;

  @override
  void initState() {
    super.initState();
    _classId = widget.classId;
    _date = widget.date ?? DateTime.now();
    _date = DateTime(_date.year, _date.month, _date.day);
  }

  void _hydrate(DataProvider data) {
    if (_hydrated) return;
    if (_classId != null) {
      final existing =
          data.studentAttendanceForClassOnDate(_classId!, _date);
      for (final a in existing) {
        _selections[a.studentId] = a.status;
      }
    }
    _hydrated = true;
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 7)),
    );
    if (d != null) {
      setState(() {
        _date = DateTime(d.year, d.month, d.day);
        _hydrated = false;
        _selections.clear();
      });
    }
  }

  void _setAll(AttendanceStatus s, List<String> studentIds) {
    setState(() {
      for (final id in studentIds) {
        _selections[id] = s;
      }
    });
  }

  Future<void> _save() async {
    if (_classId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih kelas terlebih dahulu')),
      );
      return;
    }
    final user = context.read<AuthProvider>().user!;
    final data = context.read<DataProvider>();
    final cls = data.classById(_classId!);
    if (cls == null) return;

    final existing = {
      for (final a in data.studentAttendanceForClassOnDate(_classId!, _date))
        a.studentId: a,
    };

    for (final studentId in cls.studentIds) {
      final status = _selections[studentId] ?? AttendanceStatus.alpa;
      final prev = existing[studentId];
      final att = StudentAttendance(
        id: prev?.id ?? const Uuid().v4(),
        classId: _classId!,
        studentId: studentId,
        date: _date,
        status: status,
        recordedByTeacherId: user.id,
      );
      await data.upsertStudentAttendance(att);
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Presensi tersimpan')),
      );
      context.go('/teacher/class-attendance');
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();
    _hydrate(data);
    final df = DateFormat('EEEE, dd MMM yyyy', 'id_ID');
    final cls = _classId == null ? null : data.classById(_classId!);
    final students = cls == null
        ? <AppUser>[]
        : cls.studentIds
            .map((id) => data.userById(id))
            .whereType<AppUser>()
            .toList();

    final hadir = _selections.values
        .where((s) => s == AttendanceStatus.hadir)
        .length;
    final total = students.length;

    return RoleScaffold(
      title: 'Ambil Presensi',
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: ListView(
            padding: const EdgeInsets.all(8),
            children: [
              PageHeader(
                title: 'Ambil Presensi Kelas',
                subtitle: 'Pilih kelas dan tanggal, lalu tandai status tiap siswa.',
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      LayoutBuilder(builder: (context, constraints) {
                        final wide = constraints.maxWidth >= 600;
                        final classDropdown = DropdownButtonFormField<String?>(
                          initialValue: _classId,
                          items: data.classes
                              .map((c) => DropdownMenuItem(
                                  value: c.id, child: Text(c.name)))
                              .toList(),
                          onChanged: (v) => setState(() {
                            _classId = v;
                            _selections.clear();
                            _hydrated = false;
                          }),
                          decoration: const InputDecoration(
                            labelText: 'Kelas',
                            prefixIcon: Icon(Icons.class_outlined),
                          ),
                        );
                        final dateField = InkWell(
                          onTap: _pickDate,
                          borderRadius: BorderRadius.circular(10),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Tanggal',
                              prefixIcon: Icon(Icons.calendar_today_outlined),
                            ),
                            child: Text(df.format(_date)),
                          ),
                        );
                        if (wide) {
                          return Row(
                            children: [
                              Expanded(child: classDropdown),
                              const SizedBox(width: 12),
                              Expanded(child: dateField),
                            ],
                          );
                        }
                        return Column(
                          children: [
                            classDropdown,
                            const SizedBox(height: 12),
                            dateField,
                          ],
                        );
                      }),
                      if (cls != null) ...[
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Text('Total siswa: $total',
                                style: Theme.of(context).textTheme.bodyMedium),
                            const Spacer(),
                            Text('Hadir: $hadir / $total',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final s in AttendanceStatus.values)
                              OutlinedButton(
                                onPressed: () => _setAll(
                                    s, cls.studentIds.toList()),
                                style: OutlinedButton.styleFrom(
                                    foregroundColor: s.color),
                                child: Text('Semua ${s.label}'),
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (cls == null)
                const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(child: Text('Pilih kelas untuk memulai')),
                )
              else if (students.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(child: Text('Kelas belum memiliki siswa')),
                )
              else
                Card(
                  child: Column(
                    children: [
                      for (var i = 0; i < students.length; i++) ...[
                        if (i > 0) const Divider(height: 1),
                        _StudentRow(
                          number: i + 1,
                          name: students[i].name,
                          selected: _selections[students[i].id],
                          onChange: (s) => setState(
                              () => _selections[students[i].id] = s),
                        ),
                      ],
                    ],
                  ),
                ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () =>
                        context.go('/teacher/class-attendance'),
                    child: const Text('Batal'),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: cls == null ? null : _save,
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Simpan Presensi'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _StudentRow extends StatelessWidget {
  const _StudentRow({
    required this.number,
    required this.name,
    required this.selected,
    required this.onChange,
  });

  final int number;
  final String name;
  final AttendanceStatus? selected;
  final ValueChanged<AttendanceStatus> onChange;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text('$number.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ),
          Expanded(
            child: Text(name,
                style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          const SizedBox(width: 8),
          if (selected != null) AttendanceStatusChip(status: selected!),
          const SizedBox(width: 8),
          PopupMenuButton<AttendanceStatus>(
            tooltip: 'Pilih status',
            initialValue: selected,
            onSelected: onChange,
            itemBuilder: (_) => [
              for (final s in AttendanceStatus.values)
                PopupMenuItem(
                  value: s,
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle, color: s.color),
                      ),
                      const SizedBox(width: 10),
                      Text(s.label),
                    ],
                  ),
                ),
            ],
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.edit_outlined,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 6),
                  Text(selected == null ? 'Pilih' : 'Ubah',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
