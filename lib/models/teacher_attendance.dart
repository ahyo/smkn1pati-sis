import 'attendance_status.dart';

class TeacherAttendance {
  final String id;
  final String teacherId;
  final DateTime date; // logical day (00:00)
  final AttendanceStatus status;
  final DateTime? checkInTime;
  final String? note;

  const TeacherAttendance({
    required this.id,
    required this.teacherId,
    required this.date,
    required this.status,
    this.checkInTime,
    this.note,
  });

  /// Day-only key (e.g., 2026-05-09) used to enforce one record per day.
  static String dateKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String get dateKeyStr => dateKey(date);

  Map<String, dynamic> toMap() => {
        'teacherId': teacherId,
        'date': date.toIso8601String(),
        'status': status.name,
        'checkInTime': checkInTime?.toIso8601String(),
        'note': note,
      };

  factory TeacherAttendance.fromMap(String id, Map<String, dynamic> map) {
    return TeacherAttendance(
      id: id,
      teacherId: map['teacherId'] as String? ?? '',
      date: DateTime.tryParse(map['date'] as String? ?? '') ?? DateTime.now(),
      status: AttendanceStatus.fromString(map['status'] as String?),
      checkInTime: map['checkInTime'] == null
          ? null
          : DateTime.tryParse(map['checkInTime'] as String),
      note: map['note'] as String?,
    );
  }
}
