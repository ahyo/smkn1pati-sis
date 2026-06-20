import 'attendance_status.dart';

class StudentAttendance {
  final String id;
  final String classId;
  final String studentId;

  /// Mata pelajaran presensi ini. Null untuk presensi harian lama (umum).
  final String? subjectId;
  final DateTime date;
  final AttendanceStatus status;
  final String? recordedByTeacherId;
  final String? note;

  const StudentAttendance({
    required this.id,
    required this.classId,
    required this.studentId,
    this.subjectId,
    required this.date,
    required this.status,
    this.recordedByTeacherId,
    this.note,
  });

  static String dateKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String get dateKeyStr => dateKey(date);

  Map<String, dynamic> toMap() => {
        'classId': classId,
        'studentId': studentId,
        'subjectId': subjectId,
        'date': date.toIso8601String(),
        'status': status.name,
        'recordedByTeacherId': recordedByTeacherId,
        'note': note,
      };

  factory StudentAttendance.fromMap(String id, Map<String, dynamic> map) {
    return StudentAttendance(
      id: id,
      classId: map['classId'] as String? ?? '',
      studentId: map['studentId'] as String? ?? '',
      subjectId: map['subjectId'] as String?,
      date: DateTime.tryParse(map['date'] as String? ?? '') ?? DateTime.now(),
      status: AttendanceStatus.fromString(map['status'] as String?),
      recordedByTeacherId: map['recordedByTeacherId'] as String?,
      note: map['note'] as String?,
    );
  }
}
